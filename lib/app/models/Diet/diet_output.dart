class NutritionInfo {
  final String? name;
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fiber;
  final int? fat;
  final int? healthScore;
  final String? healthComments;

  NutritionInfo({
    this.name,
    this.calories,
    this.protein,
    this.carbs,
    this.fiber,
    this.fat,
    this.healthScore,
    this.healthComments,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) => NutritionInfo(
        name: json['name'],
        calories: json['calories'],
        protein: json['protein'],
        carbs: json['carbs'],
        fiber: json['fiber'],
        fat: json['fat'],
        healthScore: json['healthScore'],
        healthComments: json['healthComments'],
      );

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (calories != null) 'calories': calories,
        if (protein != null) 'protein': protein,
        if (carbs != null) 'carbs': carbs,
        if (fiber != null) 'fiber': fiber,
        if (fat != null) 'fat': fat,
        if (healthScore != null) 'healthScore': healthScore,
        if (healthComments != null) 'healthComments': healthComments,
      };
}

class NutritionResponseModel {
  final String? message;
  final String? imageUrl;
  final String? foodName;
  final String? portion;
  final double? portionSize;
  final int? confidenceScore;
  final List<NutritionInfo>? ingredients;
  final List<dynamic>? primaryConcerns;
  final List<dynamic>? suggestAlternatives;
  final int? overallHealthScore;
  final String? overallHealthComments;

  NutritionResponseModel({
    this.message,
    this.imageUrl,
    this.foodName,
    this.portion,
    this.portionSize,
    this.confidenceScore,
    this.ingredients,
    this.primaryConcerns,
    this.suggestAlternatives,
    this.overallHealthScore,
    this.overallHealthComments,
  });

  factory NutritionResponseModel.fromJson(Map<String, dynamic> json) =>
      NutritionResponseModel(
        message: json['message'],
        imageUrl: json['imageUrl'],
        foodName: json['foodName'],
        portion: json['portion'],
        portionSize: (json['portionSize'] as num?)?.toDouble(),
        confidenceScore: json['confidenceScore'],
        ingredients: json['ingredients'] == null
            ? null
            : (json['ingredients'] as List)
                .map((x) => NutritionInfo.fromJson(x))
                .toList(),
        primaryConcerns: json['primaryConcerns'],
        suggestAlternatives: json['suggestAlternatives'],
        overallHealthScore: json['overallHealthScore'],
        overallHealthComments: json['overallHealthComments'],
      );

  Map<String, dynamic> toJson() => {
        if (message != null) 'message': message,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (foodName != null) 'foodName': foodName,
        if (portion != null) 'portion': portion,
        if (portionSize != null) 'portionSize': portionSize,
        if (confidenceScore != null) 'confidenceScore': confidenceScore,
        if (ingredients != null)
          'ingredients': ingredients!.map((x) => x.toJson()).toList(),
        if (primaryConcerns != null) 'primaryConcerns': primaryConcerns,
        if (suggestAlternatives != null)
          'suggestAlternatives': suggestAlternatives,
        if (overallHealthScore != null)
          'overallHealthScore': overallHealthScore,
        if (overallHealthComments != null)
          'overallHealthComments': overallHealthComments,
      };
}

class MealsStructure {
  final NutritionResponseModel? breakfast;
  final NutritionResponseModel? lunch;
  final NutritionResponseModel? dinner;
  final List<NutritionResponseModel>? snacks;

  MealsStructure({
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snacks,
  });

  factory MealsStructure.fromJson(Map<String, dynamic> json) => MealsStructure(
        breakfast: json['breakfast'] == null
            ? null
            : NutritionResponseModel.fromJson(json['breakfast']),
        lunch:
            json['lunch'] == null ? null : NutritionResponseModel.fromJson(json['lunch']),
        dinner:
            json['dinner'] == null ? null : NutritionResponseModel.fromJson(json['dinner']),
        snacks: json['snacks'] == null
            ? null
            : (json['snacks'] as List)
                .map((x) => NutritionResponseModel.fromJson(x))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        if (breakfast != null) 'breakfast': breakfast!.toJson(),
        if (lunch != null) 'lunch': lunch!.toJson(),
        if (dinner != null) 'dinner': dinner!.toJson(),
        if (snacks != null) 'snacks': snacks!.map((x) => x.toJson()).toList(),
      };
}

class NutritionSummary {
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fiber;
  final int? fat;

  NutritionSummary({
    this.calories,
    this.protein,
    this.carbs,
    this.fiber,
    this.fat,
  });

  factory NutritionSummary.fromJson(Map<String, dynamic> json) =>
      NutritionSummary(
        calories: json['calories'],
        protein: json['protein'],
        carbs: json['carbs'],
        fiber: json['fiber'],
        fat: json['fat'],
      );

  Map<String, dynamic> toJson() => {
        if (calories != null) 'calories': calories,
        if (protein != null) 'protein': protein,
        if (carbs != null) 'carbs': carbs,
        if (fiber != null) 'fiber': fiber,
        if (fat != null) 'fat': fat,
      };
}

class DailyDietEntry {
  final int? dayIndex;
  final String? dayName;
  final MealsStructure? meals;
  final NutritionSummary? totalNutrition;
  final NutritionResponseModel? cheatMealOfTheDay;

  DailyDietEntry({
    this.dayIndex,
    this.dayName,
    this.meals,
    this.totalNutrition,
    this.cheatMealOfTheDay,
  });

  factory DailyDietEntry.fromJson(Map<String, dynamic> json) => DailyDietEntry(
        dayIndex: json['dayIndex'],
        dayName: json['dayName'],
        meals: json['meals'] == null ? null : MealsStructure.fromJson(json['meals']),
        totalNutrition: json['totalNutrition'] == null
            ? null
            : NutritionSummary.fromJson(json['totalNutrition']),
        cheatMealOfTheDay: json['cheatMealOfTheDay'] == null
            ? null
            : NutritionResponseModel.fromJson(json['cheatMealOfTheDay']),
      );

  Map<String, dynamic> toJson() => {
        if (dayIndex != null) 'dayIndex': dayIndex,
        if (dayName != null) 'dayName': dayName,
        if (meals != null) 'meals': meals!.toJson(),
        if (totalNutrition != null) 'totalNutrition': totalNutrition!.toJson(),
        if (cheatMealOfTheDay != null)
          'cheatMealOfTheDay': cheatMealOfTheDay!.toJson(),
      };
}

class WeeklyDietOutput {
  final String? dietId;
  final String? userId;
  final String? weekStartDate;
  final String? weekEndDate;
  final String? status;
  final List<DailyDietEntry>? dailyDiets;
  final NutritionSummary? totalWeeklyNutrition;
  final String? createdAt;
  final String? updatedAt;

  WeeklyDietOutput({
    this.dietId,
    this.userId,
    this.weekStartDate,
    this.weekEndDate,
    this.status,
    this.dailyDiets,
    this.totalWeeklyNutrition,
    this.createdAt,
    this.updatedAt,
  });

  factory WeeklyDietOutput.fromJson(Map<String, dynamic> json) =>
      WeeklyDietOutput(
        dietId: json['dietId'],
        userId: json['userId'],
        weekStartDate: json['weekStartDate'],
        weekEndDate: json['weekEndDate'],
        status: json['status'],
        dailyDiets: json['dailyDiets'] == null
            ? null
            : (json['dailyDiets'] as List)
                .map((x) => DailyDietEntry.fromJson(x))
                .toList(),
        totalWeeklyNutrition: json['totalWeeklyNutrition'] == null
            ? null
            : NutritionSummary.fromJson(json['totalWeeklyNutrition']),
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );

  Map<String, dynamic> toJson() => {
        if (dietId != null) 'dietId': dietId,
        if (userId != null) 'userId': userId,
        if (weekStartDate != null) 'weekStartDate': weekStartDate,
        if (weekEndDate != null) 'weekEndDate': weekEndDate,
        if (status != null) 'status': status,
        if (dailyDiets != null)
          'dailyDiets': dailyDiets!.map((x) => x.toJson()).toList(),
        if (totalWeeklyNutrition != null)
          'totalWeeklyNutrition': totalWeeklyNutrition!.toJson(),
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };
}

class DietHistoryResponse {
  final List<WeeklyDietOutput>? diets;
  final int? total;
  final int? limit;
  final int? offset;

  DietHistoryResponse({
    this.diets,
    this.total,
    this.limit,
    this.offset,
  });

  factory DietHistoryResponse.fromJson(Map<String, dynamic> json) =>
      DietHistoryResponse(
        diets: json['diets'] == null
            ? null
            : (json['diets'] as List)
                .map((x) => WeeklyDietOutput.fromJson(x))
                .toList(),
        total: json['total'],
        limit: json['limit'],
        offset: json['offset'],
      );
}

class SuggestAlternativesResponse {
  final List<NutritionResponseModel>? alternatives;
  final NutritionResponseModel? currentMeal;

  SuggestAlternativesResponse({
    this.alternatives,
    this.currentMeal,
  });

  factory SuggestAlternativesResponse.fromJson(Map<String, dynamic> json) =>
      SuggestAlternativesResponse(
        alternatives: json['alternatives'] == null
            ? null
            : (json['alternatives'] as List)
                .map((x) => NutritionResponseModel.fromJson(x))
                .toList(),
        currentMeal: json['currentMeal'] == null
            ? null
            : NutritionResponseModel.fromJson(json['currentMeal']),
      );
}