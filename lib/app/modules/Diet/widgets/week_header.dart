import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/Diet/diet_output.dart';

class WeekHeader extends StatelessWidget {
  final String weekStartDate;
  final String weekEndDate;
  final NutritionSummary? nutrition;

  const WeekHeader({
    super.key,
    required this.weekStartDate,
    required this.weekEndDate,
    this.nutrition,
  });

  String _normalizeDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = _getMonth(int.parse(parts[1]));
        final day = int.parse(parts[2]);
        return '${_getOrdinal(day)} $month $year';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _getOrdinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDateChip(context, _normalizeDate(weekStartDate)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: NomAIColors.black,
            size: 20.sp,
          ),
        ),
        _buildDateChip(context, _normalizeDate(weekEndDate)),
      ],
    );
  }

  Widget _buildDateChip(BuildContext context, String date) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: NomAIColors.black,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: Colors.white,
            size: 14.sp,
          ),
          SizedBox(width: 1.5.w),
          Text(
            date,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(BuildContext context, NutritionSummary nutrition) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: NomAIColors.greyLight,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(context, 'Calories', '${nutrition.calories ?? 0}'),
          _buildSummaryItem(context, 'Protein', '${nutrition.protein ?? 0}g'),
          _buildSummaryItem(context, 'Carbs', '${nutrition.carbs ?? 0}g'),
          _buildSummaryItem(context, 'Fat', '${nutrition.fat ?? 0}g'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: NomAIColors.black,
              ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: NomAIColors.black.withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}
