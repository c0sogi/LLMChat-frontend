import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchUtils {
  static Future<String?> fetch({
    required String authorization,
    required String url,
    required int successCode,
    required String messageOnFail,
    required Future<void> Function(dynamic)? onSuccess,
  }) async {
    // Fetch some information from the server
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': authorization,
      },
    );
    return getFetchResult<String?>(
      body: response.body,
      statusCode: response.statusCode,
      successCode: successCode,
      messageOnSuccess: null,
      messageOnFail: messageOnFail,
      messageOnTokenExpired: "토큰이 만료되었습니다. 다시 로그인해주세요.",
      onSuccess: onSuccess,
    );
  }

  static Future<T> getFetchResult<T>({
    required String body,
    required int statusCode,
    required int successCode,
    required T messageOnSuccess,
    required T messageOnFail,
    required T messageOnTokenExpired,
    Future<void> Function(dynamic)? onSuccess,
    Future<void> Function(dynamic)? onFail,
  }) async {
    bool isFailCallbackCalled = false;
    try {
      final dynamic bodyJson = jsonDecode(body);
      if (statusCode == successCode) {
        await onSuccess?.call(bodyJson);
        return messageOnSuccess;
      }
      await onFail?.call(body);
      isFailCallbackCalled = true;
      return bodyJson["detail"] == "Token Expired"
          ? messageOnTokenExpired
          : messageOnFail;
    } catch (e) {
      if (!isFailCallbackCalled) {
        await onFail?.call(body);
      }
      return e is T ? e as T : messageOnFail;
    }
  }
}
