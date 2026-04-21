import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/Diet/diet_output.dart';
import 'package:NomAi/app/modules/Diet/controller/diet_controller.dart';
import 'package:NomAi/app/modules/Diet/widgets/widgets.dart';

class DietHistoryPage extends StatefulWidget {
  const DietHistoryPage({super.key});

  @override
  State<DietHistoryPage> createState() => _DietHistoryPageState();
}

class _DietHistoryPageState extends State<DietHistoryPage> {
  final DietController _controller = Get.find<DietController>();
  WeeklyDietOutput? _selectedDiet;
  bool _isViewingDiet = false;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _controller.loadDietHistory();
  }

  void _viewDiet(WeeklyDietOutput diet) {
    setState(() {
      _selectedDiet = diet;
      _isViewingDiet = true;
    });
  }

  void _closeDietView() {
    setState(() {
      _selectedDiet = null;
      _isViewingDiet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_isViewingDiet ? Icons.arrow_back : Icons.arrow_back),
          color: NomAIColors.black,
          onPressed: _isViewingDiet ? _closeDietView : () => Get.back(),
        ),
        title: Text(
          _isViewingDiet ? 'Diet Details' : 'Past Diet Plans',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: NomAIColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isViewingDiet && _selectedDiet != null
          ? _buildDietDetailView(_selectedDiet!)
          : _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    return Obx(() {
      if (_controller.isLoadingHistory.value) {
        return _buildLoadingShimmer();
      }

      if (_controller.dietHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: NomAIColors.black.withOpacity(0.3),
              ),
              SizedBox(height: 16),
              Text(
                'No past diet plans',
                style: context.textTheme.titleMedium?.copyWith(
                  color: NomAIColors.black.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your completed diet plans will appear here',
                style: context.textTheme.bodySmall?.copyWith(
                  color: NomAIColors.black.withOpacity(0.4),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _controller.dietHistory.length,
        itemBuilder: (context, index) {
          final diet = _controller.dietHistory[index];
          return _buildDietHistoryCard(diet);
        },
      );
    });
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NomAIColors.greyLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 18,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDietHistoryCard(WeeklyDietOutput diet) {
    final isCompleted = diet.status == 'completed';
    final isModified = diet.status == 'modified';

    return GestureDetector(
      onTap: () => _viewDiet(diet),
      child: Container(
        margin: EdgeInsets.only(bottom: 3.w),
        decoration: BoxDecoration(
          color: NomAIColors.greyLight,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(
            color: NomAIColors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: NomAIColors.black,
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${diet.weekStartDate ?? ""} - ${diet.weekEndDate ?? ""}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: NomAIColors.black,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '7 Day Diet Plan',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: NomAIColors.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? NomAIColors.lightSuccess.withValues(alpha: 0.15)
                              : isModified
                                  ? Colors.orange.withValues(alpha: 0.15)
                                  : NomAIColors.black.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Text(
                          diet.status?.toUpperCase() ?? 'UNKNOWN',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? NomAIColors.lightSuccess
                                : isModified
                                    ? Colors.orange
                                    : NomAIColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // if (diet.totalWeeklyNutrition != null)
            //   Container(
            //     padding:
            //         EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 2.5.w),
            //     decoration: BoxDecoration(
            //       color: NomAIColors.whiteText,
            //       borderRadius: BorderRadius.only(
            //         bottomLeft: Radius.circular(4.w),
            //         bottomRight: Radius.circular(4.w),
            //       ),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceAround,
            //       children: [
            //         _buildMacroChip(
            //           'Cal',
            //           '${diet.totalWeeklyNutrition!.calories ?? 0}',
            //           Icons.local_fire_department_rounded,
            //           NomAIColors.black,
            //         ),
            //         _buildMacroChip(
            //           'P',
            //           '${diet.totalWeeklyNutrition!.protein ?? 0}g',
            //           Icons.fitness_center_rounded,
            //           NomAIColors.proteinColor,
            //         ),
            //         _buildMacroChip(
            //           'C',
            //           '${diet.totalWeeklyNutrition!.carbs ?? 0}g',
            //           Icons.grain_rounded,
            //           NomAIColors.carbsColor,
            //         ),
            //         _buildMacroChip(
            //           'F',
            //           '${diet.totalWeeklyNutrition!.fat ?? 0}g',
            //           Icons.opacity_rounded,
            //           NomAIColors.fatColor,
            //         ),
            //       ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.5.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 1.5.w),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietDetailView(WeeklyDietOutput diet) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: WeekHeader(
            weekStartDate: diet.weekStartDate ?? '',
            weekEndDate: diet.weekEndDate ?? '',
            nutrition: diet.totalWeeklyNutrition,
          ),
        ),
        SizedBox(height: 1.5.h),
        _buildDaySelectorForDiet(diet),
        Expanded(
          child: _buildDayMealsForDiet(diet),
        ),
        _buildCopyButton(diet),
      ],
    );
  }

  Widget _buildDaySelectorForDiet(WeeklyDietOutput diet) {
    final days = diet.dailyDiets ?? [];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _selectedDayIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? NomAIColors.black : NomAIColors.greyLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                day.dayName ?? '',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : NomAIColors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayMealsForDiet(WeeklyDietOutput diet) {
    final days = diet.dailyDiets ?? [];
    if (days.isEmpty) return const SizedBox.shrink();

    final selectedIndex = _selectedDayIndex.clamp(0, days.length - 1);
    final day = days[selectedIndex];

    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        if (day.totalNutrition != null)
          DayNutritionSummary(nutrition: day.totalNutrition!),
        SizedBox(height: 2.h),
        if (day.meals?.breakfast != null)
          MealCard(
              title: 'Breakfast',
              meal: day.meals!.breakfast!,
              icon: Icons.wb_sunny),
        if (day.meals?.lunch != null)
          MealCard(
              title: 'Lunch', meal: day.meals!.lunch!, icon: Icons.wb_cloudy),
        if (day.meals?.dinner != null)
          MealCard(
              title: 'Dinner',
              meal: day.meals!.dinner!,
              icon: Icons.nightlight),
        if (day.meals?.snacks != null && day.meals!.snacks!.isNotEmpty)
          ...day.meals!.snacks!.map((snack) => MealCard(
              title: 'Snack', meal: snack, icon: Icons.cookie_outlined)),
        if (day.cheatMealOfTheDay != null)
          MealCard(
              title: 'Cheat Meal',
              meal: day.cheatMealOfTheDay!,
              icon: Icons.local_fire_department),
      ],
    );
  }

  Widget _buildCopyButton(WeeklyDietOutput diet) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _controller.isCopyingDiet.value
                  ? null
                  : () => _copyDiet(diet),
              style: ElevatedButton.styleFrom(
                backgroundColor: NomAIColors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _controller.isCopyingDiet.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Copy This Diet Plan',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          )),
    );
  }

  void _copyDiet(WeeklyDietOutput diet) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Copy Diet'),
        content: Text(
          'Copy "${diet.weekStartDate} - ${diet.weekEndDate}" as your new active diet?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Copy'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _controller.copyPastDiet(diet.id ?? '');
      if (success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Diet plan copied successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: NomAIColors.black,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to copy diet plan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: NomAIColors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
