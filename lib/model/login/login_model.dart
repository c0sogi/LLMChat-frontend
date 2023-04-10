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

  Future<List<String?>> onGetToken(String token) async {
    _jwtToken = token;
    if (isRemembered) {
      await _authService.saveToken(_jwtToken);
    }
    return [await fetchApiKeys(), await fetchUserInfo()];
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

    response.statusCode == 200
        ? _apiKeys.assignAll(jsonDecode(response.body))
        : () {
            if (jsonDecode(response.body)["detail"] == "Token Expired") {
              return "토큰이 만료되었습니다. 다시 로그인해주세요.";
            } else {
              return "API 키를 불러오는데 실패하였습니다.";
            }
          }();
    return null;
    // ? Get.snackbar("Error", "토큰이 만료되었습니다. 다시 로그인해주세요.",
    //     backgroundColor: Colors.red)
    // : Get.snackbar("Error", "API 키를 불러오는데 실패하였습니다.",
    //     backgroundColor: Colors.red);
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
    response.statusCode == 200
        ? _username = jsonDecode(response.body)['email']
        : () {
            if (jsonDecode(response.body)["detail"] == "Token Expired") {
              return "토큰이 만료되었습니다. 다시 로그인해주세요.";
            } else {
              return "API 키를 불러오는데 실패하였습니다.";
            }
          }();
    return null;
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
    if (response.statusCode == 201) {
      final List<String?> errorMessages = await onGetToken(
        jsonDecode(response.body)['Authorization'],
      );
      return errorMessages.every((element) => element == null)
          ? SnackBarModel(
              title: "Success",
              message: "회원가입에 성공하였습니다.",
              backgroundColor: Colors.green,
            )
          : SnackBarModel(
              title: "Error",
              message: errorMessages.join("\n"),
              backgroundColor: Colors.red,
            );
    } else {
      return SnackBarModel(
        title: "Error",
        message: "회원가입에 실패하였습니다.",
        backgroundColor: Colors.red,
      );
    }
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
    if (response.statusCode == 200) {
      final List<String?> errorMessages = await onGetToken(
        jsonDecode(response.body)['Authorization'],
      );
      return errorMessages.every((element) => element == null)
          ? SnackBarModel(
              title: "Success",
              message: "로그인에 성공하였습니다.",
              backgroundColor: Colors.green,
            )
          : SnackBarModel(
              title: "Error",
              message: errorMessages.join("\n"),
              backgroundColor: Colors.red,
            );
    } else {
      return SnackBarModel(
        title: "Error",
        message: "로그인에 실패하였습니다.",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> deleteToken() async {
    _jwtToken = "";
    _apiKeys.clear();
    await _authService.deleteToken();
  }

  Future<void> loadJwtTokenFromLocalStorage() async {
    final storedToken = await _authService.getToken();
    storedToken == null ? _jwtToken = "" : onGetToken(storedToken);
  }
}
