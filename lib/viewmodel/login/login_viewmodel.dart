import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/app_config.dart';
import '../chat/chat_viewmodel.dart';
import '../../model/login/login_storage_model.dart';

class LoginController extends GetxController {
  // controllers
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = AuthService();

  // observers
  final RxBool isLoading = false.obs;
  final RxString jwtToken = ''.obs;
  final RxList<dynamic> apiKeys = <dynamic>[].obs;
  final RxString selectedApiKey = ''.obs;
  final RxBool isRemembered = false.obs;
  final RxString username = "".obs;

  // variables

  @override
  void onInit() async {
    super.onInit();
    await loadJwtTokenFromLocalStorage();
  }

  @override
  void onClose() {
    super.onClose();
    // unregister controllers
    formKey.currentState?.dispose();
  }

  Future<void> onGetToken(String token) async {
    jwtToken(token);
    if (isRemembered.value) {
      await _authService.saveToken(jwtToken.value);
    }
    await fetchApiKeys();
    await fetchUserInfo();
  }

  Future<void> fetchApiKeys() async {
    final response = await http.get(
      Uri.parse(Config.fetchApiKeysUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': jwtToken.value,
      },
    );
    // TODO: statusCode가 401이고 internal_code가 6일 때는 토큰 만료임을 알려주기
    // 만약 토큰 만료이면 토큰을 지우고 로그인 화면으로 이동
    response.statusCode == 200
        ? apiKeys.assignAll(jsonDecode(response.body))
        : Get.snackbar('Error', 'API 키를 불러오는데 실패하였습니다.');
  }

  Future<void> fetchUserInfo() async {
    final response = await http.get(
      Uri.parse(Config.fetchUserInfoUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': jwtToken.value,
      },
    );
    // TODO: statusCode가 401이고 internal_code가 6일 때는 토큰 만료임을 알려주기
    // 만약 토큰 만료이면 토큰을 지우고 로그인 화면으로 이동
    response.statusCode == 200
        ? username(jsonDecode(response.body)['email'])
        : Get.snackbar('Error', '사용자 정보를 불러오는데 실패하였습니다.');
  }

  Future<void> register(String email, String password) async {
    final response = await http.post(
      Uri.parse(Config.registerUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    response.statusCode == 201
        ? () async {
            await onGetToken(jsonDecode(response.body)['Authorization']);
            Get.snackbar('Success', '회원가입에 성공하였습니다.');
          }()
        : Get.snackbar('Error', '회원가입에 실패하였습니다.');
  }

  Future<void> login(String email, String password) async {
    print(Config.loginUrl);
    final response = await http.post(
      Uri.parse(Config.loginUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    response.statusCode == 200
        ? () async {
            await onGetToken(jsonDecode(response.body)['Authorization']);
            Get.snackbar('Success', '로그인에 성공하였습니다.');
          }()
        : Get.snackbar('Error', '로그인에 실패하였습니다.');
  }

  Future<void> deleteToken() async {
    jwtToken("");
    await _authService.deleteToken();
  }

  Future<void> loadJwtTokenFromLocalStorage() async {
    final storedToken = await _authService.getToken();
    storedToken == null ? jwtToken("") : onGetToken(storedToken);
  }

  void onClickApiKey({required String accessKey, required String userMemo}) {
    // Save the selected API key for later use and show a Snackbar for visual confirmation
    selectedApiKey(accessKey);
    // pop all dialogs until the root dialog is reached
    Get.back();
    Get.snackbar('API Key Selected', '$userMemo가 선택되었습니다.');
    Get.find<ChatViewModel>().beginChat(
      apiKey: accessKey,
      chatRoomId: 0,
    );
    update();
  }
}
