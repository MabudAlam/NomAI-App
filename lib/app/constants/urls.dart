class ApiUrl {
  static const String baseUrl =
      "https://ad9b-2a09-bac5-3e0f-1aa0-00-2a7-77.ngrok-free.app";
}

class ApiPath {
  static const String nutrtionByImage = "/api/v1/nutrition/analyze";

  static const String sendMessage = "/api/v1/chat/messages";

  static String getMessages(String userId, int offset, int limit) =>
      "/api/v1/users?user_id=$userId&offset=$offset&limit=$limit";


  static const String updateLogStatus = "/api/v1/users/log-status";

  static const String createDiet = "/api/v1/diet";

  static String getActiveDiet(String userId) => "/api/v1/diet/$userId";

  static String getDietHistory(String userId) => "/api/v1/diet/$userId/history";

  static String suggestAlternate(String userId) =>
      "/api/v1/diet/$userId/suggest-alternate";

  static String suggestAlternatives(String userId) =>
      "/api/v1/diet/$userId/suggest-alternatives";

  static String updateMeal(String userId, int dayIndex, String mealType) =>
      "/api/v1/diet/$userId/$dayIndex/meals/$mealType";

  static String getDietById(String userId, String dietId) =>
      "/api/v1/diet/$userId/diet/$dietId";

  static String copyDiet(String userId, String dietId) =>
      "/api/v1/diet/$userId/diet/$dietId/copy";
}
