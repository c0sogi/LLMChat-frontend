import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_strategy/url_strategy.dart';
import './app/app_bindings.dart';
import 'view/home_screen.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      title: "ChatGPT",
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
