import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:NomAi/app/components/shimmer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/Diet/diet_output.dart';
import 'package:NomAi/app/modules/Diet/controller/diet_controller.dart';

class ChangeMealSheet extends StatefulWidget {
  final NutritionResponseModel currentMeal;
  final String mealType;

  const ChangeMealSheet({
    super.key,
    required this.currentMeal,
    required this.mealType,
  });

  @override
  State<ChangeMealSheet> createState() => _ChangeMealSheetState();
}

class _ChangeMealSheetState extends State<ChangeMealSheet> {
  final TextEditingController _promptController = TextEditingController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _sheetController.dispose();
    Get.find<DietController>().clearAlternatives();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
    _sheetController.animateTo(
      _isFullScreen ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _fetchAlternatives() async {
    final controller = Get.find<DietController>();
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      setState(
          () => _errorMessage = 'Please enter what you would like instead');
      return;
    }

    setState(() {
      _currentStep = 1;
      _isLoading = true;
      _errorMessage = null;
    });

    final alternatives = await controller.getAlternatives(
      currentMeal: widget.currentMeal,
      mealType: widget.mealType,
      prompt: prompt,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (alternatives != null && alternatives.isNotEmpty) {
        _currentStep = 2;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _sheetController.animateTo(
            0.92,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } else {
        _errorMessage = 'Could not get alternatives. Please try again.';
        _currentStep = 0;
      }
    });
  }

  Future<void> _updateMeal(NutritionResponseModel selectedMeal) async {
    setState(() => _isLoading = true);

    final controller = Get.find<DietController>();
    final success = await controller.updateMealInDiet(
      mealType: widget.mealType,
      newMeal: selectedMeal,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Meal updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: NomAIColors.black,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to update meal. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: NomAIColors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.5, 0.95],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              _buildHeader(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: KeyedSubtree(
                    key: ValueKey(_currentStep),
                    child: _buildCurrentStep(scrollController),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      onTap: _toggleFullScreen,
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -5 && !_isFullScreen) _toggleFullScreen();
        if (details.delta.dy > 5 && _isFullScreen) _toggleFullScreen();
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: NomAIColors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _getStepTitle(),
                    key: ValueKey(_currentStep),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: NomAIColors.black,
                    ),
                  ),
                ),
                Text(
                  'For ${widget.mealType}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: NomAIColors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            color: NomAIColors.black,
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Change ${widget.mealType}';
      case 1:
        return 'Finding Alternatives...';
      case 2:
        return 'Choose an Alternative';
      default:
        return 'Change ${widget.mealType}';
    }
  }

  Widget _buildCurrentStep(ScrollController scrollController) {
    switch (_currentStep) {
      case 0:
        return _buildPromptStep(scrollController);
      case 1:
        return _buildLoadingStep();
      case 2:
        return _buildAlternativesStep(scrollController);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Step 0: Prompt ───────────────────────────────────────────────────────

  Widget _buildPromptStep(ScrollController scrollController) {
    // Align to top so content doesn't float to center when sheet is fullscreen.
    // The SingleChildScrollView handles overflow when content is taller than
    // the available space (e.g. keyboard open).
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current meal banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NomAIColors.greyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.restaurant, color: NomAIColors.black, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current ${widget.mealType}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: NomAIColors.black.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.currentMeal.foodName ?? 'Unknown',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: NomAIColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'What would you like instead?',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: NomAIColors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your preference to get 5 alternative suggestions',
              style: context.textTheme.bodyMedium?.copyWith(
                color: NomAIColors.black.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _promptController,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText:
                    'e.g., "Something lighter", "More protein", "Bengali fish dish"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: NomAIColors.black.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: NomAIColors.black),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _fetchAlternatives,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NomAIColors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Get 5 Alternatives',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NomAIColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: NomAIColors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(color: NomAIColors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Step 1: Loading with shimmer ─────────────────────────────────────────

  Widget _buildLoadingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Finding perfect alternatives...',
          //   style: context.textTheme.titleMedium?.copyWith(
          //     fontWeight: FontWeight.bold,
          //     color: NomAIColors.black,
          //   ),
          // ),
          // const SizedBox(height: 8),
          // Text(
          //   'Our AI is generating 5 meal options for you',
          //   style: context.textTheme.bodyMedium?.copyWith(
          //     color: NomAIColors.black.withOpacity(0.6),
          //   ),
          // ),
          // const SizedBox(height: 24),
          ...List.generate(5, (index) => const ShimmerMealCard()),
        ],
      ),
    );
  }

  // ─── Step 2: Alternatives list ────────────────────────────────────────────

  Widget _buildAlternativesStep(ScrollController scrollController) {
    final controller = Get.find<DietController>();

    // Obx wraps the entire step so any change to selectedAlternative
    // triggers a rebuild — this is what makes tapping a card actually
    // update the highlight and enable the Accept button.
    return Obx(() {
      final selectedName = controller.selectedAlternative.value?.foodName;

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              itemCount: controller.alternatives.length,
              itemBuilder: (context, index) {
                final meal = controller.alternatives[index];
                final isSelected = selectedName == meal.foodName;

                return GestureDetector(
                  onTap: () => controller.selectAlternative(meal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? NomAIColors.black
                          : NomAIColors.greyLight,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: NomAIColors.black, width: 2)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                meal.foodName ?? 'Unknown',
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : NomAIColors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : NomAIColors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.amber
                                        : NomAIColors.black,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${meal.overallHealthScore ?? 0}/10',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : NomAIColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (meal.overallHealthComments != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            meal.overallHealthComments!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : NomAIColors.black.withOpacity(0.6),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildMiniNutrient(
                              'Cal',
                              '${_calcTotal(meal, (i) => i.calories)}',
                              isSelected,
                            ),
                            const SizedBox(width: 8),
                            _buildMiniNutrient(
                              'P',
                              '${_calcTotal(meal, (i) => i.protein)}g',
                              isSelected,
                            ),
                            const SizedBox(width: 8),
                            _buildMiniNutrient(
                              'C',
                              '${_calcTotal(meal, (i) => i.carbs)}g',
                              isSelected,
                            ),
                            const SizedBox(width: 8),
                            _buildMiniNutrient(
                              'F',
                              '${_calcTotal(meal, (i) => i.fat)}g',
                              isSelected,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Pinned action bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: NomAIColors.black.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _currentStep = 0);
                      controller.clearAlternatives();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NomAIColors.black,
                      side: BorderSide(color: NomAIColors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    // selectedAlternative.value is read inside Obx, so this
                    // correctly becomes non-null the moment the user taps a card.
                    onPressed: selectedName != null && !_isLoading
                        ? () =>
                            _updateMeal(controller.selectedAlternative.value!)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NomAIColors.black,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          NomAIColors.black.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Accept & Update',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMiniNutrient(String label, String value, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withOpacity(0.1)
            : NomAIColors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: context.textTheme.bodySmall?.copyWith(
          color: isSelected ? Colors.white : NomAIColors.black.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  int _calcTotal(NutritionResponseModel meal, int? Function(dynamic) getter) {
    if (meal.ingredients == null) return 0;
    return meal.ingredients!.fold(0, (sum, i) => sum + (getter(i) ?? 0));
  }
}
