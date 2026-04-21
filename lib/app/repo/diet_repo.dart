import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:NomAi/app/constants/urls.dart';
import 'package:NomAi/app/models/Diet/diet_input.dart';
import 'package:NomAi/app/models/Diet/diet_output.dart';

class DietRepo {
  Future<WeeklyDietOutput?> createWeeklyDiet(DietInput input) async {
    try {
      debugPrint('DietRepo: Creating weekly diet for user ${input.userId}');
      debugPrint('DietRepo: Input JSON: ${jsonEncode(input.toJson())}');

      final response = await http.post(
        Uri.parse('${ApiUrl.baseUrl}${ApiPath.createDiet}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input.toJson()),
      );

      debugPrint('DietRepo: Response status: ${response.statusCode}');
      debugPrint('DietRepo: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return WeeklyDietOutput.fromJson(data['response']);
        }
        if (data['response'] != null) {
          debugPrint('DietRepo: No success field but has response, parsing directly');
          return WeeklyDietOutput.fromJson(data['response']);
        }
        debugPrint('DietRepo: Success was false, data: $data');
      }
      return null;
    } catch (e) {
      debugPrint('DietRepo: ERROR creating weekly diet: $e');
      return null;
    }
  }

  Future<WeeklyDietOutput?> getActiveDiet(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUrl.baseUrl}${ApiPath.getActiveDiet(userId)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return WeeklyDietOutput.fromJson(data['response']);
        }
        if (data['response'] != null) {
          return WeeklyDietOutput.fromJson(data['response']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('DietRepo: ERROR getting active diet: $e');
      return null;
    }
  }

  Future<DietHistoryResponse?> getDietHistory(
    String userId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiUrl.baseUrl}${ApiPath.getDietHistory(userId)}?limit=$limit&offset=$offset'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('DietRepo: getDietHistory response status: ${response.statusCode}');
      debugPrint('DietRepo: getDietHistory response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return DietHistoryResponse.fromJson(data['response']);
        }
        if (data['response'] != null) {
          return DietHistoryResponse.fromJson(data['response']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('DietRepo: ERROR getting diet history: $e');
      return null;
    }
  }

  Future<NutritionResponseModel?> suggestAlternate({
    required String userId,
    required NutritionResponseModel currentMeal,
    required String mealType,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    List<String>? dislikedFoods,
    List<String>? anyDiseases,
    List<String>? selectedGoals,
    String? prompt,
  }) async {
    try {
      debugPrint('DietRepo: Suggesting alternate for user $userId, mealType: $mealType');
      final response = await http.post(
        Uri.parse(
            '${ApiUrl.baseUrl}${ApiPath.suggestAlternate(userId)}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currentMeal': currentMeal.toJson(),
          'mealType': mealType,
          if (dietaryPreferences != null) 'dietaryPreferences': dietaryPreferences,
          if (allergies != null) 'allergies': allergies,
          if (dislikedFoods != null) 'dislikedFoods': dislikedFoods,
          if (anyDiseases != null) 'anyDiseases': anyDiseases,
          if (selectedGoals != null) 'selectedGoals': selectedGoals,
          if (prompt != null && prompt.isNotEmpty) 'prompt': prompt,
        }),
      );

      debugPrint('DietRepo: suggestAlternate response status: ${response.statusCode}');
      debugPrint('DietRepo: suggestAlternate response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return NutritionResponseModel.fromJson(data['response']);
        }
        if (data['response'] != null) {
          return NutritionResponseModel.fromJson(data['response']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('DietRepo: ERROR suggesting alternate: $e');
      return null;
    }
  }

  Future<SuggestAlternativesResponse?> suggestAlternatives({
    required String userId,
    required NutritionResponseModel currentMeal,
    required String mealType,
    required String prompt,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    List<String>? dislikedFoods,
    List<String>? anyDiseases,
    List<String>? selectedGoals,
  }) async {
    try {
      debugPrint('DietRepo: Suggesting 5 alternatives for user $userId, mealType: $mealType');
      debugPrint('DietRepo: prompt: $prompt');
      final response = await http.post(
        Uri.parse(
            '${ApiUrl.baseUrl}${ApiPath.suggestAlternatives(userId)}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currentMeal': currentMeal.toJson(),
          'mealType': mealType,
          'prompt': prompt,
          if (dietaryPreferences != null) 'dietaryPreferences': dietaryPreferences,
          if (allergies != null) 'allergies': allergies,
          if (dislikedFoods != null) 'dislikedFoods': dislikedFoods,
          if (anyDiseases != null) 'anyDiseases': anyDiseases,
          if (selectedGoals != null) 'selectedGoals': selectedGoals,
        }),
      );

      debugPrint('DietRepo: suggestAlternatives response status: ${response.statusCode}');
      debugPrint('DietRepo: suggestAlternatives response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return SuggestAlternativesResponse.fromJson(data['response']);
        }
        if (data['response'] != null) {
          return SuggestAlternativesResponse.fromJson(data['response']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('DietRepo: ERROR suggesting alternatives: $e');
      return null;
    }
  }

  Future<bool> updateMeal({
    required String userId,
    required int dayIndex,
    required String mealType,
    required NutritionResponseModel meal,
  }) async {
    try {
      debugPrint('DietRepo: Updating meal for user $userId, day $dayIndex, mealType: $mealType');
      debugPrint('DietRepo: updateMeal payload: ${jsonEncode(meal.toJson())}');

      final response = await http.put(
        Uri.parse(
            '${ApiUrl.baseUrl}${ApiPath.updateMeal(userId, dayIndex, mealType)}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(meal.toJson()),
      );

      debugPrint('DietRepo: updateMeal response status: ${response.statusCode}');
      debugPrint('DietRepo: updateMeal response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['response']?['updated'] == true;
        }
        if (data['response']?['updated'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('DietRepo: ERROR updating meal: $e');
      return false;
    }
  }

  Future<WeeklyDietOutput?> getDietById({
    required String userId,
    required String dietId,
  }) async {
    try {
      debugPrint('DietRepo: Getting diet by ID $dietId for user $userId');

      final response = await http.get(
        Uri.parse('${ApiUrl.baseUrl}${ApiPath.getDietById(userId, dietId)}'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('DietRepo: getDietById response status: ${response.statusCode}');
      debugPrint('DietRepo: getDietById response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return WeeklyDietOutput.fromJson(data['response']);
        }
        if (data['response'] != null) {
          return WeeklyDietOutput.fromJson(data['response']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('DietRepo: ERROR getting diet by ID: $e');
      return null;
    }
  }

  Future<WeeklyDietOutput?> copyDiet({
    required String userId,
    required String dietId,
  }) async {
    try {
      debugPrint('DietRepo: Copying diet $dietId for user $userId');

      final response = await http.post(
        Uri.parse('${ApiUrl.baseUrl}${ApiPath.copyDiet(userId, dietId)}'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('DietRepo: copyDiet response status: ${response.statusCode}');
      debugPrint('DietRepo: copyDiet response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return WeeklyDietOutput.fromJson(data['response']);
        }
        if (data['response'] != null) {
          return WeeklyDietOutput.fromJson(data['response']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('DietRepo: ERROR copying diet: $e');
      return null;
    }
  }
}
