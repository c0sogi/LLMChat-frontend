import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_browser.dart';
import 'package:url_strategy/url_strategy.dart';
import './app/app_bindings.dart';
import 'view/home_screen.dart';

String extractLanguageCode(String? systemLocale) {
  if (systemLocale == null || systemLocale.isEmpty) {
    return 'en'; // default language code if systemLocale is null or empty
  }
  return systemLocale.split(RegExp('[-_]'))[0];
}

late final String languageCode;

void main(List<String> args) async {
  await findSystemLocale();
  final locale = Intl.systemLocale;
  await initializeDateFormatting(locale);
  await findSystemLocale();
  languageCode = extractLanguageCode(Intl.systemLocale);
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
      title: "LLMChat",
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
