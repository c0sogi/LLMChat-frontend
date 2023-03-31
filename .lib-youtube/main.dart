import 'package:flutter/material.dart';
import 'package:flutter_web/src/bindings/bindings.dart';
import 'package:get/get.dart';
import 'src/index.dart';
import 'src/pages/video.dart';

void main(List<String> args) => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      defaultTransition: Transition.cupertino,
      initialRoute: "/",
      getPages: [
        GetPage(
          name: "/",
          page: () => const IndexPage(),
          binding: IndexBinding(),
        ),
        GetPage(
          name: "/video",
          page: () => const VideoPage(),
        ),
      ],
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.green,
        hoverColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF6750a4),
          onPrimary: Color(0xFF22005d),
          secondary: Color(0xFF7d5260),
          onSecondary: Color(0xFF31101d),
          error: Color(0xFFba1b1b),
          onError: Color(0xFF410001),
          background: Colors.white,
          onBackground: Color(0xFF31101d),
          surface: Color(0xFF4DB6AC),
          onSurface: Color(0xFF00796B),
        ),
        appBarTheme: const AppBarTheme(
          toolbarHeight: 60,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          elevation: 10,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 20,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          displayMedium: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          displaySmall: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          bodySmall: const TextStyle(
            color: Colors.purple,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
          bodyLarge: const TextStyle(
            color: Colors.green,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.lerp(FontWeight.w400, FontWeight.w500, 0.5),
          ),
        ),
        cardTheme: const CardTheme(
          color: Color(0xaaf4eddb),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(50))),
        ),
      ),
    );
  }
}
