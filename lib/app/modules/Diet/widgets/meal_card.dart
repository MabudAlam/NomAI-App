import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/components/buttons.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/Diet/diet_output.dart';

class MealCard extends StatefulWidget {
  final String title;
  final NutritionResponseModel meal;
  final IconData icon;
  final VoidCallback? onChange;
  final VoidCallback? onAddToLog;

  const MealCard({
    super.key,
    required this.title,
    required this.meal,
    required this.icon,
    this.onChange,
    this.onAddToLog,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool _isAddingToLog = false;

  Future<void> _handleAddToLog() async {
    if (_isAddingToLog || widget.onAddToLog == null) return;

    setState(() => _isAddingToLog = true);
    try {
      widget.onAddToLog!();
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _isAddingToLog = false);
    }
  }

  int get _totalCalories =>
      widget.meal.ingredients
          ?.fold<int>(0, (sum, ing) => sum + (ing.calories ?? 0)) ??
      0;

  int get _totalProtein =>
      widget.meal.ingredients
          ?.fold<int>(0, (sum, ing) => sum + (ing.protein ?? 0)) ??
      0;

  int get _totalCarbs =>
      widget.meal.ingredients
          ?.fold<int>(0, (sum, ing) => sum + (ing.carbs ?? 0)) ??
      0;

  int get _totalFat =>
      widget.meal.ingredients
          ?.fold<int>(0, (sum, ing) => sum + (ing.fat ?? 0)) ??
      0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: NomAIColors.greyLight,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: NomAIColors.black, size: 20),
              SizedBox(width: 2.w),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: NomAIColors.black,
                    ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: NomAIColors.black,
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Text(
                  '${widget.meal.overallHealthScore ?? 0}/10',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            widget.meal.foodName ?? 'Unknown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: NomAIColors.black,
                ),
          ),
          if (widget.meal.overallHealthComments != null) ...[
            SizedBox(height: 1.h),
            Text(
              widget.meal.overallHealthComments!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: NomAIColors.black.withValues(alpha: 0.7),
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: NomAIColors.whiteText,
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTotalNutrient('Cal', _totalCalories, NomAIColors.black,
                    Icons.local_fire_department_rounded),
                _buildDivider(),
                _buildTotalNutrient('P', _totalProtein,
                    NomAIColors.proteinColor, Icons.fitness_center_rounded),
                _buildDivider(),
                _buildTotalNutrient('C', _totalCarbs, NomAIColors.carbsColor,
                    Icons.grain_rounded),
                _buildDivider(),
                _buildTotalNutrient('F', _totalFat, NomAIColors.fatColor,
                    Icons.opacity_rounded),
              ],
            ),
          ),
          if (widget.meal.ingredients != null &&
              widget.meal.ingredients!.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            ...widget.meal.ingredients!.map((ing) => Container(
                  margin: EdgeInsets.only(bottom: 0.8.h),
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 2.w,
                            height: 2.w,
                            decoration: BoxDecoration(
                              color: NomAIColors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.5.w),
                          Expanded(
                            child: Text(
                              ing.name ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: NomAIColors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.8.h),
                      Row(
                        children: [
                          _buildMacroLarge(
                              'Cal',
                              ing.calories ?? 0,
                              NomAIColors.blackText,
                              Icons.local_fire_department_rounded),
                          SizedBox(width: 1.5.w),
                          _buildMacroLarge(
                              'P',
                              ing.protein ?? 0,
                              NomAIColors.proteinColor,
                              Icons.fitness_center_rounded),
                          SizedBox(width: 1.5.w),
                          _buildMacroLarge('C', ing.carbs ?? 0,
                              NomAIColors.carbsColor, Icons.grain_rounded),
                          SizedBox(width: 1.5.w),
                          _buildMacroLarge('F', ing.fat ?? 0,
                              NomAIColors.fatColor, Icons.opacity_rounded),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
          if (widget.onChange != null || widget.onAddToLog != null) ...[
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.onAddToLog != null)
                  widget.meal.isEaten == true
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: NomAIColors.darkSuccess.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  color: NomAIColors.darkSuccess, size: 2.w),
                              SizedBox(width: 1.w),
                              Text(
                                'Eaten',
                                style: TextStyle(
                                  color: NomAIColors.darkSuccess,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        )
                      : PrimaryButtonWithIcon(
                          tile: 'Add',
                          icon: Icons.add,
                          onPressed: _handleAddToLog,
                          isLoading: _isAddingToLog,
                        ),
                if (widget.onChange != null) ...[
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: widget.onChange,
                    icon: Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Change'),
                    style: TextButton.styleFrom(
                      foregroundColor: NomAIColors.black,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalNutrient(
      String label, int value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(width: 0.5.w),
            Text(
              '$label',
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
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 3.h,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildMacroLarge(String label, int value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 0.5.w),
          Text(
            '$label:$value',
            style: TextStyle(
              fontSize: 14.sp,
              color: NomAIColors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
