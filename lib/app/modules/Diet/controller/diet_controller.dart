import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/models/Diet/diet_input.dart';
import 'package:NomAi/app/models/Diet/diet_output.dart';
import 'package:NomAi/app/repo/diet_repo.dart';

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
}
