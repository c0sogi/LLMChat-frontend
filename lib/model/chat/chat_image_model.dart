import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatImageModel {
  // static const AssetImage user = AssetImage(
  //   'assets/images/user_profile.png',
  // );
  static Rx<NetworkImage?> user = Rx<NetworkImage?>(null);
  static const AssetImage openai = AssetImage(
    'assets/images/openai_profile.png',
  );
  static const AssetImage vicuna = AssetImage(
    'assets/images/vicuna_profile.jpg',
  );
  static const AssetImage ai = AssetImage(
    'assets/images/ai_profile.png',
  );

  static AssetImage getLlmAssetImage(String modelName) {
    const List<String> openaiModels = ["gpt-3.5-turbo", "gpt-4", "gpt-4-32k"];
    if (openaiModels.contains(modelName)) {
      return openai;
    }
    if (modelName.isEmpty) {
      return ai;
    }
    return vicuna;
  }

  static String gravatarUrl(String email) {
    var emailTrimmed = email.trim().toLowerCase();
    var bytes = utf8.encode(emailTrimmed);
    var digest = md5.convert(bytes);

    return 'https://www.gravatar.com/avatar/$digest?d=retro';
  }

  static void setUserImage(String email) {
    user(NetworkImage(gravatarUrl(email)));
  }
}
