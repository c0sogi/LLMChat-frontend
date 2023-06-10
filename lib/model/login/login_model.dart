import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web/model/chat/chat_image_model.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../../model/login/login_storage_model.dart';
import '../../utils/fetch_utils.dart';

class SnackBarModel {
  final String title;
  final String message;
  final Color backgroundColor;
  final Duration duration;
  final SnackPosition snackPosition;
  final Icon? icon;

  SnackBarModel({
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.snackPosition,
    this.duration = const Duration(seconds: 1),
    this.icon,
  });
}

class ErrorSnackBarModel extends SnackBarModel {
  ErrorSnackBarModel({
    required String title,
    required String message,
    Color backgroundColor = ThemeViewModel.errorColor,
    Duration duration = const Duration(seconds: 1),
    SnackPosition snackPosition = SnackPosition.TOP,
    Icon? icon = const Icon(Icons.error),
  }) : super(
          title: title,
          message: message,
          backgroundColor: backgroundColor,
          duration: duration,
          snackPosition: snackPosition,
          icon: icon,
        );
}

class SuccessSnackBarModel extends SnackBarModel {
  SuccessSnackBarModel({
    required String title,
    required String message,
    Color backgroundColor = ThemeViewModel.successColor,
    Duration duration = const Duration(seconds: 1),
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Icon? icon = const Icon(Icons.check),
  }) : super(
          title: title,
          message: message,
          backgroundColor: backgroundColor,
          duration: duration,
          snackPosition: snackPosition,
          icon: icon,
        );
}

class InfoSnackBarModel extends SnackBarModel {
  InfoSnackBarModel({
    required String title,
    required String message,
    Color backgroundColor = ThemeViewModel.infoColor,
    Duration duration = const Duration(seconds: 1),
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Icon? icon = const Icon(Icons.info),
  }) : super(
          title: title,
          message: message,
          backgroundColor: backgroundColor,
          duration: duration,
          snackPosition: snackPosition,
          icon: icon,
        );
}

class LoginModel {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final List<dynamic> apiKeys = <dynamic>[];

  String jwtToken = "";
  String selectedApiKey = "";
  bool isRemembered = false;
  String username = "";

  Future<SnackBarModel?> init() async {
    return await loadJwtTokenFromLocalStorage();
  }

  void close() {
    formKey.currentState?.reset();
  }

  void onClickApiKey({required String accessKey, required String userMemo}) {
    // Save the selected API key for later use and show a Snackbar for visual confirmation
    selectedApiKey = accessKey;
  }

  Future<String?> onGetToken(String token) async {
    jwtToken = token;
    if (isRemembered) {
      await AuthService.saveToken(token);
    }

    final List<String?> result = await Future.wait([
      JsonFetchUtils.fetch(
        fetchMethod: FetchMethod.get,
        authorization: token,
        url: Config.fetchApiKeysUrl,
        successCode: 200,
        messageOnFail: "Failed to fetch API Keys",
        onSuccess: (dynamic body) async {
          apiKeys.assignAll(body);
        },
        onFail: (dynamic bodyDecoded) async {
          if (bodyDecoded is Map && bodyDecoded["detail"] == "Token Expired") {
            await logout();
            throw "Token expired. Please login again.";
          }
        },
      ),
      JsonFetchUtils.fetch(
          fetchMethod: FetchMethod.get,
          authorization: token,
          url: Config.fetchUserInfoUrl,
          successCode: 200,
          messageOnFail: "Failed to fetch user info",
          onSuccess: (dynamic body) async {
            username = body['email'];
            ChatImageModel.setUserImage(username);
          }),
    ]);
    // If all the results are null, return null. Otherwise, return the joined string.
    // This is because the result of Future.wait is a List of Future<T> and we want to
    // return a Error Message String (or null for success)
    // join result without null if there is any null, instead of result.join("\n")
    final Iterable<String?> errorMessages =
        result.where((String? element) => element != null);
    if (errorMessages.isEmpty) {
      return null;
    } else {
      return errorMessages.join("\n");
    }
  }

  Future<SnackBarModel> register(String email, String password) async {
    try {
      final String? fetchResult = await JsonFetchUtils.fetch(
        fetchMethod: FetchMethod.post,
        url: Config.registerUrl,
        successCode: 201,
        body: {'email': email, 'password': password},
        messageOnFail: "Failed to register",
        onSuccess: (dynamic bodyDecoded) async {
          final String? errorMessages = await onGetToken(
            bodyDecoded['Authorization'],
          );
          if (errorMessages != null) {
            throw errorMessages;
          }
        },
        onFail: (dynamic bodyDecoded) async {
          throw bodyDecoded['detail'];
        },
      );
      return fetchResult == null
          ? SuccessSnackBarModel(
              title: "Successfully registered",
              message: "성공적으로 회원가입 되었습니다.",
            )
          : ErrorSnackBarModel(
              title: "Error",
              message: fetchResult,
            );
    } catch (e) {
      return ErrorSnackBarModel(
        title: "Error",
        message: e.toString(),
      );
    }
  }

  Future<SnackBarModel> unregister() async {
    final String? fetchResult = await JsonFetchUtils.fetch(
      fetchMethod: FetchMethod.delete,
      authorization: jwtToken,
      url: Config.unregisterUrl,
      successCode: 204,
      messageOnFail: "Failed to unregister",
      onSuccess: (dynamic body) async {
        await logout();
      },
    );
    return fetchResult == null
        ? SuccessSnackBarModel(
            title: "Successfully unregistered",
            message: "성공적으로 회원탈퇴 되었습니다.",
          )
        : ErrorSnackBarModel(
            title: "Error",
            message: fetchResult,
          );
  }

  Future<SnackBarModel> login(String email, String password) async {
    try {
      final String? fetchResult = await JsonFetchUtils.fetch(
        fetchMethod: FetchMethod.post,
        url: Config.loginUrl,
        successCode: 200,
        body: {'email': email, 'password': password},
        messageOnFail: "Failed to login",
        onSuccess: (dynamic bodyDecoded) async {
          final String? errorMessages = await onGetToken(
            bodyDecoded['Authorization'],
          );
          if (errorMessages != null) {
            throw errorMessages;
          }
        },
        onFail: (dynamic bodyDecoded) async {
          throw bodyDecoded['detail'];
        },
      );
      return fetchResult == null
          ? SuccessSnackBarModel(
              title: "Successfully logged in",
              message: "성공적으로 로그인 되었습니다.",
            )
          : ErrorSnackBarModel(
              title: "Error",
              message: fetchResult,
            );
    } catch (e) {
      return ErrorSnackBarModel(
        title: "Error",
        message: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    selectedApiKey = "";
    apiKeys.clear();
    await deleteToken();
  }

  Future<void> deleteToken() async {
    jwtToken = "";
    await AuthService.deleteToken();
  }

  Future<SnackBarModel?> loadJwtTokenFromLocalStorage() async {
    final storedToken = await AuthService.getToken();
    if (storedToken != null) {
      jwtToken = storedToken;
      final String? errorMessages = await onGetToken(storedToken);
      return errorMessages == null
          ? SuccessSnackBarModel(
              title: "Successful auto login",
              message: "자동 로그인에 성공했습니다.",
            )
          : ErrorSnackBarModel(
              title: "Error",
              message: errorMessages,
            );
    }
    return null;
  }

  Future<SnackBarModel> createNewApiKey({required String userMemo}) async {
    final String? postResult = await JsonFetchUtils.fetch(
      fetchMethod: FetchMethod.post,
      authorization: jwtToken,
      url: Config.postApiKeysUrl,
      body: {"user_memo": userMemo},
      successCode: 201,
      messageOnFail: "Failed to create API key.",
      onSuccess: (dynamic body) async {
        apiKeys.add(body);
      },
    );
    return postResult == null
        ? SuccessSnackBarModel(
            title: "Successfully created API key",
            message: "API 키가 성공적으로 생성되었습니다.",
          )
        : ErrorSnackBarModel(
            title: "Error",
            message: postResult,
          );
  }

  static String gravatarUrl(String email) {
    return 'https://www.gravatar.com/avatar/${md5.convert(utf8.encode(email.trim().toLowerCase()))}';
  }
}
