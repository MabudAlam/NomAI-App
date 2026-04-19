import 'package:equatable/equatable.dart';

class ChatPostModel extends Equatable {
  final String? text;
  final String? userId;
  final String? imageUrl;
  final String? imageData;
  final DateTime? localTime;
  final List<String>? dietaryPreferences;
  final List<String>? allergies;
  final List<String>? selectedGoals;

  const ChatPostModel({
    this.text,
    this.userId,
    this.imageUrl,
    this.imageData,
    this.localTime,
    this.dietaryPreferences,
    this.allergies,
    this.selectedGoals,
  });

  factory ChatPostModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChatPostModel();
    return ChatPostModel(
      text: json['text'] as String?,
      userId: json['user_id'] as String?,
      imageUrl: json['image_url'] as String?,
      imageData: json['image_data'] as String?,
      localTime: json['local_time'] != null
          ? DateTime.tryParse(json['local_time'] as String)
          : null,
      dietaryPreferences: json['dietary_preferences'] is List
          ? List<String>.from(json['dietary_preferences'] as List)
          : null,
      allergies: json['allergies'] is List
          ? List<String>.from(json['allergies'] as List)
          : null,
      selectedGoals: json['selected_goals'] is List
          ? List<String>.from(json['selected_goals'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'user_id': userId,
      'image_url': imageUrl,
      'image_data': imageData,
      'local_time': localTime?.toIso8601String(),
      'dietary_preferences': dietaryPreferences,
      'allergies': allergies,
      'selected_goals': selectedGoals,
    };
  }

  @override
  List<Object?> get props => [
        text,
        userId,
        imageUrl,
        imageData,
        localTime,
        dietaryPreferences,
        allergies,
        selectedGoals,
      ];
}

class ChatOutputModel extends Equatable {
  final String? aiAnswer;
  final String? messageId;
  final String? userMessageId;
  final NutritionData? nutritionData;
  final List<String>? toolsUsed;

  const ChatOutputModel({
    this.aiAnswer,
    this.messageId,
    this.userMessageId,
    this.nutritionData,
    this.toolsUsed,
  });

  factory ChatOutputModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChatOutputModel();
    return ChatOutputModel(
      aiAnswer: json['ai_answer'] as String?,
      messageId: json['message_id'] as String?,
      userMessageId: json['user_message_id'] as String?,
      nutritionData: json['nutrition_data'] != null
          ? NutritionData.fromJson(
              json['nutrition_data'] as Map<String, dynamic>?)
          : null,
      toolsUsed: json['tools_used'] is List
          ? List<String>.from(json['tools_used'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ai_answer': aiAnswer,
      'message_id': messageId,
      'user_message_id': userMessageId,
      'nutrition_data': nutritionData?.toJson(),
      'tools_used': toolsUsed,
    };
  }

  @override
  List<Object?> get props => [aiAnswer, messageId, userMessageId, nutritionData, toolsUsed];
}

class NutritionData extends Equatable {
  final ResponseData? response;
  final int? status;
  final String? message;
  final Metadata? metadata;

  const NutritionData({
    this.response,
    this.status,
    this.message,
    this.metadata,
  });

  factory NutritionData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NutritionData();
    return NutritionData(
      response: json['response'] != null
          ? ResponseData.fromJson(json['response'] as Map<String, dynamic>?)
          : null,
      status: json['status'] as int?,
      message: json['message'] as String?,
      metadata: json['metadata'] != null
          ? Metadata.fromJson(json['metadata'] as Map<String, dynamic>?)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response?.toJson(),
      'status': status,
      'message': message,
      'metadata': metadata?.toJson(),
    };
  }

  @override
  List<Object?> get props => [response, status, message, metadata];
}

class ResponseData extends Equatable {
  final String? message;
  final String? imageUrl;
  final String? foodName;
  final String? portion;
  final double? portionSize;
  final int? confidenceScore;
  final List<Ingredient>? ingredients;
  final List<PrimaryConcern>? primaryConcerns;
  final List<SuggestAlternative>? suggestAlternatives;
  final int? overallHealthScore;
  final String? overallHealthComments;

  const ResponseData({
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

  factory ResponseData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ResponseData();
    return ResponseData(
      message: json['message'] as String?,
      imageUrl: json['imageUrl'] as String?,
      foodName: json['foodName'] as String?,
      portion: json['portion'] as String?,
      portionSize: (json['portionSize'] as num?)?.toDouble(),
      confidenceScore: json['confidenceScore'] as int?,
      ingredients: json['ingredients'] is List
          ? (json['ingredients'] as List)
              .map((e) => Ingredient.fromJson(e as Map<String, dynamic>?))
              .toList()
          : null,
      primaryConcerns: json['primaryConcerns'] is List
          ? (json['primaryConcerns'] as List)
              .map((e) => PrimaryConcern.fromJson(e as Map<String, dynamic>?))
              .toList()
          : null,
      suggestAlternatives: json['suggestAlternatives'] is List
          ? (json['suggestAlternatives'] as List)
              .map((e) =>
                  SuggestAlternative.fromJson(e as Map<String, dynamic>?))
              .toList()
          : null,
      overallHealthScore: json['overallHealthScore'] as int?,
      overallHealthComments: json['overallHealthComments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'imageUrl': imageUrl,
      'foodName': foodName,
      'portion': portion,
      'portionSize': portionSize,
      'confidenceScore': confidenceScore,
      'ingredients': ingredients?.map((e) => e.toJson()).toList(),
      'primaryConcerns': primaryConcerns?.map((e) => e.toJson()).toList(),
      'suggestAlternatives':
          suggestAlternatives?.map((e) => e.toJson()).toList(),
      'overallHealthScore': overallHealthScore,
      'overallHealthComments': overallHealthComments,
    };
  }

  @override
  List<Object?> get props => [
        message,
        imageUrl,
        foodName,
        portion,
        portionSize,
        confidenceScore,
        ingredients,
        primaryConcerns,
        suggestAlternatives,
        overallHealthScore,
        overallHealthComments,
      ];
}

class Ingredient extends Equatable {
  final String? name;
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fiber;
  final int? fat;
  final int? healthScore;
  final String? healthComments;

  const Ingredient({
    this.name,
    this.calories,
    this.protein,
    this.carbs,
    this.fiber,
    this.fat,
    this.healthScore,
    this.healthComments,
  });

  factory Ingredient.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Ingredient();
    return Ingredient(
      name: json['name'] as String?,
      calories: json['calories'] as int?,
      protein: json['protein'] as int?,
      carbs: json['carbs'] as int?,
      fiber: json['fiber'] as int?,
      fat: json['fat'] as int?,
      healthScore: json['healthScore'] as int?,
      healthComments: json['healthComments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fiber': fiber,
      'fat': fat,
      'healthScore': healthScore,
      'healthComments': healthComments,
    };
  }

  @override
  List<Object?> get props => [
        name,
        calories,
        protein,
        carbs,
        fiber,
        fat,
        healthScore,
        healthComments,
      ];
}

class PrimaryConcern extends Equatable {
  final String? issue;
  final String? explanation;
  final List<Recommendation>? recommendations;

  const PrimaryConcern({
    this.issue,
    this.explanation,
    this.recommendations,
  });

  factory PrimaryConcern.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PrimaryConcern();
    return PrimaryConcern(
      issue: json['issue'] as String?,
      explanation: json['explanation'] as String?,
      recommendations: json['recommendations'] is List
          ? (json['recommendations'] as List)
              .map((e) => Recommendation.fromJson(e as Map<String, dynamic>?))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue': issue,
      'explanation': explanation,
      'recommendations': recommendations?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [issue, explanation, recommendations];
}

class Recommendation extends Equatable {
  final String? food;
  final String? quantity;
  final String? reasoning;

  const Recommendation({
    this.food,
    this.quantity,
    this.reasoning,
  });

  factory Recommendation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Recommendation();
    return Recommendation(
      food: json['food'] as String?,
      quantity: json['quantity'] as String?,
      reasoning: json['reasoning'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food': food,
      'quantity': quantity,
      'reasoning': reasoning,
    };
  }

  @override
  List<Object?> get props => [food, quantity, reasoning];
}

class SuggestAlternative extends Equatable {
  final String? name;
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fiber;
  final int? fat;
  final int? healthScore;
  final String? healthComments;

  const SuggestAlternative({
    this.name,
    this.calories,
    this.protein,
    this.carbs,
    this.fiber,
    this.fat,
    this.healthScore,
    this.healthComments,
  });

  factory SuggestAlternative.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SuggestAlternative();
    return SuggestAlternative(
      name: json['name'] as String?,
      calories: json['calories'] as int?,
      protein: json['protein'] as int?,
      carbs: json['carbs'] as int?,
      fiber: json['fiber'] as int?,
      fat: json['fat'] as int?,
      healthScore: json['healthScore'] as int?,
      healthComments: json['healthComments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fiber': fiber,
      'fat': fat,
      'healthScore': healthScore,
      'healthComments': healthComments,
    };
  }

  @override
  List<Object?> get props => [
        name,
        calories,
        protein,
        carbs,
        fiber,
        fat,
        healthScore,
        healthComments,
      ];
}

class Metadata extends Equatable {
  final int? inputTokenCount;
  final int? outputTokenCount;
  final int? totalTokenCount;
  final double? estimatedCost;
  final double? executionTimeSeconds;

  const Metadata({
    this.inputTokenCount,
    this.outputTokenCount,
    this.totalTokenCount,
    this.estimatedCost,
    this.executionTimeSeconds,
  });

  factory Metadata.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Metadata();
    return Metadata(
      inputTokenCount: json['input_token_count'] as int?,
      outputTokenCount: json['output_token_count'] as int?,
      totalTokenCount: json['total_token_count'] as int?,
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
      executionTimeSeconds:
          (json['execution_time_seconds'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input_token_count': inputTokenCount,
      'output_token_count': outputTokenCount,
      'total_token_count': totalTokenCount,
      'estimated_cost': estimatedCost,
      'execution_time_seconds': executionTimeSeconds,
    };
  }

  @override
  List<Object?> get props => [
        inputTokenCount,
        outputTokenCount,
        totalTokenCount,
        estimatedCost,
        executionTimeSeconds,
      ];
}
