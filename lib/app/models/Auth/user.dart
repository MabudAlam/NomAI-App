import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum Gender { male, female, other, none }

enum WeeklyPace { slow, moderate, fast, none }

enum HealthMode {
  none,
  weightLoss,
  muscleGain,
  maintainWeight,
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  none
}

enum Goal { loseWeight, maintainWeight, gainMuscle }

enum DietPreference { none, vegetarian, vegan, keto, paleo }

extension GenderExtension on Gender {
  String toSimpleText() {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.none:
        return 'Prefer not to say';
    }
  }

  String toJson() => name;

  static Gender fromJson(String json) {
    return Gender.values.firstWhere(
      (e) => e.name == json,
      orElse: () => Gender.none,
    );
  }
}

extension WeeklyPaceExtension on WeeklyPace {
  String toSimpleText() {
    switch (this) {
      case WeeklyPace.slow:
        return 'Slow & Steady';
      case WeeklyPace.moderate:
        return 'Moderate Progress';
      case WeeklyPace.fast:
        return 'Fast Track';
      case WeeklyPace.none:
        return 'Not Specified';
    }
  }

  String toJson() => name;

  static WeeklyPace fromJson(String json) {
    return WeeklyPace.values.firstWhere(
      (e) => e.name == json,
      orElse: () => WeeklyPace.none,
    );
  }
}

extension HealthModeExtension on HealthMode {
  String toSimpleText() {
    switch (this) {
      case HealthMode.weightLoss:
        return 'Lose Weight';
      case HealthMode.muscleGain:
        return 'Build Muscle';
      case HealthMode.maintainWeight:
        return 'Maintain Current Weight';
      case HealthMode.none:
        return 'Not Specified';
    }
  }

  String toJson() => name;

  static HealthMode fromJson(String json) {
    return HealthMode.values.firstWhere(
      (e) => e.name == json,
      orElse: () => HealthMode.none,
    );
  }
}

extension ActivityLevelExtension on ActivityLevel {
  String toSimpleText() {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.none:
        return '';
    }
  }

  String toJson() => name;

  static ActivityLevel fromJson(String json) {
    return ActivityLevel.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ActivityLevel.sedentary,
    );
  }
}

extension GoalExtension on Goal {
  String toSimpleText() {
    switch (this) {
      case Goal.loseWeight:
        return 'Lose Weight';
      case Goal.maintainWeight:
        return 'Maintain Weight';
      case Goal.gainMuscle:
        return 'Gain Muscle';
    }
  }

  String toJson() => name;

  static Goal fromJson(String json) {
    return Goal.values.firstWhere(
      (e) => e.name == json,
      orElse: () => Goal.maintainWeight,
    );
  }
}

extension DietPreferenceExtension on DietPreference {
  String toSimpleText() {
    switch (this) {
      case DietPreference.none:
        return 'No Preference';
      case DietPreference.vegetarian:
        return 'Vegetarian';
      case DietPreference.vegan:
        return 'Vegan';
      case DietPreference.keto:
        return 'Keto';
      case DietPreference.paleo:
        return 'Paleo';
    }
  }

  String toJson() => name;

  static DietPreference fromJson(String json) {
    return DietPreference.values.firstWhere(
      (e) => e.name == json,
      orElse: () => DietPreference.none,
    );
  }
}

// ---------------------------------------------------------------------------
// UserModel
// ---------------------------------------------------------------------------

class UserModel extends Equatable {
  final String userId;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserBasicInfo? userInfo;

  const UserModel({
    required this.userId,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.userInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_info': userInfo?.toJson(),
    };
  }

  Map<String, dynamic> toEntity() => toJson();

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      userInfo: json['user_info'] != null
          ? UserBasicInfo.fromJson(json['user_info'] as Map<String, dynamic>)
          : null,
    );
  }

  static UserModel fromEntity(Map<String, dynamic> entity) => fromJson(entity);

  UserModel copyWith({
    String? userId,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserBasicInfo? userInfo,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userInfo: userInfo ?? this.userInfo,
    );
  }

  UserModel.empty()
      : this(
          userId: '',
          email: '',
          name: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

  @override
  List<Object?> get props => [
        userId,
        email,
        name,
        photoUrl,
        phoneNumber,
        createdAt,
        updatedAt,
        userInfo,
      ];
}

// ---------------------------------------------------------------------------
// UserBasicInfo
// ---------------------------------------------------------------------------

class UserBasicInfo {
  final Gender selectedGender;
  final int age;
  final WeeklyPace selectedPace;
  final DateTime birthDate;
  final double? currentHeight;
  final double? currentWeight;
  final double? desiredWeight;
  final String selectedHaveYouTriedApps;
  final String selectedWorkoutOption;
  final HealthMode selectedGoal;
  final String selectedObstacle;
  final String selectedDietKnowledge;
  final List<String> selectedMeals;
  final String selectedBodySatisfaction;
  final String selectedDiet;
  final String selectedMealTiming;
  final TimeOfDay? firstMealOfDay;
  final TimeOfDay? secondMealOfDay;
  final TimeOfDay? thirdMealOfDay;
  final String selectedMacronutrientKnowledge;
  final List<String> selectedAllergies;
  final String selectedEatOut;
  final String selectedHomeCooked;
  final ActivityLevel selectedActivityLevel;
  final String selectedSleepPattern;
  final UserMacros userMacros;

  UserBasicInfo({
    required this.selectedGender,
    required this.birthDate,
    required this.currentHeight,
    required this.currentWeight,
    required this.desiredWeight,
    required this.selectedHaveYouTriedApps,
    required this.selectedWorkoutOption,
    required this.selectedGoal,
    required this.selectedPace,
    required this.selectedObstacle,
    required this.selectedDietKnowledge,
    required this.selectedMeals,
    required this.selectedBodySatisfaction,
    required this.selectedDiet,
    required this.selectedMealTiming,
    required this.firstMealOfDay,
    required this.secondMealOfDay,
    required this.thirdMealOfDay,
    required this.selectedMacronutrientKnowledge,
    required this.selectedAllergies,
    required this.selectedEatOut,
    required this.selectedHomeCooked,
    required this.selectedActivityLevel,
    required this.selectedSleepPattern,
    required this.userMacros,
    required this.age,
  });

  Map<String, dynamic> toJson() {
    return {
      'gender': selectedGender.toJson(),
      'age': age,
      'birth_date': birthDate.toIso8601String(),
      'height': (currentHeight ?? 0.0).toString(),
      'weight': (currentWeight ?? 0.0).toString(),
      'target_weight': (desiredWeight ?? 0.0).toString(),
      'previous_apps_experience': selectedHaveYouTriedApps,
      'workout_preference': selectedWorkoutOption,
      'health_goal': selectedGoal.toJson(),
      'weekly_pace': selectedPace.toJson(),
      'main_obstacle': selectedObstacle,
      'diet_knowledge_level': selectedDietKnowledge,
      'preferred_meals': selectedMeals,
      'body_satisfaction': selectedBodySatisfaction,
      'diet_type': selectedDiet,
      'meal_timing_preference': selectedMealTiming,
      'first_meal_time': _timeOfDayToString(firstMealOfDay),
      'second_meal_time': _timeOfDayToString(secondMealOfDay),
      'third_meal_time': _timeOfDayToString(thirdMealOfDay),
      'macro_knowledge_level': selectedMacronutrientKnowledge,
      'allergies': selectedAllergies,
      'eating_out_frequency': selectedEatOut,
      'home_cooking_frequency': selectedHomeCooked,
      'activity_level': selectedActivityLevel.toJson(),
      'sleep_pattern': selectedSleepPattern,
      'macros': userMacros.toJson(),
    };
  }

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) {
    return UserBasicInfo(
      selectedGender: GenderExtension.fromJson(json['gender'] as String? ?? 'none'),
      age: (json['age'] as num?)?.toInt() ?? 0,
      birthDate: DateTime.parse(json['birth_date'] as String),
      currentHeight: _parseDouble(json['height']),
      currentWeight: _parseDouble(json['weight']),
      desiredWeight: _parseDouble(json['target_weight']),
      selectedHaveYouTriedApps: json['previous_apps_experience'] as String? ?? '',
      selectedWorkoutOption: json['workout_preference'] as String? ?? '',
      selectedGoal: HealthModeExtension.fromJson(json['health_goal'] as String? ?? 'none'),
      selectedPace: WeeklyPaceExtension.fromJson(json['weekly_pace'] as String? ?? 'none'),
      selectedObstacle: json['main_obstacle'] as String? ?? '',
      selectedDietKnowledge: json['diet_knowledge_level'] as String? ?? '',
      selectedMeals: List<String>.from(json['preferred_meals'] as List? ?? []),
      selectedBodySatisfaction: json['body_satisfaction'] as String? ?? '',
      selectedDiet: json['diet_type'] as String? ?? '',
      selectedMealTiming: json['meal_timing_preference'] as String? ?? '',
      firstMealOfDay: _timeOfDayFromString(json['first_meal_time'] as String?),
      secondMealOfDay: _timeOfDayFromString(json['second_meal_time'] as String?),
      thirdMealOfDay: _timeOfDayFromString(json['third_meal_time'] as String?),
      selectedMacronutrientKnowledge: json['macro_knowledge_level'] as String? ?? '',
      selectedAllergies: List<String>.from(json['allergies'] as List? ?? []),
      selectedEatOut: json['eating_out_frequency'] as String? ?? '',
      selectedHomeCooked: json['home_cooking_frequency'] as String? ?? '',
      selectedActivityLevel: ActivityLevelExtension.fromJson(
          json['activity_level'] as String? ?? 'sedentary'),
      selectedSleepPattern: json['sleep_pattern'] as String? ?? '',
      userMacros: UserMacros.fromJson(json['macros'] as Map<String, dynamic>? ?? {}),
    );
  }

  static String _timeOfDayToString(TimeOfDay? time) {
    if (time == null) return '00:00';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay _timeOfDayFromString(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  UserBasicInfo copyWith({
    Gender? selectedGender,
    int? age,
    WeeklyPace? selectedPace,
    DateTime? birthDate,
    double? currentHeight,
    double? currentWeight,
    double? desiredWeight,
    String? selectedHaveYouTriedApps,
    String? selectedWorkoutOption,
    HealthMode? selectedGoal,
    String? selectedObstacle,
    String? selectedDietKnowledge,
    List<String>? selectedMeals,
    String? selectedBodySatisfaction,
    String? selectedDiet,
    String? selectedMealTiming,
    TimeOfDay? firstMealOfDay,
    TimeOfDay? secondMealOfDay,
    TimeOfDay? thirdMealOfDay,
    String? selectedMacronutrientKnowledge,
    List<String>? selectedAllergies,
    String? selectedEatOut,
    String? selectedHomeCooked,
    ActivityLevel? selectedActivityLevel,
    String? selectedSleepPattern,
    UserMacros? userMacros,
  }) {
    return UserBasicInfo(
      selectedGender: selectedGender ?? this.selectedGender,
      age: age ?? this.age,
      selectedPace: selectedPace ?? this.selectedPace,
      birthDate: birthDate ?? this.birthDate,
      currentHeight: currentHeight ?? this.currentHeight,
      currentWeight: currentWeight ?? this.currentWeight,
      desiredWeight: desiredWeight ?? this.desiredWeight,
      selectedHaveYouTriedApps: selectedHaveYouTriedApps ?? this.selectedHaveYouTriedApps,
      selectedWorkoutOption: selectedWorkoutOption ?? this.selectedWorkoutOption,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      selectedObstacle: selectedObstacle ?? this.selectedObstacle,
      selectedDietKnowledge: selectedDietKnowledge ?? this.selectedDietKnowledge,
      selectedMeals: selectedMeals ?? this.selectedMeals,
      selectedBodySatisfaction: selectedBodySatisfaction ?? this.selectedBodySatisfaction,
      selectedDiet: selectedDiet ?? this.selectedDiet,
      selectedMealTiming: selectedMealTiming ?? this.selectedMealTiming,
      firstMealOfDay: firstMealOfDay ?? this.firstMealOfDay,
      secondMealOfDay: secondMealOfDay ?? this.secondMealOfDay,
      thirdMealOfDay: thirdMealOfDay ?? this.thirdMealOfDay,
      selectedMacronutrientKnowledge: selectedMacronutrientKnowledge ?? this.selectedMacronutrientKnowledge,
      selectedAllergies: selectedAllergies ?? this.selectedAllergies,
      selectedEatOut: selectedEatOut ?? this.selectedEatOut,
      selectedHomeCooked: selectedHomeCooked ?? this.selectedHomeCooked,
      selectedActivityLevel: selectedActivityLevel ?? this.selectedActivityLevel,
      selectedSleepPattern: selectedSleepPattern ?? this.selectedSleepPattern,
      userMacros: userMacros ?? this.userMacros,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

// ---------------------------------------------------------------------------
// UserMacros
// ---------------------------------------------------------------------------

class UserMacros {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int water;
  final int fiber;

  UserMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.water = 0,
    this.fiber = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'daily_calories': calories,
      'daily_protein': protein,
      'daily_carbs': carbs,
      'daily_fat': fat,
      'daily_water': water,
      'daily_fiber': fiber,
    };
  }

  factory UserMacros.fromJson(Map<String, dynamic> json) {
    return UserMacros(
      calories: (json['daily_calories'] as num?)?.toInt() ?? 0,
      protein: (json['daily_protein'] as num?)?.toInt() ?? 0,
      carbs: (json['daily_carbs'] as num?)?.toInt() ?? 0,
      fat: (json['daily_fat'] as num?)?.toInt() ?? 0,
      water: (json['daily_water'] as num?)?.toInt() ?? 0,
      fiber: (json['daily_fiber'] as num?)?.toInt() ?? 0,
    );
  }
}