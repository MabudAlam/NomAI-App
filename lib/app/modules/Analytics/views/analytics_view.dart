import 'package:NomAi/app/components/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/components/shimmer.dart';
import 'package:NomAi/app/modules/Analytics/model/analytics.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:NomAi/app/utility/registry_service.dart';
import 'package:sizer/sizer.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  Future<MonthlyAnalytics?>? _future;
  String? _userId;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  _Metric _selectedMetric = _Metric.calories;
  int? _expandedIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      _userId ??= userState.userModel.userId;
      _future ??= serviceLocator<NutritionRecordRepo>()
          .getMonthlyAnalytics(userState.userModel.userId, _selectedMonth);
    }
  }

  Widget _buildSummary(MonthlyAnalytics data) {
    final days = data.dailyAnalytics;
    int totalCalories = 0;
    int totalProtein = 0;
    int totalFat = 0;
    int totalCarbs = 0;
    int maxDayCalories = 0;
    int totalWater = 0;
    int totalMeals = 0;

    for (final d in days) {
      totalCalories += d.totalCalories;
      totalProtein += d.totalProtein;
      totalFat += d.totalFat;
      totalCarbs += d.totalCarbs;
      totalMeals += d.mealCount;
      if (d.totalCalories > maxDayCalories) maxDayCalories = d.totalCalories;
      totalWater += d.waterIntake;
    }

    final int divisor = days.isNotEmpty ? days.length : 1;
    final avgCalories = (totalCalories / divisor).round();
    final avgProtein = (totalProtein / divisor).round();
    final avgCarbs = (totalCarbs / divisor).round();
    final avgFat = (totalFat / divisor).round();
    final avgWater = (totalWater / divisor).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: _buildMetricCards(
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            totalWater: totalWater,
          ),
        ),
        SizedBox(height: 1.5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: _buildMonthlyChart(
            days,
            monthTotal: _valueForSelectedMetric(
              totalCalories: totalCalories,
              totalProtein: totalProtein,
              totalCarbs: totalCarbs,
              totalFat: totalFat,
              totalWater: totalWater,
            ),
            totalMeals: totalMeals,
          ),
        ),
        SizedBox(height: 1.5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Container(
            padding: EdgeInsets.all(4.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: NomAIColors.lightSurface,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                  color: NomAIColors.blackText.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Monthly Averages',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NomAIColors.blackText,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Wrap(
                  spacing: 5.w,
                  runSpacing: 1.2.h,
                  children: [
                    _avgMetric('Avg Cal/day', '${avgCalories} cal'),
                    _avgMetric('Protein', '${avgProtein} g'),
                    _avgMetric('Carbs', '${avgCarbs} g'),
                    _avgMetric('Fat', '${avgFat} g'),
                    _avgMetric('Water', '${avgWater} ml'),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Daily breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: NomAIColors.blackText,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        ...days
            .asMap()
            .entries
            .map((e) => _dailyTile(e.value, e.key, maxDayCalories))
            .toList(),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 14.h),
      ],
    );
  }

  Widget _buildMonthHeader(String monthLabel) {
    return Row(
      children: [
        _MonthButton(icon: Icons.chevron_left, onTap: _prevMonth),
        Expanded(
          child: Center(
            child: Text(
              monthLabel,
              style: TextStyle(
                fontSize: 14,
                color: NomAIColors.whiteText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _MonthButton(icon: Icons.chevron_right, onTap: _nextMonth),
      ],
    );
  }

  Widget _buildMonthlyChart(
    List<DailyAnalytics> days, {
    required int monthTotal,
    required int totalMeals,
  }) {
    if (days.isEmpty) return const SizedBox.shrink();

    final sorted = [...days]..sort((a, b) => a.date.compareTo(b.date));
    final spots = <FlSpot>[];
    int minDay = 31;
    int maxDay = 1;
    double maxY = 0;
    for (final d in sorted) {
      final x = d.date.day.toDouble();
      final y = _valueForMetric(d).toDouble();
      spots.add(FlSpot(x, y));
      if (d.date.day < minDay) minDay = d.date.day;
      if (d.date.day > maxDay) maxDay = d.date.day;
      if (y > maxY) maxY = y;
    }

    // Add some headroom for y-axis
    final double yInterval = _niceYInterval(maxY);
    final double chartMaxY = (maxY == 0 ? 1000 : maxY + yInterval);

    return SizedBox(
      height: 28.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: NomAIColors.lightSurface,
          borderRadius: BorderRadius.circular(3.w),
          border:
              Border.all(color: NomAIColors.blackText.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(3.w, 1.5.h, 4.w, 1.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_metricTitle(_selectedMetric)} trend',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: NomAIColors.blackText,
                          ),
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          '$monthTotal ${_metricLabel(_selectedMetric)} · $totalMeals meals this month',
                          style: TextStyle(
                            fontSize: 11,
                            color: NomAIColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.5.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: NomAIColors.blackText,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _metricTitle(_selectedMetric),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.2.h),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: minDay.toDouble(),
                    maxX: maxDay.toDouble(),
                    minY: 0,
                    maxY: chartMaxY,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipPadding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((ts) {
                            final day = ts.x.toInt();
                            final value = ts.y.toInt();
                            final label = _metricLabel(_selectedMetric);
                            return LineTooltipItem(
                              'Day $day\n$value $label',
                              const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.black.withValues(alpha: 0.08),
                        strokeWidth: 1,
                      ),
                      horizontalInterval: yInterval,
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 14.w,
                          interval: yInterval,
                          getTitlesWidget: (value, meta) {
                            if (value < 0) return const SizedBox.shrink();
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                  fontSize: 10, color: NomAIColors.blackText),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _niceXInterval(minDay, maxDay),
                          getTitlesWidget: (value, meta) {
                            final v = value.toInt();
                            return Padding(
                              padding: EdgeInsets.only(top: 0.6.h),
                              child: Text(
                                v.toString(),
                                style: const TextStyle(
                                    fontSize: 10, color: NomAIColors.blackText),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(
                            color: Colors.black.withValues(alpha: 0.2),
                            width: 1),
                        bottom: BorderSide(
                            color: Colors.black.withValues(alpha: 0.2),
                            width: 1),
                        right: const BorderSide(color: Colors.transparent),
                        top: const BorderSide(color: Colors.transparent),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: NomAIColors.blackText,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, p, bar, i) =>
                              FlDotCirclePainter(
                            radius: 3,
                            color: NomAIColors.blackText,
                            strokeWidth: 0,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: NomAIColors.blackText.withValues(alpha: 0.06),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _niceXInterval(int minDay, int maxDay) {
    final range = (maxDay - minDay).clamp(1, 31);
    if (range <= 7) return 1;
    if (range <= 14) return 2;
    if (range <= 21) return 3;
    return 5;
  }

  double _niceYInterval(double maxY) {
    if (maxY <= 500) return 100;
    if (maxY <= 1200) return 200;
    if (maxY <= 2000) return 250;
    if (maxY <= 3000) return 500;
    return 1000;
  }

  Widget _avgMetric(String label, String value) {
    return SizedBox(
      width: 30.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: NomAIColors.blackText,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: NomAIColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards({
    required int totalCalories,
    required int totalProtein,
    required int totalCarbs,
    required int totalFat,
    required int totalWater,
  }) {
    final items = [
      _MetricCardData(
        metric: _Metric.calories,
        label: 'Calories',
        value: totalCalories,
        unit: 'cal',
        color: const Color(0xFF111111),
      ),
      _MetricCardData(
        metric: _Metric.protein,
        label: 'Protein',
        value: totalProtein,
        unit: 'g',
        color: const Color(0xFFE91E63),
      ),
      _MetricCardData(
        metric: _Metric.carbs,
        label: 'Carbs',
        value: totalCarbs,
        unit: 'g',
        color: const Color(0xFF6BAA3A),
      ),
      _MetricCardData(
        metric: _Metric.fat,
        label: 'Fat',
        value: totalFat,
        unit: 'g',
        color: const Color(0xFF2F80ED),
      ),
      _MetricCardData(
        metric: _Metric.water,
        label: 'Water',
        value: totalWater,
        unit: 'mL',
        color: NomAIColors.waterColor,
      ),
    ];

    return Wrap(
      spacing: 2.2.w,
      runSpacing: 1.2.h,
      children: items
          .map(
            (item) => GestureDetector(
              onTap: () => setState(() => _selectedMetric = item.metric),
              child: Container(
                width: 29.w,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.1.h),
                decoration: BoxDecoration(
                  color: _selectedMetric == item.metric
                      ? NomAIColors.blackText
                      : NomAIColors.lightSurface,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: _selectedMetric == item.metric
                        ? NomAIColors.blackText
                        : NomAIColors.blackText.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _selectedMetric == item.metric
                                  ? Colors.white
                                  : NomAIColors.blackText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.8.h),
                    Text(
                      '${item.value} ${item.unit}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _selectedMetric == item.metric
                            ? Colors.white
                            : NomAIColors.blackText,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Tap for trend',
                      style: TextStyle(
                        fontSize: 9,
                        color: _selectedMetric == item.metric
                            ? Colors.white.withValues(alpha: 0.8)
                            : NomAIColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  int _valueForSelectedMetric({
    required int totalCalories,
    required int totalProtein,
    required int totalCarbs,
    required int totalFat,
    required int totalWater,
  }) {
    switch (_selectedMetric) {
      case _Metric.calories:
        return totalCalories;
      case _Metric.protein:
        return totalProtein;
      case _Metric.carbs:
        return totalCarbs;
      case _Metric.fat:
        return totalFat;
      case _Metric.water:
        return totalWater;
    }
  }

  Widget _dailyTile(DailyAnalytics d, int index, int maxDayCalories) {
    final dayLabel = DateFormat('dd MMM').format(d.date);
    final percent =
        maxDayCalories > 0 ? (d.totalCalories / maxDayCalories) : 0.0;
    final expanded = _expandedIndex == index;

    return GestureDetector(
      onTap: () => setState(() {
        _expandedIndex = expanded ? null : index;
      }),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
        padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: NomAIColors.lightSurface,
          borderRadius: BorderRadius.circular(3.w),
          border:
              Border.all(color: NomAIColors.blackText.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 18.w,
                  child: Text(
                    dayLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NomAIColors.blackText,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 0.6.h,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: percent.clamp(0.0, 1.0),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: NomAIColors.blackText,
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      Text(
                        '${d.totalCalories} cal · ${d.mealCount} meals',
                        style: TextStyle(
                          fontSize: 11,
                          color: NomAIColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: NomAIColors.blackText,
                  size: 4.w,
                ),
              ],
            ),
            if (expanded) ...[
              SizedBox(height: 1.h),
              Divider(color: Colors.black.withValues(alpha: 0.08), height: 1),
              SizedBox(height: 1.h),
              _expandedMetrics(d),
              if ((d.overAllSummary ?? '').isNotEmpty) ...[
                SizedBox(height: 1.h),
                Text(
                  d.overAllSummary!,
                  style: TextStyle(fontSize: 12, color: NomAIColors.grey),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _expandedMetrics(DailyAnalytics d) {
    final pairs = <MapEntry<String, String>>[
      MapEntry('Calories', '${d.totalCalories} cal'),
      MapEntry('Protein', '${d.totalProtein} g'),
      MapEntry('Carbs', '${d.totalCarbs} g'),
      MapEntry('Fat', '${d.totalFat} g'),
      MapEntry('Water', '${d.waterIntake} ml'),
      MapEntry('Burned', '${d.totalCaloriesBurned} cal'),
      MapEntry('Meals', d.mealCount.toString()),
    ];

    return Wrap(
      spacing: 4.w,
      runSpacing: 1.h,
      children: pairs.map((e) => _kv(e.key, e.value)).toList(),
    );
  }

  Widget _kv(String k, String v) {
    return SizedBox(
      width: 30.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            v,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NomAIColors.blackText,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            k,
            style: TextStyle(fontSize: 12, color: NomAIColors.grey),
          ),
        ],
      ),
    );
  }

  String _metricTitle(_Metric m) {
    switch (m) {
      case _Metric.calories:
        return 'Calories';
      case _Metric.protein:
        return 'Protein';
      case _Metric.carbs:
        return 'Carbs';
      case _Metric.fat:
        return 'Fat';
      case _Metric.water:
        return 'Water';
    }
  }

  String _metricLabel(_Metric m) {
    switch (m) {
      case _Metric.calories:
        return 'cal';
      case _Metric.protein:
        return 'g';
      case _Metric.carbs:
        return 'g';
      case _Metric.fat:
        return 'g';
      case _Metric.water:
        return 'ml';
    }
  }

  int _valueForMetric(DailyAnalytics d) {
    switch (_selectedMetric) {
      case _Metric.calories:
        return d.totalCalories;
      case _Metric.protein:
        return d.totalProtein;
      case _Metric.carbs:
        return d.totalCarbs;
      case _Metric.fat:
        return d.totalFat;
      case _Metric.water:
        return d.waterIntake;
    }
  }

  void _prevMonth() {
    final prev = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    _setMonth(prev);
  }

  void _nextMonth() {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    _setMonth(next);
  }

  void _setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    _expandedIndex = null;
    if (_userId != null) {
      setState(() {
        _future = serviceLocator<NutritionRecordRepo>()
            .getMonthlyAnalytics(_userId!, _selectedMonth);
      });
    } else {
      setState(() {});
    }
  }

  Widget _MonthButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.w),
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.w),
          border:
              Border.all(color: NomAIColors.blackText.withValues(alpha: 0.2)),
          color: NomAIColors.lightSurface,
        ),
        child: Icon(icon, size: 4.w, color: NomAIColors.blackText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NomAIColors.lightBackground,
      appBar: AppBar(
        backgroundColor: NomAIColors.blueGrey,
        elevation: 0,
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: NomAIColors.whiteText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: NomAIColors.whiteText),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NomAIColors.blueGrey,
              NomAIColors.blueGrey.withValues(alpha: 0.9),
              NomAIColors.blueGrey.withValues(alpha: 0.8),
              NomAIColors.blueGrey.withValues(alpha: 0.7),
              NomAIColors.blueGrey.withValues(alpha: 0.6),
              NomAIColors.blueGrey.withValues(alpha: 0.5),
              NomAIColors.blueGrey.withValues(alpha: 0.4),
              NomAIColors.blueGrey.withValues(alpha: 0.3),
              NomAIColors.blueGrey.withValues(alpha: 0.2),
              NomAIColors.blueGrey.withValues(alpha: 0.1),
              NomAIColors.whiteText,
            ],
            stops: const [
              0.0,
              0.1,
              0.2,
              0.3,
              0.4,
              0.5,
              0.6,
              0.7,
              0.8,
              0.9,
              1.0,
            ],
          ),
        ),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading || state is UserInitial) {
              return const _AnalyticsShimmerState();
            }
            if (state is UserLoaded) {
              _userId ??= state.userModel.userId;
              _future ??= serviceLocator<NutritionRecordRepo>()
                  .getMonthlyAnalytics(state.userModel.userId, _selectedMonth);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _buildMonthHeader(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: FutureBuilder<MonthlyAnalytics?>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _AnalyticsLoadingContent();
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Failed to load analytics',
                              style: TextStyle(color: NomAIColors.red),
                            ),
                          );
                        }
                        final data = snapshot.data;
                        if (data == null || data.dailyAnalytics.isEmpty) {
                          return _buildEmptyState();
                        }
                        return SingleChildScrollView(
                            child: _buildSummary(data));
                      },
                    ),
                  ),
                ],
              );
            }
            if (state is UserError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: NomAIColors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmptyIllustrations(
            removeHeightValue: true,
            title: "No records yet",
            message: "You haven't logged any meals in $monthLabel.",
            imagePath: "assets/svg/empty.svg",
            width: 50.w,
            height: 40.h,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 14.h),
        ],
      ),
    );
  }
}

class _AnalyticsLoadingContent extends StatelessWidget {
  const _AnalyticsLoadingContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ShimmerCard(height: 28.h, padding: EdgeInsets.all(4.w)),
          ),
          SizedBox(height: 1.5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ShimmerCard(height: 12.h, padding: EdgeInsets.all(4.w)),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ShimmerText(width: 36.w, height: 16),
          ),
          SizedBox(height: 1.h),
          ...List.generate(
            4,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
              child: ShimmerCard(height: 10.h),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 14.h),
        ],
      ),
    );
  }
}

class _AnalyticsShimmerState extends StatelessWidget {
  const _AnalyticsShimmerState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerCircle(size: 7.w),
                SizedBox(width: 2.w),
                Expanded(
                  child: Center(
                    child: ShimmerText(width: 28.w, height: 14),
                  ),
                ),
                SizedBox(width: 2.w),
                ShimmerCircle(size: 7.w),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.zero,
                  child: ShimmerChip(
                    width: index == 0 ? 24.w : 18.w,
                    height: 4.2.h,
                  ),
                ),
              ),
            ),
          ),
          const _AnalyticsLoadingContent(),
        ],
      ),
    );
  }
}

class _MetricCardData {
  final _Metric metric;
  final String label;
  final int value;
  final String unit;
  final Color color;

  const _MetricCardData({
    required this.metric,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
}

enum _Metric { calories, protein, carbs, fat, water }
