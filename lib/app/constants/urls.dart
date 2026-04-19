class ApiUrl {
  static const String baseUrl =
      "https://46d0-2a09-bac5-3e0d-1a46-00-29e-85.ngrok-free.app";
}

class ApiPath {
  static const String nutrtionByImage = "/api/v1/nutrition/analyze";

  static const String sendMessage = "/api/v1/chat/messages";

  static String getMessages(String userId, int offset, int limit) =>
      "/api/v1/users?user_id=$userId&offset=$offset&limit=$limit";

  static const String updateLogStatus = "/api/v1/users/log-status";
}
