import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    Future<void> Function(dynamic)? onFail,
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
      bodyBytes: res.bodyBytes,
      statusCode: res.statusCode,
      successCode: successCode,
      messageOnSuccess: null,
      messageOnFail: messageOnFail,
      onSuccess: onSuccess,
      onFail: onFail,
    );
  }

  static Future<T> getFetchResult<T>({
    required Uint8List bodyBytes,
    required int statusCode,
    required int successCode,
    required T messageOnSuccess,
    required T messageOnFail,
    Future<void> Function(dynamic)? onSuccess,
    Future<void> Function(dynamic)? onFail,
  }) async {
    dynamic bodyDecoded;

    try {
      bodyDecoded = jsonDecode(utf8.decode(bodyBytes));
    } catch (_) {
      bodyDecoded = bodyBytes;
    }

    try {
      if (statusCode == successCode) {
        await onSuccess?.call(bodyDecoded);
        return messageOnSuccess;
      }
      await onFail?.call(bodyDecoded) as T;
      return messageOnFail;
    } catch (e) {
      return e is T ? e as T : messageOnFail;
    }
  }
}
