class Config {
  static const host = "localhost:8000";
  static const websocketSchema = "ws";
  static const httpSchema = "http";

  static const String webSocketUrl = "$websocketSchema://$host/ws/chatgpt";
  static const String httpUrl = "$httpSchema://$host";
  static const String loginUrl = "$httpUrl/api/auth/login/email";
  static const String registerUrl = "$httpUrl/api/auth/register/email";
  static const String fetchApiKeysUrl = "$httpUrl/api/user/apikeys";
  static const String fetchUserInfoUrl = "$httpUrl/api/user/me";
  static const String fetchUserChatrooms = "$httpUrl/api/user/chatrooms";

  static const int scrollOffset = 0;
}
