import 'package:NomAi/app/models/Auth/user.dart';

class NutritionValidation {
  static const double minWeight = 25;
  static const double maxWeight = 300;
  static const double minHeight = 100;
  static const double maxHeight = 250;
  static const int minAge = 10;
  static const int maxAge = 100;

  static const double minCaloriesMale = 1500;
  static const double minCaloriesFemale = 1200;
  static const double minCaloriesOther = 1350;

  static double minCaloriesForGender(Gender gender) {
    switch (gender) {
      case Gender.male:
        return minCaloriesMale;
      case Gender.female:
        return minCaloriesFemale;
      default:
        return minCaloriesOther;
    }
  }

  static ValidationResult validate({
    required double? weight,
    required double? height,
    required DateTime? birthDate,
    required Gender gender,
  }) {
    List<String> warnings = [];
    double validatedWeight = weight ?? 70;
    double validatedHeight = height ?? 170;
    int? validatedAge;

    if (weight == null || weight <= 0) {
      warnings.add('Weight is required. Using a default of 70kg.');
      validatedWeight = 70;
    } else if (weight < minWeight) {
      warnings.add(
          'Weight $weight kg is below minimum. Clamping to $minWeight kg.');
      validatedWeight = minWeight;
    } else if (weight > maxWeight) {
      warnings
          .add('Weight $weight kg exceeds maximum. Clamping to $maxWeight kg.');
      validatedWeight = maxWeight;
    }

    if (height == null || height <= 0) {
      warnings.add('Height is required. Using a default of 170cm.');
      validatedHeight = 170;
    } else if (height < minHeight) {
      warnings.add(
          'Height $height cm is below minimum. Clamping to $minHeight cm.');
      validatedHeight = minHeight;
    } else if (height > maxHeight) {
      warnings
          .add('Height $height cm exceeds maximum. Clamping to $maxHeight cm.');
      validatedHeight = maxHeight;
    }

    if (birthDate != null) {
      validatedAge = _calculateAge(birthDate);
      if (validatedAge < minAge) {
        warnings
            .add('Age $validatedAge is below minimum. Using $minAge years.');
        validatedAge = minAge;
      } else if (validatedAge > maxAge) {
        warnings.add('Age $validatedAge exceeds maximum. Using $maxAge years.');
        validatedAge = maxAge;
      }
    } else {
      warnings.add('Birth date is required. Age cannot be validated.');
      validatedAge = 30;
    }

    return ValidationResult(
      weight: validatedWeight,
      height: validatedHeight,
      age: validatedAge,
      warnings: warnings,
      isValid: warnings.isEmpty,
    );
  }

  static int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

class ValidationResult {
  final double weight;
  final double height;
  final int age;
  final List<String> warnings;
  final bool isValid;

  ValidationResult({
    required this.weight,
    required this.height,
    required this.age,
    required this.warnings,
    required this.isValid,
  });
}

class GoalAdjustment {
  final double deficit;
  final String description;

  GoalAdjustment({required this.deficit, required this.description});
}

class NutritionCalculator {
  static const double MIN_CARBS_PER_KG = 2.0;
  static const double MAX_PROTEIN_PER_KG = 2.2;
  static const double MIN_CARBS_FLOOR = 50;

  static double calculateBMR({
    required Gender gender,
    required double weightKg,
    required double heightCm,
    required int age,
    double? bodyFatPercentage,
  }) {
    if (bodyFatPercentage != null && bodyFatPercentage > 0) {
      return _calculateKatchMcArdle(weightKg, bodyFatPercentage);
    }
    return _calculateMifflinStJeor(gender, weightKg, heightCm, age);
  }

  static double _calculateMifflinStJeor(
      Gender gender, double weightKg, double heightCm, int age) {
    double bmr;
    switch (gender) {
      case Gender.male:
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
        break;
      case Gender.female:
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
        break;
      default:
        double maleBmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
        double femaleBmr =
            (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
        bmr = (maleBmr + femaleBmr) / 2;
    }
    return bmr;
  }

  static double _calculateKatchMcArdle(
      double weightKg, double bodyFatPercentage) {
    double leanBodyMass = weightKg * (1 - bodyFatPercentage / 100);
    return 370 + (21.6 * leanBodyMass);
  }

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static double _calculateLBM(Gender gender, double weightKg, double heightCm) {
    if (gender == Gender.male) {
      return (0.407 * weightKg) + (0.267 * heightCm) - 19.2;
    } else if (gender == Gender.female) {
      return (0.252 * weightKg) + (0.473 * heightCm) - 48.3;
    } else {
      double maleLbm = (0.407 * weightKg) + (0.267 * heightCm) - 19.2;
      double femaleLbm = (0.252 * weightKg) + (0.473 * heightCm) - 48.3;
      return (maleLbm + femaleLbm) / 2;
    }
  }

  static double calculateTDEE(double bmr, ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return bmr * 1.2;
      case ActivityLevel.lightlyActive:
        return bmr * 1.375;
      case ActivityLevel.moderatelyActive:
        return bmr * 1.55;
      case ActivityLevel.veryActive:
        return bmr * 1.725;
      default:
        return bmr * 1.2;
    }
  }

  static ActivityLevel crossCheckActivityLevel({
    required ActivityLevel selectedActivityLevel,
    required String workoutOption,
    required int mealsPerDay,
  }) {
    bool isHighActivity = workoutOption.toLowerCase().contains('intense') ||
        workoutOption.toLowerCase().contains('heavy') ||
        workoutOption.toLowerCase().contains('athlete') ||
        workoutOption.toLowerCase().contains('5-6') ||
        workoutOption.toLowerCase().contains('7 days');

    bool isModerateActivity =
        workoutOption.toLowerCase().contains('moderate') ||
            workoutOption.toLowerCase().contains('3-4') ||
            workoutOption.toLowerCase().contains('regular');

    ActivityLevel recommended = selectedActivityLevel;

    if (isHighActivity && selectedActivityLevel == ActivityLevel.sedentary) {
      recommended = ActivityLevel.moderatelyActive;
    } else if (isModerateActivity &&
        selectedActivityLevel == ActivityLevel.sedentary) {
      recommended = ActivityLevel.lightlyActive;
    }

    if (mealsPerDay < 3 && recommended == ActivityLevel.veryActive) {
      recommended = ActivityLevel.moderatelyActive;
    }

    return recommended;
  }

  static WeeklyPace clampPaceForSafety({
    required WeeklyPace selectedPace,
    required double currentWeight,
    required double targetWeight,
  }) {
    double weightDiff = (currentWeight - targetWeight).abs();
    double maxSafeWeeklyLoss = currentWeight * 0.01;

    double totalLossNeeded = weightDiff;
    double weeksToLose = totalLossNeeded / (maxSafeWeeklyLoss * 4.33);

    if (weeksToLose < 4 && selectedPace == WeeklyPace.fast) {
      return WeeklyPace.moderate;
    }

    if (weeksToLose < 2) {
      return WeeklyPace.slow;
    }

    return selectedPace;
  }

  static HealthMode adjustGoalIfNeeded({
    required double currentWeight,
    required double targetWeight,
    required HealthMode selectedGoal,
  }) {
    double diff = (currentWeight - targetWeight).abs();

    if (diff < 2) {
      return HealthMode.maintainWeight;
    }

    if (diff > 50) {
      return selectedGoal;
    }

    return selectedGoal;
  }

  static GoalAdjustment calculateGoalAdjustment({
    required HealthMode goal,
    required WeeklyPace pace,
    required double tdee,
    required double currentWeight,
    required double targetWeight,
    required Gender gender,
    required double estimatedBodyFat,
  }) {
    if (goal == HealthMode.maintainWeight || goal == HealthMode.none) {
      return GoalAdjustment(
          deficit: 0, description: 'Maintain current calories');
    }

    if (goal == HealthMode.muscleGain) {
      double surplus;
      String desc;

      if (estimatedBodyFat < 15) {
        surplus = 300;
        desc = 'Lean bulk: +300 kcal';
      } else if (estimatedBodyFat < 25) {
        surplus = 250;
        desc = 'Body recomposition: +250 kcal';
      } else {
        surplus = 200;
        desc = 'Slow bulk (higher body fat): +200 kcal';
      }

      if (pace == WeeklyPace.fast) {
        surplus = 500;
        desc = 'Faster bulk: +500 kcal';
      }

      return GoalAdjustment(deficit: -surplus, description: desc);
    }

    double deficit;
    String desc;

    switch (pace) {
      case WeeklyPace.slow:
        deficit = 300;
        desc = 'Mild deficit: -300 kcal';
        break;
      case WeeklyPace.moderate:
        deficit = 500;
        desc = 'Moderate deficit: -500 kcal';
        break;
      case WeeklyPace.fast:
        if (estimatedBodyFat > 25) {
          deficit = 1000;
          desc = 'Aggressive deficit (high body fat): -1000 kcal';
        } else {
          deficit = 750;
          desc = 'Aggressive deficit: -750 kcal';
        }
        break;
      default:
        deficit = 0;
        desc = 'No deficit';
    }

    double maxDeficit = tdee * 0.25;
    if (deficit > maxDeficit) {
      deficit = maxDeficit;
      desc = 'Deficit capped at 25% of TDEE: -${deficit.toInt()} kcal';
    }

    return GoalAdjustment(deficit: deficit, description: desc);
  }

  static double applyMinCalories(double calories, Gender gender) {
    double minCalories = NutritionValidation.minCaloriesForGender(gender);
    return calories < minCalories ? minCalories : calories;
  }

  static double estimateBodyFatPercentage(
      double currentWeight, double targetWeight) {
    double estimatedBodyFat =
        ((currentWeight - targetWeight) / currentWeight) * 100;
    if (estimatedBodyFat > 40) estimatedBodyFat = 40;
    if (estimatedBodyFat < 0) estimatedBodyFat = 5;
    return estimatedBodyFat;
  }

  static double calculateSleepAdjustment(String sleepPattern) {
    switch (sleepPattern.toLowerCase()) {
      case 'less than 6 hours':
      case 'very poor':
        return 0.97;
      case '6-7 hours':
      case 'poor':
        return 0.98;
      case '7-8 hours':
      case 'good':
        return 1.0;
      case 'more than 8 hours':
        return 1.02;
      default:
        return 1.0;
    }
  }

  static double calculateObstacleAdjustment(String obstacle) {
    switch (obstacle.toLowerCase()) {
      case 'low energy':
      case 'fatigue':
        return 0.95;
      case 'stress eating':
      case 'emotional eating':
        return 0.97;
      case 'late night snacking':
        return 0.98;
      default:
        return 1.0;
    }
  }

  static BehavioralMacroAdjustment calculateBehavioralAdjustment({
    required String? behavioralPreference,
    required String? sweetTooth,
    required String? junkFood,
    required String? lackOfTime,
    required int mealsPerDay,
  }) {
    int carbBoost = 0;
    int fatAdjust = 0;
    int proteinReduce = 0;
    List<String> reasons = [];

    if (behavioralPreference != null) {
      String pref = behavioralPreference.toLowerCase();
      if (pref.contains('sweet') ||
          pref.contains('sugar') ||
          pref.contains('dessert')) {
        carbBoost += 30;
        reasons.add('Sweet tooth: +30g carbs');
      }
      if (pref.contains('junk') ||
          pref.contains('fast food') ||
          pref.contains('processed')) {
        carbBoost += 20;
        fatAdjust -= 10;
        reasons.add('Junk food preference: +20g carbs, -10g fat');
      }
      if (pref.contains('time') ||
          pref.contains('busy') ||
          pref.contains('schedule')) {
        proteinReduce += 10;
        reasons.add('Lack of time: simplified protein approach');
      }
      if (pref.contains(' Athlete') || pref.contains('performance')) {
        carbBoost += 50;
        reasons.add('Performance focus: +50g carbs');
      }
    }

    if (sweetTooth != null && sweetTooth.toLowerCase().contains('yes')) {
      carbBoost += 25;
      reasons.add('Sweet tooth: +25g carbs');
    }

    if (junkFood != null && junkFood.toLowerCase().contains('yes')) {
      carbBoost += 20;
      fatAdjust -= 10;
      reasons.add('Junk food preference: +20g carbs, -10g fat');
    }

    if (mealsPerDay >= 4) {
      carbBoost += 20;
      reasons.add('Higher meal frequency: +20g carbs for sustained energy');
    }

    return BehavioralMacroAdjustment(
      carbBoost: carbBoost,
      fatAdjust: fatAdjust,
      proteinReduce: proteinReduce,
      reasons: reasons,
    );
  }

  static MacroSplit calculateMacros({
    required double calories,
    required HealthMode goal,
    required double bodyWeight,
    required DietPreference dietPreference,
    required int mealsPerDay,
    String? behavioralPreference,
    ActivityLevel? activityLevel,
  }) {
    double proteinPerKg;
    double fatPercentage;
    double carbPercentage;

    switch (goal) {
      case HealthMode.weightLoss:
        if (dietPreference == DietPreference.keto) {
          proteinPerKg = 2.0;
          fatPercentage = 0.65;
          carbPercentage = 0.05;
        } else {
          proteinPerKg = 2.0;
          fatPercentage = 0.30;
          carbPercentage = 0.35;
        }
        break;
      case HealthMode.muscleGain:
        if (dietPreference == DietPreference.keto) {
          proteinPerKg = 2.2;
          fatPercentage = 0.55;
          carbPercentage = 0.10;
        } else {
          proteinPerKg = 2.0;
          fatPercentage = 0.25;
          carbPercentage = 0.40;
        }
        break;
      case HealthMode.maintainWeight:
      case HealthMode.none:
      default:
        if (dietPreference == DietPreference.keto) {
          proteinPerKg = 1.8;
          fatPercentage = 0.60;
          carbPercentage = 0.10;
        } else {
          proteinPerKg = 1.6;
          fatPercentage = 0.30;
          carbPercentage = 0.35;
        }
        break;
    }

    if (dietPreference == DietPreference.paleo) {
      carbPercentage = 0.25;
    } else if (dietPreference == DietPreference.vegetarian ||
        dietPreference == DietPreference.vegan) {
      proteinPerKg += 0.2;
    }

    if (proteinPerKg > MAX_PROTEIN_PER_KG) {
      proteinPerKg = MAX_PROTEIN_PER_KG;
    }

    int proteinGrams = (bodyWeight * proteinPerKg).round();
    double proteinCalories = proteinGrams * 4.0;
    double fatCalories = calories * fatPercentage;
    int fatGrams = (fatCalories / 9.0).round();
    double remainingCalories = calories - proteinCalories - fatCalories;
    int carbGrams = (remainingCalories / 4.0).round();

    if (dietPreference != DietPreference.keto) {
      int minCarbs = (bodyWeight * MIN_CARBS_PER_KG).round();
      if (minCarbs < MIN_CARBS_FLOOR) minCarbs = MIN_CARBS_FLOOR.floor();

      if (carbGrams < minCarbs) {
        int calorieDeficit = minCarbs * 4 - carbGrams * 4;
        fatGrams = ((fatCalories - calorieDeficit) / 9.0).round();
        if (fatGrams < 30) {
          fatGrams = 30;
        }
        carbGrams = minCarbs;
      }
    } else {
      if (carbGrams < 20) {
        carbGrams = 20;
      }
    }

    int fiberIntake = (calories / 1000 * 14).round();
    if (fiberIntake < 25) fiberIntake = 25;
    if (fiberIntake > 40) fiberIntake = 40;

    double mealCalorie = calories / mealsPerDay;
    int proteinPerMeal = (proteinGrams / mealsPerDay).round();

    return MacroSplit(
      calories: calories.round(),
      protein: proteinGrams,
      carbs: carbGrams,
      fat: fatGrams,
      fiber: fiberIntake,
      proteinPerMeal: proteinPerMeal,
      mealCalorie: mealCalorie.round(),
      proteinPerKg: proteinPerKg,
      fatPercentage: fatPercentage,
      carbPercentage: carbPercentage,
    );
  }

  static int calculateWater(double bodyWeight, int mealsPerDay) {
    int baseWater = (bodyWeight * 35).round();
    int adjustedWater = baseWater + (mealsPerDay - 3) * 200;
    return adjustedWater.clamp(2000, 5000);
  }

  static NutritionResult calculateNutrition({
    required Gender gender,
    required DateTime birthDate,
    required double? currentHeight,
    required double? currentWeight,
    required WeeklyPace selectedPace,
    required double? desiredWeight,
    required HealthMode selectedGoal,
    required ActivityLevel selectedActivityLevel,
    required String selectedSleepPattern,
    required String selectedObstacle,
    required DietPreference selectedDietPreference,
    required List<String> selectedMeals,
    required String selectedWorkoutOption,
  }) {
    List<String> allWarnings = [];
    List<String> adjustments = [];

    double weight = currentWeight ?? 70;
    double height = currentHeight ?? 170;
    double targetWeight = desiredWeight ?? weight;

    ValidationResult validation = NutritionValidation.validate(
      weight: currentWeight,
      height: currentHeight,
      birthDate: birthDate,
      gender: gender,
    );
    weight = validation.weight;
    height = validation.height;
    int age = validation.age;
    allWarnings.addAll(validation.warnings);

    HealthMode adjustedGoal = adjustGoalIfNeeded(
      currentWeight: weight,
      targetWeight: targetWeight,
      selectedGoal: selectedGoal,
    );
    if (adjustedGoal != selectedGoal) {
      adjustments
          .add('Goal adjusted to ${adjustedGoal.name} (target too close/far)');
    }

    int mealsPerDay = selectedMeals.length;
    if (mealsPerDay < 2) mealsPerDay = 3;
    if (mealsPerDay > 6) mealsPerDay = 6;

    ActivityLevel crossCheckedActivity = crossCheckActivityLevel(
      selectedActivityLevel: selectedActivityLevel,
      workoutOption: selectedWorkoutOption,
      mealsPerDay: mealsPerDay,
    );
    if (crossCheckedActivity != selectedActivityLevel) {
      adjustments.add('Activity level adjusted based on workout pattern');
    }

    WeeklyPace safePace = clampPaceForSafety(
      selectedPace: selectedPace,
      currentWeight: weight,
      targetWeight: targetWeight,
    );
    if (safePace != selectedPace) {
      adjustments
          .add('Pace adjusted to ${safePace.name} (unsafe pace detected)');
    }

    double bmr = calculateBMR(
      gender: gender,
      weightKg: weight,
      heightCm: height,
      age: age,
    );
    double tdee = calculateTDEE(bmr, crossCheckedActivity);

    double estimatedBodyFat = estimateBodyFatPercentage(weight, targetWeight);

    GoalAdjustment goalAdjustment = calculateGoalAdjustment(
      goal: adjustedGoal,
      pace: safePace,
      tdee: tdee,
      currentWeight: weight,
      targetWeight: targetWeight,
      gender: gender,
      estimatedBodyFat: estimatedBodyFat,
    );

    double adjustedCalories = tdee - goalAdjustment.deficit;

    double sleepFactor = calculateSleepAdjustment(selectedSleepPattern);
    adjustedCalories *= sleepFactor;

    double obstacleFactor = calculateObstacleAdjustment(selectedObstacle);
    adjustedCalories *= obstacleFactor;

    adjustedCalories = applyMinCalories(adjustedCalories, gender);
    adjustedCalories = adjustedCalories.roundToDouble();

    MacroSplit macros = calculateMacros(
      calories: adjustedCalories,
      goal: adjustedGoal,
      bodyWeight: weight,
      dietPreference: selectedDietPreference,
      mealsPerDay: mealsPerDay,
      activityLevel: crossCheckedActivity,
    );

    BehavioralMacroAdjustment behaviorAdjust = calculateBehavioralAdjustment(
      behavioralPreference:
          selectedMeals.isNotEmpty ? selectedMeals.first : null,
      sweetTooth: selectedMeals.isNotEmpty ? selectedMeals.first : null,
      junkFood: selectedMeals.isNotEmpty ? selectedMeals.first : null,
      lackOfTime: selectedMeals.isNotEmpty ? selectedMeals.first : null,
      mealsPerDay: mealsPerDay,
    );

    int finalCarbs = macros.carbs + behaviorAdjust.carbBoost;
    int finalFat = macros.fat + behaviorAdjust.fatAdjust;
    int finalProtein = macros.protein - behaviorAdjust.proteinReduce;
    if (finalFat < 30) finalFat = 30;
    if (finalProtein < (weight * 1.2).round()) {
      finalProtein = (weight * 1.2).round();
    }

    if (behaviorAdjust.reasons.isNotEmpty) {
      adjustments.addAll(behaviorAdjust.reasons);
    }

    int water = calculateWater(weight, mealsPerDay);

    return NutritionResult(
      calories: adjustedCalories.round(),
      protein: finalProtein,
      carbs: finalCarbs,
      fat: finalFat,
      fiber: macros.fiber,
      water: water,
      bmr: bmr.round(),
      tdee: tdee.round(),
      estimatedBodyFat: estimatedBodyFat,
      goalAdjustmentDescription: goalAdjustment.description,
      activityLevelUsed: crossCheckedActivity,
      warnings: allWarnings,
      adjustments: adjustments,
      macros: UserMacros(
        calories: adjustedCalories.round(),
        protein: finalProtein,
        carbs: finalCarbs,
        fat: finalFat,
        water: water,
        fiber: macros.fiber,
      ),
    );
  }
}

class MacroSplit {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int proteinPerMeal;
  final int mealCalorie;
  final double proteinPerKg;
  final double fatPercentage;
  final double carbPercentage;

  MacroSplit({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.proteinPerMeal,
    required this.mealCalorie,
    required this.proteinPerKg,
    required this.fatPercentage,
    required this.carbPercentage,
  });
}

class BehavioralMacroAdjustment {
  final int carbBoost;
  final int fatAdjust;
  final int proteinReduce;
  final List<String> reasons;

  BehavioralMacroAdjustment({
    required this.carbBoost,
    required this.fatAdjust,
    required this.proteinReduce,
    required this.reasons,
  });
}

class NutritionResult {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int water;
  final int bmr;
  final int tdee;
  final double estimatedBodyFat;
  final String goalAdjustmentDescription;
  final ActivityLevel activityLevelUsed;
  final List<String> warnings;
  final List<String> adjustments;
  final UserMacros macros;

  NutritionResult({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.water,
    required this.bmr,
    required this.tdee,
    required this.estimatedBodyFat,
    required this.goalAdjustmentDescription,
    required this.activityLevelUsed,
    required this.warnings,
    required this.adjustments,
    required this.macros,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasAdjustments => adjustments.isNotEmpty;
}

class NutritionAdaptor {
  static NutritionResult recalculateForProgress({
    required NutritionResult currentPlan,
    required double actualWeeklyLoss,
    required double expectedWeeklyLoss,
  }) {
    int calorieAdjustment = 0;
    String reason;

    if ((actualWeeklyLoss - expectedWeeklyLoss).abs() < 0.2) {
      return currentPlan;
    }

    if (actualWeeklyLoss < expectedWeeklyLoss - 0.5) {
      calorieAdjustment = -200;
      reason = 'Losing weight slower than expected. Reducing calories by 200.';
    } else if (actualWeeklyLoss > expectedWeeklyLoss + 0.5) {
      if (actualWeeklyLoss > expectedWeeklyLoss + 1.0) {
        calorieAdjustment = 150;
        reason = 'Losing weight too fast. Increasing calories by 150.';
      } else {
        calorieAdjustment = -100;
        reason =
            'Losing weight slightly faster than expected. Small reduction.';
      }
    } else {
      reason = 'Minor adjustment';
    }

    double newCalories = (currentPlan.calories + calorieAdjustment).toDouble();
    double minCalories = NutritionValidation.minCaloriesForGender(Gender.male);

    if (newCalories < minCalories) {
      newCalories = minCalories;
    }

    MacroSplit newMacros = NutritionCalculator.calculateMacros(
      calories: newCalories,
      goal: HealthMode.weightLoss,
      bodyWeight: 70,
      dietPreference: DietPreference.none,
      mealsPerDay: 3,
    );

    List<String> newWarnings = [...currentPlan.warnings, reason];
    List<String> newAdjustments = [
      ...currentPlan.adjustments,
      'Recalculated based on progress'
    ];

    return NutritionResult(
      calories: newCalories.round(),
      protein: newMacros.protein,
      carbs: newMacros.carbs,
      fat: newMacros.fat,
      fiber: newMacros.fiber,
      water: currentPlan.water,
      bmr: currentPlan.bmr,
      tdee: currentPlan.tdee,
      estimatedBodyFat: currentPlan.estimatedBodyFat,
      goalAdjustmentDescription: currentPlan.goalAdjustmentDescription,
      activityLevelUsed: currentPlan.activityLevelUsed,
      warnings: newWarnings,
      adjustments: newAdjustments,
      macros: UserMacros(
        calories: newCalories.round(),
        protein: newMacros.protein,
        carbs: newMacros.carbs,
        fat: newMacros.fat,
        water: currentPlan.water,
        fiber: newMacros.fiber,
      ),
    );
  }
}
