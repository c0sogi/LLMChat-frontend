import 'dart:convert';
import 'package:http/http.dart' as http;

enum FetchMethod {
  get,
  post,
  put,
  delete,
}

class JsonFetchUtils {
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  static Future<String?> fetch({
    required FetchMethod fetchMethod,
    required String url,
    required int successCode,
    required String messageOnFail,
    required Future<void> Function(dynamic)? onSuccess,
    String? authorization,
    Object? body,
  }) async {
    final Map<String, String> headers = {
      ..._defaultHeaders,
      if (authorization != null) 'Authorization': authorization
    };
    final encodedBody = body != null ? jsonEncode(body) : null;
    late final http.Response res;
    switch (fetchMethod) {
      case FetchMethod.get:
        res = await http.get(Uri.parse(url), headers: headers);
        break;
      case FetchMethod.post:
        res = await http.post(Uri.parse(url),
            body: encodedBody, headers: headers);
        break;
      case FetchMethod.put:
        res =
            await http.put(Uri.parse(url), body: encodedBody, headers: headers);
        break;
      case FetchMethod.delete:
        res = await http.delete(Uri.parse(url), headers: headers);
    }
    return getFetchResult<String?>(
      body: res.body,
      statusCode: res.statusCode,
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
