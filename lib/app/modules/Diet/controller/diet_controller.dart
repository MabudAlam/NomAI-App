import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/constants/enums.dart';
import 'package:NomAi/app/models/AI/nutrition_input.dart';
import 'package:NomAi/app/models/AI/nutrition_output.dart';
import 'package:NomAi/app/models/AI/nutrition_record.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/models/Diet/diet_input.dart';
import 'package:NomAi/app/models/Diet/diet_output.dart';
import 'package:NomAi/app/modules/Scanner/controller/scanner_controller.dart';
import 'package:NomAi/app/modules/Scanner/views/scan_view.dart';
import 'package:NomAi/app/repo/diet_repo.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:NomAi/app/utility/registry_service.dart';

class DietController extends GetxController {
  final DietRepo _dietRepo = DietRepo();

  final Rx<WeeklyDietOutput?> weeklyDiet = Rx<WeeklyDietOutput?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isSuggestingAlternatives = false.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool isCopyingDiet = false.obs;
  final RxInt selectedDayIndex = 0.obs;
  final RxList<NutritionResponseModel> alternatives = <NutritionResponseModel>[].obs;
  final Rx<NutritionResponseModel?> selectedAlternative = Rx<NutritionResponseModel?>(null);
  final RxList<WeeklyDietOutput> dietHistory = <WeeklyDietOutput>[].obs;

  UserModel? _userModel;

  String get userId => _userModel?.userId ?? '';

  int get calories => _userModel?.userInfo?.userMacros.calories ?? 2000;
  int get protein => _userModel?.userInfo?.userMacros.protein ?? 120;
  int get carbs => _userModel?.userInfo?.userMacros.carbs ?? 200;
  int get fat => _userModel?.userInfo?.userMacros.fat ?? 65;
  int get fiber => _userModel?.userInfo?.userMacros.fiber ?? 30;

  List<String>? get dietaryPreferences =>
      _userModel?.userInfo?.selectedDiet != null
          ? [_userModel!.userInfo!.selectedDiet]
          : null;

  List<String>? get allergies => _userModel?.userInfo?.selectedAllergies;

  List<String>? get selectedGoals =>
      [_userModel?.userInfo?.selectedGoal.name ?? 'weight-loss'];

  void setUserModel(UserModel userModel) {
    _userModel = userModel;
    loadActiveDiet();
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadActiveDiet() async {
    if (userId.isEmpty) return;
    isLoading.value = true;
    try {
      final diet = await _dietRepo.getActiveDiet(userId);
      weeklyDiet.value = diet;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createWeeklyDiet({
    int? calories,
    int? protein,
    int? carbs,
    int? fiber,
    int? fat,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    List<String>? selectedGoals,
    List<String>? dislikedFoods,
    List<String>? anyDiseases,
    String? prompt,
  }) async {
    isCreating.value = true;
    try {
      debugPrint('DietController: Creating weekly diet');
      debugPrint('DietController: userId=$userId, calories=$calories, protein=$protein, carbs=$carbs, fat=$fat, fiber=$fiber');
      debugPrint('DietController: dietaryPreferences=$dietaryPreferences, allergies=$allergies, selectedGoals=$selectedGoals');

      final input = DietInput(
        userId: userId,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        carbs: carbs ?? this.carbs,
        fiber: fiber ?? this.fiber,
        fat: fat ?? this.fat,
        dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
        allergies: allergies ?? this.allergies,
        selectedGoals: selectedGoals ?? this.selectedGoals,
        dislikedFoods: dislikedFoods,
        anyDiseases: anyDiseases,
        prompt: prompt ?? '',
      );

      final diet = await _dietRepo.createWeeklyDiet(input);
      debugPrint('DietController: Diet result: ${diet != null ? "success" : "failed (null)"}');

      if (diet != null) {
        weeklyDiet.value = diet;
        return true;
      }
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  Future<List<NutritionResponseModel>?> getAlternatives({
    required NutritionResponseModel currentMeal,
    required String mealType,
    required String prompt,
  }) async {
    if (userId.isEmpty) return null;

    isSuggestingAlternatives.value = true;
    alternatives.clear();
    selectedAlternative.value = null;
    try {
      debugPrint('DietController: Getting 5 alternatives for $mealType with prompt: $prompt');

      final response = await _dietRepo.suggestAlternatives(
        userId: userId,
        currentMeal: currentMeal,
        mealType: mealType,
        prompt: prompt,
        dietaryPreferences: dietaryPreferences,
        allergies: allergies,
        selectedGoals: selectedGoals,
      );

      if (response?.alternatives != null) {
        alternatives.addAll(response!.alternatives!);
        debugPrint('DietController: Got ${alternatives.length} alternatives');
        return alternatives;
      }
      return null;
    } finally {
      isSuggestingAlternatives.value = false;
    }
  }

  void selectAlternative(NutritionResponseModel meal) {
    selectedAlternative.value = meal;
  }

  Future<bool> updateMealInDiet({
    required String mealType,
    required NutritionResponseModel newMeal,
  }) async {
    if (userId.isEmpty) return false;

    final dayIndex = selectedDayIndex.value;
    debugPrint('DietController: Updating $mealType on day $dayIndex');

    final success = await _dietRepo.updateMeal(
      userId: userId,
      dayIndex: dayIndex,
      mealType: mealType,
      meal: newMeal,
    );

    if (success) {
      debugPrint('DietController: Meal updated successfully, reloading diet');
      await loadActiveDiet();
    }

    alternatives.clear();
    selectedAlternative.value = null;
    return success;
  }

  void clearAlternatives() {
    alternatives.clear();
    selectedAlternative.value = null;
  }

  void selectDay(int index) {
    selectedDayIndex.value = index;
  }

  DailyDietEntry? get selectedDay {
    if (weeklyDiet.value?.dailyDiets == null) return null;
    if (selectedDayIndex.value >= weeklyDiet.value!.dailyDiets!.length) {
      return null;
    }
    return weeklyDiet.value!.dailyDiets![selectedDayIndex.value];
  }

  NutritionSummary? get totalWeeklyNutrition => weeklyDiet.value?.totalWeeklyNutrition;

  bool get hasActiveDiet => weeklyDiet.value != null;

  bool get isDietExpired {
    if (weeklyDiet.value?.weekEndDate == null) return true;
    final endDate = DateTime.tryParse(weeklyDiet.value!.weekEndDate!);
    if (endDate == null) return true;
    return endDate.isBefore(DateTime.now());
  }

  String? get weekStartDate => weeklyDiet.value?.weekStartDate;
  String? get weekEndDate => weeklyDiet.value?.weekEndDate;
  String get dietStatusText {
    if (weeklyDiet.value == null) return 'No diet plan';
    if (isDietExpired) {
      return 'Plan ended on ${weekEndDate ?? "unknown"}';
    }
    return '${weekStartDate ?? ""} - ${weekEndDate ?? ""}';
  }

  Future<void> loadDietHistory() async {
    if (userId.isEmpty) return;
    isLoadingHistory.value = true;
    try {
      final history = await _dietRepo.getDietHistory(userId);
      if (history?.diets != null) {
        dietHistory.assignAll(history!.diets!);
        debugPrint('DietController: Loaded ${dietHistory.length} past diets');
      }
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<bool> copyPastDiet(String dietId) async {
    if (userId.isEmpty) return false;
    isCopyingDiet.value = true;
    try {
      debugPrint('DietController: Copying diet $dietId');
      final copiedDiet = await _dietRepo.copyDiet(
        userId: userId,
        dietId: dietId,
      );
      if (copiedDiet != null) {
        weeklyDiet.value = copiedDiet;
        await loadDietHistory();
        return true;
      }
      return false;
    } finally {
      isCopyingDiet.value = false;
    }
  }

  Future<bool> markMealAsEaten({
    required int dayIndex,
    required String mealType,
    required NutritionResponseModel meal,
  }) async {
    if (userId.isEmpty) return false;

    try {
      debugPrint('DietController: Marking $mealType on day $dayIndex as eaten');

      final updatedMeal = meal.copyWith(isEaten: true);

      final success = await _dietRepo.updateMeal(
        userId: userId,
        dayIndex: dayIndex,
        mealType: mealType,
        meal: updatedMeal,
      );

      if (success) {
        _updateMealLocally(dayIndex, mealType, updatedMeal);
        await _addMealToLog(meal);
        debugPrint('DietController: Meal marked as eaten and added to log');
        Get.snackbar(
          'Added to Log',
          'Meal has been marked as eaten and added to your daily log.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: NomAIColors.black,
          colorText: NomAIColors.whiteText,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to mark meal as eaten.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: NomAIColors.darkError,
          colorText: NomAIColors.whiteText,
        );
      }

      return success;
    } catch (e) {
      debugPrint('DietController: ERROR marking meal as eaten: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: NomAIColors.darkError,
        colorText: NomAIColors.whiteText,
      );
      return false;
    }
  }

  Future<void> _addMealToLog(NutritionResponseModel meal) async {
    if (userId.isEmpty) return;

    try {
      final ingredients = meal.ingredients
          ?.map((ing) => Ingredient(
                name: ing.name,
                calories: ing.calories,
                protein: ing.protein,
                carbs: ing.carbs,
                fiber: ing.fiber,
                fat: ing.fat,
                sugar: null,
                sodium: null,
                healthScore: ing.healthScore,
                healthComments: ing.healthComments,
              ))
          .toList();

      final nutritionOutput = NutritionOutput(
        status: 200,
        response: NutritionResponse(
          foodName: meal.foodName,
          portion: meal.portion,
          portionSize: meal.portionSize,
          overallHealthScore: meal.overallHealthScore,
          overallHealthComments: meal.overallHealthComments,
          ingredients: ingredients,
        ),
      );

      final nutritionRecord = NutritionRecord(
        nutritionOutput: nutritionOutput,
        recordTime: DateTime.now(),
        nutritionInputQuery: NutritionInputQuery(
          imageUrl: meal.imageUrl ?? '',
          scanMode: ScanMode.food,
        ),
        processingStatus: ProcessingStatus.COMPLETED,
      );

      final scannerController = Get.find<ScannerController>();
      scannerController.addRecord(nutritionRecord);

      final nutritionRecordRepo = serviceLocator<NutritionRecordRepo>();
      final existingRecords = await nutritionRecordRepo.getNutritionData(
        userId,
        DateTime.now(),
      );

      int totalConsumedCalories = existingRecords.dailyConsumedCalories;
      int totalConsumedProtein = existingRecords.dailyConsumedProtein;
      int totalConsumedFat = existingRecords.dailyConsumedFat;
      int totalConsumedCarb = existingRecords.dailyConsumedCarb;

      if (ingredients != null) {
        for (final ing in ingredients) {
          totalConsumedCalories += ing.calories ?? 0;
          totalConsumedProtein += ing.protein ?? 0;
          totalConsumedFat += ing.fat ?? 0;
          totalConsumedCarb += ing.carbs ?? 0;
        }
      }

      final dailyRecords =
          List<NutritionRecord>.from(existingRecords.dailyRecords)
            ..add(nutritionRecord);

      final dailyNutritionRecords = DailyNutritionRecords(
        dailyRecords: dailyRecords,
        recordDate: DateTime.now(),
        recordId: existingRecords.recordId,
        dailyConsumedCalories: totalConsumedCalories,
        dailyBurnedCalories: existingRecords.dailyBurnedCalories,
        dailyConsumedProtein: totalConsumedProtein,
        dailyConsumedFat: totalConsumedFat,
        dailyConsumedCarb: totalConsumedCarb,
      );

      await nutritionRecordRepo.saveNutritionData(
        dailyNutritionRecords,
        userId,
      );

      scannerController.updateNutritionValues(
        conCalories: totalConsumedCalories,
        conProtein: totalConsumedProtein,
        conFat: totalConsumedFat,
        conCarb: totalConsumedCarb,
      );

      debugPrint('DietController: Meal added to daily log');
    } catch (e) {
      debugPrint('DietController: ERROR adding to log: $e');
    }
  }

  void _updateMealLocally(int dayIndex, String mealType, NutritionResponseModel updatedMeal) {
    if (weeklyDiet.value == null) return;

    final dailyDiets = weeklyDiet.value!.dailyDiets;
    if (dailyDiets == null || dayIndex >= dailyDiets.length) return;

    final day = dailyDiets[dayIndex];
    if (day.meals == null) return;

    switch (mealType) {
      case 'breakfast':
      case 'lunch':
      case 'dinner':
      case 'snacks':
        day.meals!.updateMeal(mealType, updatedMeal);
        break;
      case 'cheatMeal':
        day.cheatMealOfTheDay = updatedMeal;
        break;
    }

    weeklyDiet.refresh();
  }
}
