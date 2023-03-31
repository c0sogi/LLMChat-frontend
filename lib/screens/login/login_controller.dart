import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final String baseUrl = "http://localhost:8000";
  final RxBool isLoading = false.obs;
  final RxString jwtToken = ''.obs;
  final RxList<dynamic> apiKeys = <dynamic>[].obs;
  final RxString selectedApiKey = ''.obs;

  void setJwtToken(String token) {
    jwtToken(token);
    fetchApiKeys();
  }

  Future<void> fetchApiKeys() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/apikeys'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': jwtToken.value,
      },
    );

    if (response.statusCode == 200) {
      apiKeys.assignAll(jsonDecode(response.body));
    } else {
      Get.snackbar('Error', 'Failed to fetch API keys');
    }
  }

  Future<void> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register/email'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      setJwtToken(jsonDecode(response.body)['Authorization']);
      Get.snackbar('Success', '회원가입에 성공하였습니다.');
    } else {
      Get.snackbar('Error', '회원가입에 실패하였습니다.');
    }
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login/email'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      setJwtToken(jsonDecode(response.body)['Authorization']);
      // Store the JWT token securely, e.g., using FlutterSecureStorage

      Get.snackbar('Success', '로그인에 성공하였습니다.');
    } else {
      Get.snackbar('Error', '로그인에 실패하였습니다.');
    }
  }
}
