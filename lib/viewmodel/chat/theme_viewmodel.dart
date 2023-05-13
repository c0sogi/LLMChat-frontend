import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeViewModel extends GetxController {
  static const Color idleColor = Color(0xFFE65100);
  static const Color activeColor = Color(0xFF0D47A1);
  static const Color errorColor = Color(0xFFD50000);
  static const Color successColor = Color(0xFF43A047);
  static const Color infoColor = Color(0xFF1976D2);
  static const defaultGradientColors = <Color>[
    Color(0xff1f005a),
    Color(0xff5b0060),
    Color(0xff870160),
    Color(0xffac255e),
    Color(0xffca485c),
    Color(0xffe16b5c),
    Color(0xfff39060),
    Color(0xffffb56b),
  ];
  final Rx<Alignment> begin = Alignment.topCenter.obs;
  final Rx<Alignment> end = Alignment.bottomCenter.obs;
  final RxList<double> stops =
      <double>[0.0, 0.05, 0.1, 0.3, 0.4, 0.6, 0.8, 1.0].obs;

  void toggleTheme(bool night) {
    if (night) {
      stops.assignAll([0.0, 0.33, 0.66, 0.8, 0.95, 0.98, 0.99, 1.0]);
    } else {
      stops.assignAll([0.0, 0.05, 0.1, 0.3, 0.4, 0.6, 0.8, 1.0]);
    }
    update();
  }
}
