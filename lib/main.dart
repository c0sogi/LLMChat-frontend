import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import './app/app_bindings.dart';
import './screens/home_screen.dart';

void main(List<String> args) {
  setPathUrlStrategy(); // 해당 라인 추가.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      home: const HomeScreen(),
    );
  }
}
