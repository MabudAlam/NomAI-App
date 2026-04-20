import 'package:flutter/material.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/Chat/ChatPostModel.dart';
import 'package:NomAi/app/components/buttons.dart';

class NutritionAnalysisCard extends StatefulWidget {
  final ResponseData response;
  final VoidCallback? onAddToLog;
  final bool isAlreadyAdded;

  const NutritionAnalysisCard({
    super.key,
    required this.response,
    this.onAddToLog,
    this.isAlreadyAdded = false,
  });

  @override
  State<NutritionAnalysisCard> createState() => _NutritionAnalysisCardState();
}

class _NutritionAnalysisCardState extends State<NutritionAnalysisCard> {
  bool _isExpanded = false;

  int get _totalCalories {
    if (widget.response.ingredients == null) return 0;
    return widget.response.ingredients!
        .fold(0, (sum, i) => sum + (i.calories ?? 0));
  }

  int get _totalProtein {
    if (widget.response.ingredients == null) return 0;
    return widget.response.ingredients!
        .fold(0, (sum, i) => sum + (i.protein ?? 0));
  }

  int get _totalCarbs {
    if (widget.response.ingredients == null) return 0;
    return widget.response.ingredients!
        .fold(0, (sum, i) => sum + (i.carbs ?? 0));
  }

  int get _totalFat {
    if (widget.response.ingredients == null) return 0;
    return widget.response.ingredients!.fold(0, (sum, i) => sum + (i.fat ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: NomAIColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: NomAIColors.blackText.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: NomAIColors.blueGrey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: NomAIColors.blueGrey,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.response.foodName ?? 'Food Analysis',
                              style: TextStyle(
                                color: NomAIColors.blackText,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (widget.response.portionSize != null)
                              Text(
                                '${widget.response.portionSize?.toInt()}g',
                                style: TextStyle(
                                  color: NomAIColors.blackText,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.response.overallHealthScore != null)
                        _HealthScoreBadge(
                            score: widget.response.overallHealthScore!),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: NomAIColors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _CompactNutritionRow(
                    calories: _totalCalories,
                    protein: _totalProtein,
                    carbs: _totalCarbs,
                    fat: _totalFat,
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              Divider(
                  height: 1,
                  color: NomAIColors.blackText.withValues(alpha: 0.08)),
              _ExpandedContent(
                response: widget.response,
                onAddToLog: widget.onAddToLog,
                isAlreadyAdded: widget.isAlreadyAdded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompactNutritionRow extends StatelessWidget {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const _CompactNutritionRow({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CompactNutrient(
            label: 'Cal',
            value: calories,
            color: NomAIColors.blueGrey,
            icon: Icons.local_fire_department_rounded),
        const SizedBox(width: 16),
        _CompactNutrient(
            label: 'P',
            value: protein,
            color: NomAIColors.proteinColor,
            icon: Icons.fitness_center_rounded),
        const SizedBox(width: 16),
        _CompactNutrient(
            label: 'C',
            value: carbs,
            color: NomAIColors.carbsColor,
            icon: Icons.grain_rounded),
        const SizedBox(width: 16),
        _CompactNutrient(
            label: 'F',
            value: fat,
            color: NomAIColors.fatColor,
            icon: Icons.opacity_rounded),
      ],
    );
  }
}

class _CompactNutrient extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _CompactNutrient({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            color: NomAIColors.blackText,
            fontSize: 12,
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            color: NomAIColors.blackText,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _HealthScoreBadge extends StatelessWidget {
  final int score;

  const _HealthScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (score >= 7) {
      color = NomAIColors.darkSuccess;
    } else if (score >= 4) {
      color = NomAIColors.darkWarning;
    } else {
      color = NomAIColors.darkError;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$score/10',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final ResponseData response;
  final VoidCallback? onAddToLog;
  final bool isAlreadyAdded;

  const _ExpandedContent({
    required this.response,
    this.onAddToLog,
    this.isAlreadyAdded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (response.overallHealthComments != null) ...[
            Text(
              response.overallHealthComments!,
              style: TextStyle(
                color: NomAIColors.blackText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (response.ingredients != null &&
              response.ingredients!.isNotEmpty) ...[
            _SectionTitle(title: 'Ingredients', icon: Icons.list_alt),
            const SizedBox(height: 8),
            Column(
              children: response.ingredients!
                  .map((i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _IngredientDetailCard(ingredient: i),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          if (response.primaryConcerns != null &&
              response.primaryConcerns!.isNotEmpty) ...[
            _SectionTitle(
                title: 'Concerns',
                icon: Icons.warning_amber,
                color: NomAIColors.darkError),
            const SizedBox(height: 8),
            ...response.primaryConcerns!.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ConcernItem(concern: c),
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (response.suggestAlternatives != null &&
              response.suggestAlternatives!.isNotEmpty) ...[
            _SectionTitle(
              title: 'Better Alternatives',
              icon: Icons.swap_horiz,
              color: NomAIColors.lightSuccess,
            ),
            const SizedBox(height: 8),
            ...response.suggestAlternatives!.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AlternativeItem(alternative: a),
              ),
            ),
          ],
          _AddButton(
            response: response,
            onAddToLog: onAddToLog,
            isAlreadyAdded: isAlreadyAdded,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const _SectionTitle({required this.title, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? NomAIColors.blackText;
    return Row(
      children: [
        Icon(icon, color: c, size: 16),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: c,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _IngredientDetailCard extends StatelessWidget {
  final Ingredient ingredient;

  const _IngredientDetailCard({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NomAIColors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: NomAIColors.blackText.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ingredient.name ?? '',
                  style: TextStyle(
                    color: NomAIColors.blackText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (ingredient.healthScore != null)
                _MiniHealthScore(score: ingredient.healthScore!),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MiniNutrient(
                  label: 'Cal',
                  value: ingredient.calories ?? 0,
                  color: NomAIColors.blueGrey,
                  icon: Icons.local_fire_department_rounded),
              const SizedBox(width: 12),
              _MiniNutrient(
                  label: 'P',
                  value: ingredient.protein ?? 0,
                  color: NomAIColors.proteinColor,
                  icon: Icons.fitness_center_rounded),
              const SizedBox(width: 12),
              _MiniNutrient(
                  label: 'C',
                  value: ingredient.carbs ?? 0,
                  color: NomAIColors.carbsColor,
                  icon: Icons.grain_rounded),
              const SizedBox(width: 12),
              _MiniNutrient(
                  label: 'F',
                  value: ingredient.fat ?? 0,
                  color: NomAIColors.fatColor,
                  icon: Icons.opacity_rounded),
            ],
          ),
          if (ingredient.healthComments != null &&
              ingredient.healthComments!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              ingredient.healthComments!,
              style: TextStyle(
                color: NomAIColors.blackText,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniNutrient extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _MiniNutrient({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 11),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            color: NomAIColors.blackText,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MiniHealthScore extends StatelessWidget {
  final int score;

  const _MiniHealthScore({required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (score >= 7) {
      color = NomAIColors.darkSuccess;
    } else if (score >= 4) {
      color = NomAIColors.darkWarning;
    } else {
      color = NomAIColors.darkError;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$score/10',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ConcernItem extends StatelessWidget {
  final PrimaryConcern concern;

  const _ConcernItem({required this.concern});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NomAIColors.blackText.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: NomAIColors.blackText, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  concern.issue ?? '',
                  style: TextStyle(
                    color: NomAIColors.blackText,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (concern.recommendations != null &&
              concern.recommendations!.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...concern.recommendations!.map(
              (r) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right,
                        color: NomAIColors.blackText, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        r.food ?? '',
                        style: TextStyle(
                          color: NomAIColors.blackText,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlternativeItem extends StatelessWidget {
  final SuggestAlternative alternative;

  const _AlternativeItem({required this.alternative});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NomAIColors.blackText.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alternative.name ?? '',
                  style: TextStyle(
                    color: NomAIColors.blackText,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MiniNutrient(
                        label: 'Cal',
                        value: alternative.calories ?? 0,
                        color: NomAIColors.blueGrey,
                        icon: Icons.local_fire_department_rounded),
                    const SizedBox(width: 10),
                    _MiniNutrient(
                        label: 'P',
                        value: alternative.protein ?? 0,
                        color: NomAIColors.proteinColor,
                        icon: Icons.fitness_center_rounded),
                    const SizedBox(width: 10),
                    _MiniNutrient(
                        label: 'C',
                        value: alternative.carbs ?? 0,
                        color: NomAIColors.carbsColor,
                        icon: Icons.grain_rounded),
                    const SizedBox(width: 10),
                    _MiniNutrient(
                        label: 'F',
                        value: alternative.fat ?? 0,
                        color: NomAIColors.fatColor,
                        icon: Icons.opacity_rounded),
                  ],
                ),
              ],
            ),
          ),
          if (alternative.healthScore != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: NomAIColors.blueGrey,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${alternative.healthScore}',
                style: const TextStyle(
                  color: NomAIColors.whiteText,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final ResponseData response;
  final VoidCallback? onAddToLog;
  final bool isAlreadyAdded;

  const _AddButton({
    required this.response,
    this.onAddToLog,
    this.isAlreadyAdded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = onAddToLog == null && !isAlreadyAdded;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: isAlreadyAdded
          ? DisabledButton(
              tile: 'Added to Daily Log',
              icon: Icons.check_circle_rounded,
            )
          : PrimaryButton(
              tile: isLoading ? 'Adding...' : 'Add to Daily Log',
              onPressed: isLoading ? () {} : onAddToLog!,
            ),
    );
  }
}
