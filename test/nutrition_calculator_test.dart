import 'package:flutter_test/flutter_test.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/utility/user_utility.dart';

void main() {
  group('NutritionValidation', () {
    test('validates weight within range', () {
      final result = NutritionValidation.validate(
        weight: 75.0,
        height: 175.0,
        birthDate: DateTime(1990, 1, 1),
        gender: Gender.male,
      );

      expect(result.isValid, true);
      expect(result.warnings, isEmpty);
      expect(result.weight, 75.0);
    });

    test('clamps weight below minimum to 25kg', () {
      final result = NutritionValidation.validate(
        weight: 20.0,
        height: 175.0,
        birthDate: DateTime(1990, 1, 1),
        gender: Gender.male,
      );

      expect(result.weight, NutritionValidation.minWeight);
      expect(result.warnings, contains(contains('below minimum')));
    });

    test('clamps weight above maximum to 300kg', () {
      final result = NutritionValidation.validate(
        weight: 350.0,
        height: 175.0,
        birthDate: DateTime(1990, 1, 1),
        gender: Gender.male,
      );

      expect(result.weight, NutritionValidation.maxWeight);
      expect(result.warnings, contains(contains('exceeds maximum')));
    });

    test('uses default weight when null', () {
      final result = NutritionValidation.validate(
        weight: null,
        height: 175.0,
        birthDate: DateTime(1990, 1, 1),
        gender: Gender.male,
      );

      expect(result.weight, 70.0);
      expect(result.warnings, contains(contains('default of 70kg')));
    });

    test('returns correct min calories for each gender', () {
      expect(NutritionValidation.minCaloriesForGender(Gender.male), 1500);
      expect(NutritionValidation.minCaloriesForGender(Gender.female), 1200);
      expect(NutritionValidation.minCaloriesForGender(Gender.other), 1350);
    });
  });

  group('NutritionCalculator', () {
    group('BMR calculation', () {
      test('calculates BMR for male using Mifflin-St Jeor', () {
        final bmr = NutritionCalculator.calculateBMR(
          gender: Gender.male,
          weightKg: 80.0,
          heightCm: 180.0,
          age: 30,
        );

        double expectedBmr = (10 * 80.0) + (6.25 * 180.0) - (5 * 30) + 5;

        expect(bmr, closeTo(expectedBmr, 0.1));
      });

      test('calculates BMR for female using Mifflin-St Jeor', () {
        final bmr = NutritionCalculator.calculateBMR(
          gender: Gender.female,
          weightKg: 60.0,
          heightCm: 165.0,
          age: 25,
        );

        double expectedBmr = (10 * 60.0) + (6.25 * 165.0) - (5 * 25) - 161;

        expect(bmr, closeTo(expectedBmr, 0.1));
      });
    });

    group('TDEE calculation', () {
      test('applies correct multiplier for sedentary', () {
        final tdee =
            NutritionCalculator.calculateTDEE(1600, ActivityLevel.sedentary);
        expect(tdee, 1600 * 1.2);
      });

      test('applies correct multiplier for moderately active', () {
        final tdee = NutritionCalculator.calculateTDEE(
            1600, ActivityLevel.moderatelyActive);
        expect(tdee, 1600 * 1.55);
      });

      test('applies correct multiplier for very active', () {
        final tdee =
            NutritionCalculator.calculateTDEE(1600, ActivityLevel.veryActive);
        expect(tdee, 1600 * 1.725);
      });
    });

    group('Goal adjustment', () {
      test('weight loss slow pace = 300 kcal deficit', () {
        final adjustment = NutritionCalculator.calculateGoalAdjustment(
          goal: HealthMode.weightLoss,
          pace: WeeklyPace.slow,
          tdee: 2000,
          currentWeight: 80,
          targetWeight: 75,
          gender: Gender.male,
          estimatedBodyFat: 20,
        );

        expect(adjustment.deficit, 300);
        expect(adjustment.description, contains('300'));
      });

      test('weight loss moderate pace = 500 kcal deficit', () {
        final adjustment = NutritionCalculator.calculateGoalAdjustment(
          goal: HealthMode.weightLoss,
          pace: WeeklyPace.moderate,
          tdee: 2000,
          currentWeight: 80,
          targetWeight: 70,
          gender: Gender.male,
          estimatedBodyFat: 20,
        );

        expect(adjustment.deficit, 500);
      });

      test('weight loss fast pace = 750 kcal deficit for normal body fat', () {
        final adjustment = NutritionCalculator.calculateGoalAdjustment(
          goal: HealthMode.weightLoss,
          pace: WeeklyPace.fast,
          tdee: 3000,
          currentWeight: 100,
          targetWeight: 80,
          gender: Gender.male,
          estimatedBodyFat: 20,
        );

        expect(adjustment.deficit, 750);
      });

      test('weight loss fast pace = 1000 kcal deficit for high body fat', () {
        final adjustment = NutritionCalculator.calculateGoalAdjustment(
          goal: HealthMode.weightLoss,
          pace: WeeklyPace.fast,
          tdee: 4000,
          currentWeight: 120,
          targetWeight: 100,
          gender: Gender.male,
          estimatedBodyFat: 30,
        );

        expect(adjustment.deficit, 1000);
      });

      test('deficit capped at 25% of TDEE', () {
        final adjustment = NutritionCalculator.calculateGoalAdjustment(
          goal: HealthMode.weightLoss,
          pace: WeeklyPace.fast,
          tdee: 1200,
          currentWeight: 80,
          targetWeight: 70,
          gender: Gender.female,
          estimatedBodyFat: 20,
        );

        expect(adjustment.deficit, 1200 * 0.25);
        expect(adjustment.description, contains('25%'));
      });

      test('muscle gain with low body fat = lean bulk +300', () {
        final adjustment = NutritionCalculator.calculateGoalAdjustment(
          goal: HealthMode.muscleGain,
          pace: WeeklyPace.slow,
          tdee: 2000,
          currentWeight: 75,
          targetWeight: 78,
          gender: Gender.male,
          estimatedBodyFat: 12,
        );

        expect(adjustment.deficit, -300);
        expect(adjustment.description, contains('Lean bulk'));
      });

      test('muscle gain with higher body fat = slower bulk +200', () {
        final adjustment = NutritionCalculator.calculateGoalAdjustment(
          goal: HealthMode.muscleGain,
          pace: WeeklyPace.slow,
          tdee: 2000,
          currentWeight: 85,
          targetWeight: 88,
          gender: Gender.male,
          estimatedBodyFat: 25,
        );

        expect(adjustment.deficit, -200);
      });

      test('maintain weight = no adjustment', () {
        final adjustment = NutritionCalculator.calculateGoalAdjustment(
          goal: HealthMode.maintainWeight,
          pace: WeeklyPace.none,
          tdee: 2000,
          currentWeight: 75,
          targetWeight: 75,
          gender: Gender.male,
          estimatedBodyFat: 18,
        );

        expect(adjustment.deficit, 0);
      });
    });

    group('Pace clamping', () {
      test('clamps fast pace to moderate when target is close', () {
        final clampedPace = NutritionCalculator.clampPaceForSafety(
          selectedPace: WeeklyPace.fast,
          currentWeight: 80,
          targetWeight: 79,
        );

        expect(clampedPace, WeeklyPace.moderate);
      });

      test('clamps fast pace to moderate when target is very close', () {
        final clampedPace = NutritionCalculator.clampPaceForSafety(
          selectedPace: WeeklyPace.fast,
          currentWeight: 80,
          targetWeight: 77,
        );

        expect(clampedPace, WeeklyPace.moderate);
      });

      test('keeps slow pace when target is far enough', () {
        final clampedPace = NutritionCalculator.clampPaceForSafety(
          selectedPace: WeeklyPace.slow,
          currentWeight: 100,
          targetWeight: 70,
        );

        expect(clampedPace, WeeklyPace.slow);
      });
    });

    group('Goal adjustment when target is close', () {
      test('switches to maintain when desired weight is within 2kg', () {
        final adjustedGoal = NutritionCalculator.adjustGoalIfNeeded(
          currentWeight: 80,
          targetWeight: 79,
          selectedGoal: HealthMode.weightLoss,
        );

        expect(adjustedGoal, HealthMode.maintainWeight);
      });

      test('keeps original goal when weight difference is significant', () {
        final adjustedGoal = NutritionCalculator.adjustGoalIfNeeded(
          currentWeight: 80,
          targetWeight: 70,
          selectedGoal: HealthMode.weightLoss,
        );

        expect(adjustedGoal, HealthMode.weightLoss);
      });
    });

    group('Macro calculation', () {
      test('calculates macros for weight loss with normal diet', () {
        final macros = NutritionCalculator.calculateMacros(
          calories: 1800,
          goal: HealthMode.weightLoss,
          bodyWeight: 80,
          dietPreference: DietPreference.none,
          mealsPerDay: 3,
        );

        expect(macros.protein, 160);
        expect(macros.fat, greaterThan(0));
        expect(macros.carbs, greaterThan(0));
      });

      test('calculates keto macros correctly', () {
        final macros = NutritionCalculator.calculateMacros(
          calories: 1800,
          goal: HealthMode.weightLoss,
          bodyWeight: 80,
          dietPreference: DietPreference.keto,
          mealsPerDay: 3,
        );

        expect(macros.carbs, lessThan(50));
      });

      test('ensures minimum carbs of 20g', () {
        final macros = NutritionCalculator.calculateMacros(
          calories: 1000,
          goal: HealthMode.weightLoss,
          bodyWeight: 60,
          dietPreference: DietPreference.keto,
          mealsPerDay: 3,
        );

        expect(macros.carbs, greaterThanOrEqualTo(20));
      });

      test('caps protein at 2.2 g/kg maximum', () {
        final macros = NutritionCalculator.calculateMacros(
          calories: 3000,
          goal: HealthMode.muscleGain,
          bodyWeight: 100,
          dietPreference: DietPreference.none,
          mealsPerDay: 3,
        );

        expect(macros.proteinPerKg, lessThanOrEqualTo(2.2));
        expect(macros.protein, lessThanOrEqualTo(220));
      });

      test('applies carb floor of 2g per kg body weight', () {
        final macros = NutritionCalculator.calculateMacros(
          calories: 2000,
          goal: HealthMode.weightLoss,
          bodyWeight: 80,
          dietPreference: DietPreference.none,
          mealsPerDay: 3,
        );

        expect(macros.carbs, greaterThanOrEqualTo(160));
      });

      test('carb floor does not apply to keto', () {
        final macros = NutritionCalculator.calculateMacros(
          calories: 2000,
          goal: HealthMode.weightLoss,
          bodyWeight: 80,
          dietPreference: DietPreference.keto,
          mealsPerDay: 3,
        );

        expect(macros.carbs, lessThan(50));
      });
    });

    group('Behavioral adjustment', () {
      test('adjusts macros for sweet tooth', () {
        final adjustment = NutritionCalculator.calculateBehavioralAdjustment(
          behavioralPreference: 'sweet tooth',
          sweetTooth: 'yes',
          junkFood: 'no',
          lackOfTime: 'no',
          mealsPerDay: 3,
        );

        expect(adjustment.carbBoost, greaterThan(0));
        expect(adjustment.reasons, isNotEmpty);
      });

      test('adjusts macros for junk food preference', () {
        final adjustment = NutritionCalculator.calculateBehavioralAdjustment(
          behavioralPreference: 'junk food',
          sweetTooth: 'no',
          junkFood: 'yes',
          lackOfTime: 'no',
          mealsPerDay: 3,
        );

        expect(adjustment.carbBoost, greaterThan(0));
        expect(adjustment.fatAdjust, lessThan(0));
      });

      test('higher meal frequency gets carb boost', () {
        final adjustment = NutritionCalculator.calculateBehavioralAdjustment(
          behavioralPreference: '',
          sweetTooth: 'no',
          junkFood: 'no',
          lackOfTime: 'no',
          mealsPerDay: 5,
        );

        expect(adjustment.carbBoost, greaterThan(0));
      });
    });

    group('Sleep adjustment', () {
      test('applies reduction for poor sleep', () {
        final factor =
            NutritionCalculator.calculateSleepAdjustment('less than 6 hours');
        expect(factor, lessThan(1.0));
      });

      test('applies bonus for more than 8 hours sleep', () {
        final factor =
            NutritionCalculator.calculateSleepAdjustment('more than 8 hours');
        expect(factor, greaterThan(1.0));
      });
    });

    group('Activity level cross-check', () {
      test('downgrades sedentary when intense workout selected', () {
        final activity = NutritionCalculator.crossCheckActivityLevel(
          selectedActivityLevel: ActivityLevel.sedentary,
          workoutOption: 'intense training 5 days',
          mealsPerDay: 3,
        );

        expect(activity, ActivityLevel.moderatelyActive);
      });

      test('keeps selected activity when consistent with workout', () {
        final activity = NutritionCalculator.crossCheckActivityLevel(
          selectedActivityLevel: ActivityLevel.moderatelyActive,
          workoutOption: 'moderate exercise 3-4 days',
          mealsPerDay: 3,
        );

        expect(activity, ActivityLevel.moderatelyActive);
      });
    });
  });

  group('NutritionCalculator.calculateNutrition - integration', () {
    test('calculates complete nutrition plan for weight loss', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.moderatelyActive,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'moderate exercise 3-4 days',
      );

      expect(result.calories, greaterThan(0));
      expect(result.protein, greaterThan(0));
      expect(result.carbs, greaterThan(0));
      expect(result.fat, greaterThan(0));
      expect(result.water, greaterThan(0));
      expect(result.fiber, greaterThan(0));
      expect(result.tdee, greaterThan(result.bmr));
      expect(result.macros.calories, result.calories);
    });

    test('respects minimum calorie floor for small female', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.female,
        birthDate: DateTime(1995, 1, 1),
        currentHeight: 155,
        currentWeight: 50,
        selectedPace: WeeklyPace.fast,
        desiredWeight: 45,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.calories, greaterThanOrEqualTo(1200));
    });

    test('returns warnings when using default values', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: null,
        currentWeight: null,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.hasWarnings, true);
    });

    test('muscle gain increases calories above TDEE', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1995, 1, 1),
        currentHeight: 175,
        currentWeight: 70,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 73,
        selectedGoal: HealthMode.muscleGain,
        selectedActivityLevel: ActivityLevel.lightlyActive,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'light exercise 1-2 days',
      );

      expect(result.calories, greaterThan(result.tdee));
    });
  });

  group('NutritionAdaptor - feedback loop', () {
    test('no change when actual matches expected', () {
      final currentPlan = _createMockNutritionResult(calories: 2000);

      final adapted = NutritionAdaptor.recalculateForProgress(
        currentPlan: currentPlan,
        actualWeeklyLoss: 0.5,
        expectedWeeklyLoss: 0.5,
      );

      expect(adapted.calories, 2000);
    });

    test('reduces calories when losing too slowly', () {
      final currentPlan = _createMockNutritionResult(calories: 2000);

      final adapted = NutritionAdaptor.recalculateForProgress(
        currentPlan: currentPlan,
        actualWeeklyLoss: 0.2,
        expectedWeeklyLoss: 0.8,
      );

      expect(adapted.calories, lessThan(2000));
      expect(adapted.calories, 1800);
    });

    test('increases calories when losing too fast', () {
      final currentPlan = _createMockNutritionResult(calories: 2500);

      final adapted = NutritionAdaptor.recalculateForProgress(
        currentPlan: currentPlan,
        actualWeeklyLoss: 2.0,
        expectedWeeklyLoss: 0.5,
      );

      expect(adapted.calories, greaterThan(2500));
    });
  });

  group('Edge Cases - Notorious User Behavior', () {
    test('handles zero weight gracefully', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 0,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.hasWarnings, true);
      expect(result.macros.calories, greaterThan(0));
    });

    test('handles negative weight gracefully', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: -50,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.hasWarnings, true);
      expect(result.macros.calories, greaterThan(0));
    });

    test('handles extreme height (very short)', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.female,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 50,
        currentWeight: 50,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 45,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.hasWarnings, true);
      expect(result.macros.calories, greaterThan(0));
    });

    test('handles extreme height (very tall)', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 300,
        currentWeight: 200,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 100,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.hasWarnings, true);
      expect(result.macros.calories, greaterThan(0));
    });

    test('handles future birthdate gracefully', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime.now().add(const Duration(days: 365)),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.hasWarnings, true);
      expect(result.macros.calories, greaterThan(0));
    });

    test('handles very old birthdate gracefully', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1900, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.hasWarnings, true);
      expect(result.macros.calories, greaterThan(0));
    });

    test('handles target weight higher than current (weight loss goal)', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 75,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 85,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.macros.calories, greaterThan(0));
    });

    test('handles desired weight way too low', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.fast,
        desiredWeight: 30,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.macros.calories, greaterThanOrEqualTo(1500));
    });

    test('handles desired weight way too high (muscle gain)', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.female,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 160,
        currentWeight: 60,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 200,
        selectedGoal: HealthMode.muscleGain,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.macros.calories, greaterThan(0));
    });

    test('handles very small female with aggressive deficit', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.female,
        birthDate: DateTime(2000, 1, 1),
        currentHeight: 145,
        currentWeight: 40,
        selectedPace: WeeklyPace.fast,
        desiredWeight: 35,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.macros.calories, greaterThanOrEqualTo(1200));
    });

    test('handles empty meals list', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: [],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.macros.calories, greaterThan(0));
      expect(result.water, greaterThan(0));
    });

    test('handles many meals per day', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: [
          'meal1',
          'meal2',
          'meal3',
          'meal4',
          'meal5',
          'meal6',
          'meal7',
          'meal8'
        ],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.macros.calories, greaterThan(0));
    });

    test('handles missing selectedDiet with weird value', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: 'unknown sleep pattern',
        selectedObstacle: 'unknown obstacle',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'unknown workout',
      );

      expect(result.macros.calories, greaterThan(0));
    });

    test('handles very poor sleep + stress eating combo', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: 'less than 6 hours',
        selectedObstacle: 'stress eating',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.macros.calories, greaterThan(0));
    });

    test('muscle gain when already at low body fat', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 70,
        selectedPace: WeeklyPace.slow,
        desiredWeight: 72,
        selectedGoal: HealthMode.muscleGain,
        selectedActivityLevel: ActivityLevel.moderatelyActive,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'intense training 5 days',
      );

      expect(result.calories, greaterThan(result.tdee));
    });

    test('sedentary with intense workout gets upgraded', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 75,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'intense training 5 days',
      );

      expect(result.activityLevelUsed, ActivityLevel.moderatelyActive);
    });

    test('handles gender other with default values', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.other,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: null,
        currentWeight: null,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: null,
        selectedGoal: HealthMode.maintainWeight,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.hasWarnings, true);
      expect(result.macros.calories, greaterThan(0));
    });

    test('recovers from absurd calorie request via min floor', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.female,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 160,
        currentWeight: 90,
        selectedPace: WeeklyPace.fast,
        desiredWeight: 45,
        selectedGoal: HealthMode.weightLoss,
        selectedActivityLevel: ActivityLevel.sedentary,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.keto,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'sedentary',
      );

      expect(result.macros.calories, greaterThanOrEqualTo(1200));
    });

    test('all goals work for male gender none', () {
      for (final goal in HealthMode.values) {
        final result = NutritionCalculator.calculateNutrition(
          gender: Gender.none,
          birthDate: DateTime(1990, 1, 1),
          currentHeight: 175,
          currentWeight: 75,
          selectedPace: WeeklyPace.moderate,
          desiredWeight: 70,
          selectedGoal: goal,
          selectedActivityLevel: ActivityLevel.sedentary,
          selectedSleepPattern: '7-8 hours',
          selectedObstacle: 'none',
          selectedDietPreference: DietPreference.none,
          selectedMeals: ['breakfast', 'lunch', 'dinner'],
          selectedWorkoutOption: 'sedentary',
        );

        expect(result.macros.calories, greaterThan(0),
            reason: 'Goal $goal should produce valid calories');
      }
    });

    test('all activity levels produce valid TDEE', () {
      for (final activity in ActivityLevel.values) {
        final bmr = 1600.0;
        final tdee = NutritionCalculator.calculateTDEE(bmr, activity);

        expect(tdee, greaterThan(bmr),
            reason: 'Activity $activity should give TDEE > BMR');
        expect(tdee, lessThan(bmr * 2),
            reason: 'Activity $activity should not double TDEE');
      }
    });

    test('fast pace aggressive deficit capped at 25 percent', () {
      final adjustment = NutritionCalculator.calculateGoalAdjustment(
        goal: HealthMode.weightLoss,
        pace: WeeklyPace.fast,
        tdee: 1000,
        currentWeight: 50,
        targetWeight: 45,
        gender: Gender.female,
        estimatedBodyFat: 15,
      );

      expect(adjustment.deficit, lessThanOrEqualTo(250));
    });

    test('adaptor respects minimum calorie floor', () {
      final smallFemalePlan = NutritionResult(
        calories: 1250,
        protein: 100,
        carbs: 80,
        fat: 50,
        fiber: 25,
        water: 2000,
        bmr: 1100,
        tdee: 1300,
        estimatedBodyFat: 25,
        goalAdjustmentDescription: 'Deficit',
        activityLevelUsed: ActivityLevel.sedentary,
        warnings: [],
        adjustments: [],
        macros: UserMacros(
          calories: 1250,
          protein: 100,
          carbs: 80,
          fat: 50,
          water: 2000,
          fiber: 25,
        ),
      );

      final adapted = NutritionAdaptor.recalculateForProgress(
        currentPlan: smallFemalePlan,
        actualWeeklyLoss: 0.1,
        expectedWeeklyLoss: 0.8,
      );

      expect(adapted.calories, greaterThanOrEqualTo(1200));
    });

    test('trying to gain muscle but target is lower than current', () {
      final result = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.moderate,
        desiredWeight: 70,
        selectedGoal: HealthMode.muscleGain,
        selectedActivityLevel: ActivityLevel.lightlyActive,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'light exercise 1-2 days',
      );

      expect(result.calories, greaterThan(result.tdee));
    });

    test('maintenance goal ignores pace setting', () {
      final resultSlow = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.fast,
        desiredWeight: 80,
        selectedGoal: HealthMode.maintainWeight,
        selectedActivityLevel: ActivityLevel.moderatelyActive,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'moderate exercise 3-4 days',
      );

      final resultNone = NutritionCalculator.calculateNutrition(
        gender: Gender.male,
        birthDate: DateTime(1990, 1, 1),
        currentHeight: 180,
        currentWeight: 80,
        selectedPace: WeeklyPace.none,
        desiredWeight: 80,
        selectedGoal: HealthMode.maintainWeight,
        selectedActivityLevel: ActivityLevel.moderatelyActive,
        selectedSleepPattern: '7-8 hours',
        selectedObstacle: 'none',
        selectedDietPreference: DietPreference.none,
        selectedMeals: ['breakfast', 'lunch', 'dinner'],
        selectedWorkoutOption: 'moderate exercise 3-4 days',
      );

      expect(resultSlow.calories, resultNone.calories);
    });
  });
}

NutritionResult _createMockNutritionResult({required int calories}) {
  int protein = (70 * 1.8).round();
  int fat = (calories * 0.3 / 9).round();
  int carbs = ((calories - protein * 4 - fat * 9) / 4).round();

  return NutritionResult(
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    fiber: 30,
    water: 2500,
    bmr: 1600,
    tdee: 2200,
    estimatedBodyFat: 20,
    goalAdjustmentDescription: 'Moderate deficit: -500 kcal',
    activityLevelUsed: ActivityLevel.moderatelyActive,
    warnings: [],
    adjustments: [],
    macros: UserMacros(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      water: 2500,
      fiber: 30,
    ),
  );
}
