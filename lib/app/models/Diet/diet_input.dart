class DietInput {
  final String userId;
  final int calories;
  final int protein;
  final int carbs;
  final int fiber;
  final int fat;
  final List<String>? dietaryPreferences;
  final List<String>? allergies;
  final List<String>? selectedGoals;
  final List<String>? dislikedFoods;
  final List<String>? anyDiseases;
  final String prompt;

  DietInput({
    required this.userId,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fiber,
    required this.fat,
    this.dietaryPreferences,
    this.allergies,
    this.selectedGoals,
    this.dislikedFoods,
    this.anyDiseases,
    required this.prompt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fiber': fiber,
        'fat': fat,
        if (dietaryPreferences != null) 'dietaryPreferences': dietaryPreferences,
        if (allergies != null) 'allergies': allergies,
        if (selectedGoals != null) 'selectedGoals': selectedGoals,
        if (dislikedFoods != null) 'dislikedFoods': dislikedFoods,
        if (anyDiseases != null) 'anyDiseases': anyDiseases,
        'prompt': prompt,
      };
}
