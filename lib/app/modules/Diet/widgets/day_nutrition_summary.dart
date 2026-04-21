import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/Diet/diet_output.dart';

class DayNutritionSummary extends StatelessWidget {
  final NutritionSummary nutrition;

  const DayNutritionSummary({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: NomAIColors.greyLight,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMacroBadge('Cal', nutrition.calories ?? 0, NomAIColors.blueGrey,
              Icons.local_fire_department_rounded),
          _buildMacroBadge('P', nutrition.protein ?? 0,
              NomAIColors.proteinColor, Icons.fitness_center_rounded),
          _buildMacroBadge('C', nutrition.carbs ?? 0, NomAIColors.carbsColor,
              Icons.grain_rounded),
          _buildMacroBadge('F', nutrition.fat ?? 0, NomAIColors.fatColor,
              Icons.opacity_rounded),
        ],
      ),
    );
  }

  Widget _buildMacroBadge(String label, int value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.8.h),
      // decoration: BoxDecoration(
      //   color: color.withValues(alpha: 0.2),
      //   borderRadius: BorderRadius.circular(2.5.w),
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20.sp, color: color),
              SizedBox(width: 0.5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.3.h),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 14.sp,
              color: NomAIColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
