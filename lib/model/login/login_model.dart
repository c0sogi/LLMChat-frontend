import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/app_config.dart';
import '../../model/login/login_storage_model.dart';

class SnackBarModel {
  final String title;
  final String message;
  final Color backgroundColor;
  final Duration duration;

  SnackBarModel({
    required this.title,
    required this.message,
    required this.backgroundColor,
    this.duration = const Duration(seconds: 1),
  });
}

class LoginModel {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = AuthService();

  final List<dynamic> _apiKeys = <dynamic>[];
  String _jwtToken = '';
  String _selectedApiKey = '';
  bool isRemembered = false;
  String _username = "";

  GlobalKey<FormBuilderState> get formKey => _formKey;
  List<dynamic> get apiKeys => _apiKeys;
  String get jwtToken => _jwtToken;
  String get selectedApiKey => _selectedApiKey;
  String get username => _username;

  void init() async {
    await loadJwtTokenFromLocalStorage();
  }

  void close() {
    _formKey.currentState?.reset();
  }

  void onClickApiKey({required String accessKey, required String userMemo}) {
    // Save the selected API key for later use and show a Snackbar for visual confirmation
    _selectedApiKey = accessKey;
  }

  Future<String?> onGetToken(String token) async {
    _jwtToken = token;
    if (isRemembered) {
      await _authService.saveToken(token);
    }
    final List<String?> result =
        await Future.wait([fetchApiKeys(), fetchUserInfo()]);
    return result.every((element) => element == null)
        ? null
        : result.join("\n");
  }

  Future<String?> fetchApiKeys() async {
    final response = await http.get(
      Uri.parse(Config.fetchApiKeysUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': _jwtToken,
      },
    );
    return getFetchResult<String?>(
      body: response.body,
      statusCode: response.statusCode,
      successCode: 200,
      messageOnSuccess: null,
      messageOnTokenExpired: "토큰이 만료되었습니다. 다시 로그인해주세요.",
      messageOnFail: "API 키를 불러오는데 실패하였습니다.",
      onSuccess: (dynamic body) async {
        _apiKeys.assignAll(body);
      },
    );
  }

  Future<String?> fetchUserInfo() async {
    final response = await http.get(
      Uri.parse(Config.fetchUserInfoUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': _jwtToken,
      },
    );
    return getFetchResult<String?>(
      body: response.body,
      statusCode: response.statusCode,
      successCode: 200,
      messageOnSuccess: null,
      messageOnTokenExpired: "토큰이 만료되었습니다. 다시 로그인해주세요.",
      messageOnFail: "사용자 정보를 불러오는데 실패하였습니다.",
      onSuccess: (dynamic body) async {
        _username = body['email'];
      },
    );
  }

  Future<T> getFetchResult<T>({
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

  Future<SnackBarModel> register(String email, String password) async {
    final response = await http.post(
      Uri.parse(Config.registerUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    final String? fetchResult = await getFetchResult<String?>(
      body: response.body,
      statusCode: response.statusCode,
      successCode: 201,
      messageOnSuccess: null,
      messageOnFail: "회원가입에 실패하였습니다.",
      messageOnTokenExpired: "토큰이 만료되었습니다. 다시 로그인해주세요.",
      onSuccess: (dynamic body) async {
        final String? errorMessages = await onGetToken(
          jsonDecode(response.body)['Authorization'],
        );
        if (errorMessages != null) {
          throw errorMessages;
        }
      },
    );
    return SnackBarModel(
      title: fetchResult == null ? "Success" : "Error",
      message: fetchResult ?? "회원가입에 성공하였습니다.",
      backgroundColor: fetchResult == null ? Colors.green : Colors.red,
    );
  }

  Future<SnackBarModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(Config.loginUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    final String? fetchResult = await getFetchResult<String?>(
      body: response.body,
      statusCode: response.statusCode,
      successCode: 200,
      messageOnSuccess: null,
      messageOnFail: "로그인에 실패하였습니다.",
      messageOnTokenExpired: "토큰이 만료되었습니다. 다시 로그인해주세요.",
      onSuccess: (dynamic body) async {
        final String? errorMessages = await onGetToken(
          jsonDecode(response.body)['Authorization'],
        );
        if (errorMessages != null) {
          throw errorMessages;
        }
      },
    );
    return SnackBarModel(
      title: fetchResult == null ? "Success" : "Error",
      message: fetchResult ?? "로그인에 성공하였습니다.",
      backgroundColor: fetchResult == null ? Colors.green : Colors.red,
    );
  }

  Future<void> logout() async {
    _selectedApiKey = "";
    _apiKeys.clear();
    await deleteToken();
  }

  Future<void> deleteToken() async {
    _jwtToken = "";
    await _authService.deleteToken();
  }

  Future<void> loadJwtTokenFromLocalStorage() async {
    final storedToken = await _authService.getToken();
    storedToken == null ? _jwtToken = "" : await onGetToken(storedToken);
  }
}
