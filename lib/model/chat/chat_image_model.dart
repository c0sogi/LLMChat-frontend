import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class ChatImageModel {
  // static const AssetImage user = AssetImage(
  //   'assets/images/user_profile.png',
  // );
  static Rx<NetworkImage?> user = Rx<NetworkImage?>(null);
  static const AssetImage openai =
      AssetImage('assets/images/openai_profile.png');
  static const AssetImage vicuna =
      AssetImage('assets/images/vicuna_profile.jpg');
  static const AssetImage ai = AssetImage('assets/images/ai_profile.png');

  static SvgPicture searchWebSvg = SvgPicture.asset(
    kReleaseMode ? 'assets/svgs/search-web.svg' : 'svgs/search-web.svg',
    width: 20,
    height: 20,
    colorFilter: const ColorFilter.mode(
      Colors.white,
      BlendMode.srcIn,
    ),
  );

  static Map<String, TweenAnimationBuilder> lottieAnimationBuilders = {
    "search-web": getLottieBuilder("lotties/search-web.json"),
    "search-doc": getLottieBuilder("lotties/search-doc.json"),
    "read": getLottieBuilder("lotties/read.json"),
    "go-back": getLottieBuilder("lotties/go-back.json"),
    "click": getLottieBuilder("lotties/click.json"),
    "scroll-down": getLottieBuilder("lotties/scroll-down.json"),
    "ok": getLottieBuilder("lotties/ok.json"),
    "fail": getLottieBuilder("lotties/fail.json"),
    "file-upload":
        getLottieBuilder("lotties/file-upload.json", width: 48, height: 48),
    "translate": getLottieBuilder("lotties/translate.json"),
  };

  static AssetImage getLlmAssetImage(String modelName) {
    if (modelName.startsWith("gpt-3.5") || modelName.startsWith("gpt-4")) {
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

  static TweenAnimationBuilder getLottieBuilder(
    String pathToJson, {
    double width = 32,
    double height = 32,
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 2),
        builder: (BuildContext context, double value, Widget? child) {
          return Lottie.asset(
            kReleaseMode ? "assets/$pathToJson" : pathToJson,
            animate: true,
            width: width,
            height: height,
            fit: BoxFit.cover,
            frameRate: FrameRate.max,
            repeat: false,
            reverse: false,
            controller: AlwaysStoppedAnimation(value),
          );
        },
      );
}
