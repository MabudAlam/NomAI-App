import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:NomAi/app/modules/Auth/views/sign_in_screen.dart';
import 'package:NomAi/app/utility/user_utility.dart';

///
/// # Nutrition Calculation Algorithm
///
/// This module calculates personalized daily calorie and macronutrient requirements
/// using a comprehensive multi-step algorithm that prioritizes safety and accuracy.
///
/// ## Algorithm Overview
///
/// ```
/// ┌─────────────────────────────────────────────────────────────────────────────┐
/// │                        NUTRITION CALCULATION PIPELINE                       │
/// └─────────────────────────────────────────────────────────────────────────────┘
///
///   INPUTS                    STEP 1              STEP 2              STEP 3
///   ──────                   ──────              ──────              ──────
///   • Gender            →  VALIDATE        →  CALCULATE BMR   →  CALCULATE TDEE
///   • Birth Date             INPUTS               (Katch-McArdle)     (TDEE = BMR ×
///   • Height                                                                       Activity)
///   • Current Weight         Weight: 25-300kg     Mifflin-St Jeor        Sedentary: 1.2
///   • Desired Weight         Height: 100-250cm    (default) or          Light:    1.375
///   • Goal (lose/maintain/   Age: 10-100          Katch-McArdle if     Moderate: 1.55
///     gain)                  Warnings for          body fat available   Very:    1.725
///   • Pace (slow/mod/         invalid data                                STEP 6
///     fast)                Defaults applied        STEP 5              BEHAVIORAL
///   • Activity Level                             →  APPLY SAFETY    →  ADJUSTMENT
///   • Sleep Pattern         GOAL ADJUSTMENT         FLOORS               + Carb boost
///   • Obstacles                                   Min Calories:         + Fat adjust
///   • Diet Preference                            Male: 1500           + Protein tweak
///   • Meals per Day          Fat Loss:           Female: 1200
///   • Behavioral             Slow: -300 kcal      Other: 1350         STEP 7
///     Preference              Moderate: -500        Deficit cap:       MACRO SPLIT
///                             Fast: -750/1000      25% of TDEE          Final
///           MAX 25% TDEE       25% TDEE                               Protein: 1.6-2.2g/kg
///           Lean Bulk: +300 kcal                                     Carb floor: 2g/kg
///           Faster Bulk: +500                                           (not keto)
///           Maintain: ±0                                               Fat: remainder
/// ```
///
/// ## Step-by-Step Process
///
/// ### Step 1: Input Validation
/// - **Weight**: Clamp to 25-300kg, default 70kg if null
/// - **Height**: Clamp to 100-250cm, default 170cm if null
/// - **Age**: Calculate from birthDate, clamp to 10-100 years
/// - All violations generate warnings returned with results
///
/// ### Step 2: BMR Calculation
/// ```dart
/// if (bodyFatPercentage != null) {
///   // True Katch-McArdle when body fat is known
///   LBM = weight × (1 - bodyFatPercentage / 100)
///   BMR = 370 + (21.6 × LBM)
/// } else {
///   // Mifflin-St Jeor (more accurate than estimated Katch-McArdle)
///   Male:   BMR = (10 × weight) + (6.25 × height) - (5 × age) + 5
///   Female: BMR = (10 × weight) + (6.25 × height) - (5 × age) - 161
/// }
/// ```
///
/// ### Step 3: TDEE Calculation
/// ```dart
/// TDEE = BMR × Activity Multiplier
/// Activity Multipliers:
///   • Sedentary: 1.2
///   • Lightly Active: 1.375
///   • Moderately Active: 1.55
///   • Very Active: 1.725
/// ```
///
/// ### Step 4: Goal Adjustment
/// ```dart
/// Fat Loss (Deficit):
///   • Slow: TDEE - 300 kcal
///   • Moderate: TDEE - 500 kcal
///   • Fast: TDEE - 750 kcal (or -1000 if body fat > 25%)
///   • DEFICIT CAP: 25% of TDEE maximum
///
/// Muscle Gain (Surplus):
///   • Lean bulk (body fat < 15%): TDEE + 300 kcal
///   • Normal bulk (body fat 15-25%): TDEE + 250 kcal
///   • Higher body fat (> 25%): TDEE + 200 kcal
///   • Fast pace: +500 kcal
///
/// Maintenance: TDEE ± 0
/// ```
///
/// ### Step 5: Safety Floors
/// ```dart
/// Minimum Calories:
///   • Male: 1500 kcal
///   • Female: 1200 kcal
///   • Other: 1350 kcal
/// Maximum Deficit: 25% of TDEE
/// ```
///
/// ### Step 6: Behavioral Adjustment
/// ```dart
/// // Applied to calories before macro calculation
/// Sleep Adjustment:
///   • < 6 hours: 0.97 (slight deficit - recovery impaired)
///   • 6-7 hours: 0.98
///   • 7-8 hours: 1.0
///   • > 8 hours: 1.02 (slight bonus - well rested)
///
/// Obstacle Adjustment:
///   • Low energy/fatigue: 0.95
///   • Stress eating: 0.97
///   • Late night snacking: 0.98
/// ```
///
/// ### Step 7: Macro Split
/// ```dart
/// Protein: 1.6-2.2 g/kg body weight (CAPPED at 2.2 g/kg max)
///   • Weight Loss: 2.0 g/kg
///   • Muscle Gain: 2.0 g/kg
///   • Maintenance: 1.6 g/kg
///
/// Fat: 20-30% of total calories
///   • Weight Loss: 30%
///   • Muscle Gain: 25%
///   • Keto: 55-65%
///
/// Carbs: Remaining calories after protein and fat
///   • Carb Floor: 2g per kg body weight (NOT applied to keto)
///   • Minimum floor: 50g (for non-keto)
///   • Keto minimum: 20g
///
/// Behavioral Macro Adjustment:
///   • Sweet tooth: +30g carbs
///   • Junk food preference: +20g carbs, -10g fat
///   • Lack of time: simplified protein approach
///   • High meal frequency (4+): +20g carbs
/// ```
///
/// ## Safety Features
///
/// 1. **Pace Clamping**: Fast pace auto-adjusted when:
///    - Target weight within 4kg → Moderate pace
///    - Target weight within 2kg → Slow pace
///    - Max safe loss: ~1% body weight per week
///
/// 2. **Goal Auto-Adjustment**:
///    - If desired weight within 2kg of current → Switch to maintenance
///    - Prevents unnecessary deficit for trivial weight changes
///
/// 3. **Activity Cross-Check**:
///    - Sedentary + intense workout description → Upgrade to Lightly/Moderately Active
///    - Prevents under-eating due to misreported activity
///
/// 4. **Sleep & Obstacle Adjustments**:
///    - Poor sleep (< 6 hours): 0-5% calorie reduction
///    - Stress eating obstacle: 3% reduction
///    - Late night snacking: 2% reduction
///
/// 5. **Adaptation Feedback Loop**:
///    - `NutritionAdaptor.recalculateForProgress()` compares actual vs expected weight loss
///    - Adjusts calories ±100-200 kcal based on discrepancy
///
/// ## Edge Cases Handled
///
/// | Case | Handling |
/// |------|----------|
/// | Null weight/height | Use defaults (70kg, 170cm) with warning |
/// | Zero or negative weight | Clamp to minimum 25kg |
/// | Extreme height | Clamp to 100-250cm range |
/// | Future birthdate | Use default age 30 with warning |
/// | Very old birthdate | Clamp age to 100 with warning |
/// | Target > Current (weight loss) | Proceed with deficit anyway |
/// | Desired weight unrealistic | Pace clamped, min calories enforced |
/// | Small female + aggressive deficit | Floor at 1200 kcal |
/// | Empty meals list | Default to 3 meals |
/// | Many meals (> 6) | Cap at 6 for calculations |
/// | Unknown diet/sleep/obstacle | Treat as neutral (1.0 factor) |
/// | Protein exceeds 2.2g/kg | Capped at 2.2g/kg |
/// | Carbs too low (non-keto) | Floor at 2g/kg body weight |
/// | Sweet tooth preference | Carb boost +30g |
/// | Junk food preference | Carb +20g, fat -10g |
/// | Poor sleep (< 6 hours) | 3% calorie reduction |
///
/// ## Usage
///
/// ```dart
/// final result = NutritionCalculator.calculateNutrition(
///   gender: Gender.male,
///   birthDate: DateTime(1990, 1, 1),
///   currentHeight: 180,
///   currentWeight: 80,
///   selectedPace: WeeklyPace.moderate,
///   desiredWeight: 75,
///   selectedGoal: HealthMode.weightLoss,
///   selectedActivityLevel: ActivityLevel.moderatelyActive,
///   selectedSleepPattern: '7-8 hours',
///   selectedObstacle: 'none',
///   selectedDietPreference: DietPreference.none,
///   selectedMeals: ['breakfast', 'lunch', 'dinner'],
///   selectedWorkoutOption: 'moderate exercise 3-4 days',
/// );
///
/// print('Daily Calories: ${result.calories}');
/// print('Protein: ${result.protein}g');
/// print('Warnings: ${result.warnings}');
/// print('Adjustments: ${result.adjustments}');
/// ```
///

class DailyCalorieRequired extends StatefulWidget {
  final UserBasicInfo userBasicInfo;

  const DailyCalorieRequired({
    super.key,
    required this.userBasicInfo,
  });

  @override
  State<DailyCalorieRequired> createState() => _DailyCalorieRequiredState();
}

class _DailyCalorieRequiredState extends State<DailyCalorieRequired>
    with SingleTickerProviderStateMixin {
  bool _isCalculating = true;
  double _progress = 0.0;
  late Timer _timer;
  NutritionResult? _nutritionResult;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _startCalculation();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCalculation() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.01;
        } else {
          _timer.cancel();
          _isCalculating = false;
          _animationController.forward();
        }
      });
    });

    _calculateNutrition();
  }

  void _calculateNutrition() {
    final user = widget.userBasicInfo;

    _nutritionResult = NutritionCalculator.calculateNutrition(
      gender: user.selectedGender,
      birthDate: user.birthDate,
      currentHeight: user.currentHeight,
      currentWeight: user.currentWeight,
      selectedPace: user.selectedPace,
      desiredWeight: user.desiredWeight,
      selectedGoal: user.selectedGoal,
      selectedActivityLevel: user.selectedActivityLevel,
      selectedSleepPattern: user.selectedSleepPattern,
      selectedObstacle: user.selectedObstacle,
      selectedDietPreference: _parseDietPreference(user.selectedDiet),
      selectedMeals: user.selectedMeals,
      selectedWorkoutOption: user.selectedWorkoutOption,
    );
  }

  DietPreference _parseDietPreference(String diet) {
    switch (diet.toLowerCase()) {
      case 'vegetarian':
        return DietPreference.vegetarian;
      case 'vegan':
        return DietPreference.vegan;
      case 'keto':
        return DietPreference.keto;
      case 'paleo':
        return DietPreference.paleo;
      default:
        return DietPreference.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealAIColors.switchWhiteColor,
      body: SafeArea(
        child: _isCalculating ? _buildCalculatingView() : _buildResultsView(),
      ),
    );
  }

  Widget _buildCalculatingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Creating your plan",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: MealAIColors.blackText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: MealAIColors.greyLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    MealAIColors.selectedTile,
                  ),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 10),
                Text(
                  "${(_progress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MealAIColors.blackText,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _getProgressMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    color: MealAIColors.blackText.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getProgressMessage() {
    if (_progress < 0.3) {
      return "Analyzing your metrics...";
    } else if (_progress < 0.6) {
      return "Calculating nutritional needs...";
    } else if (_progress < 0.9) {
      return "Finalizing your plan...";
    } else {
      return "Almost ready!";
    }
  }

  Widget _buildResultsView() {
    final macros = _nutritionResult!.macros;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Your Nutrition Plan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MealAIColors.blackText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getHealthModeText(),
              style: TextStyle(
                fontSize: 16,
                color: MealAIColors.blackText.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 40),
            _buildInfoCard(
              title: "Daily Calories",
              value: "${macros.calories}",
              unit: "kcal",
            ),
            const SizedBox(height: 30),
            Text(
              "Macronutrients",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MealAIColors.blackText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMacroCard(
                    "Protein",
                    macros.protein,
                    "g",
                    _calculatePercentage(macros.protein * 4, macros.calories),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildMacroCard(
                    "Carbs",
                    macros.carbs,
                    "g",
                    _calculatePercentage(macros.carbs * 4, macros.calories),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildMacroCard(
                    "Fat",
                    macros.fat,
                    "g",
                    _calculatePercentage(macros.fat * 9, macros.calories),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "Recommendations",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MealAIColors.blackText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildRecommendationCard(
                    "Water",
                    macros.water,
                    "ml",
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildRecommendationCard(
                    "Fiber",
                    macros.fiber,
                    "g",
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  UserBasicInfo updatedUserBasicInfo =
                      widget.userBasicInfo.copyWith(
                    userMacros: _nutritionResult!.macros,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider<SignInBloc>(
                        create: (context) => SignInBloc(
                            userRepository: context
                                .read<AuthenticationBloc>()
                                .userRepository),
                        child: SignInScreen(
                          user: updatedUserBasicInfo,
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MealAIColors.selectedTile,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MealAIColors.whiteText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getHealthModeText() {
    switch (widget.userBasicInfo.selectedGoal) {
      case HealthMode.weightLoss:
        return "Weight Loss Plan";
      case HealthMode.muscleGain:
        return "Muscle Gain Plan";
      case HealthMode.maintainWeight:
        return "Weight Maintenance Plan";
      default:
        return "Personalized Plan";
    }
  }

  double _calculatePercentage(int macroCalories, int totalCalories) {
    return macroCalories / totalCalories;
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MealAIColors.selectedTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            size: 40,
            color: MealAIColors.whiteText,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: MealAIColors.whiteText,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: MealAIColors.whiteText,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 16,
                        color: MealAIColors.whiteText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(
    String title,
    int value,
    String unit,
    double percentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: MealAIColors.lightGreyTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: MealAIColors.blackText,
                ),
              ),
              Text(
                "${(percentage * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: MealAIColors.blackText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: MealAIColors.stepperColor,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(MealAIColors.selectedTile),
                  strokeWidth: 8,
                ),
              ),
              Column(
                children: [
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MealAIColors.blackText,
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: MealAIColors.blackText.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    String title,
    int value,
    String unit,
  ) {
    IconData icon = title == "Water" ? Icons.water_drop : Icons.grass;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: MealAIColors.lightGreyTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MealAIColors.switchWhiteColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: MealAIColors.blackText,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MealAIColors.blackText,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MealAIColors.blackText,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        color: MealAIColors.blackText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
