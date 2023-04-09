import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_strategy/url_strategy.dart';
import './app/app_bindings.dart';
import 'view/home_screen.dart';

// class DeviceInfo {
//   static bool isChromeInIOS() {
//     return isIOS() && !isSafari();
//   }

//   static bool isSafari() {
//     if (window.navigator.userAgent.toString().toLowerCase().contains('crios')) {
//       return false;
//     }
//     return context.callMethod('isSafari', []);
//   }

//   static String getOSInsideWeb() {
//     final userAgent = window.navigator.userAgent.toString().toLowerCase();
//     if (userAgent.contains('iphone')) {
//       return 'ios';
//     }
//     if (userAgent.contains('ipad')) {
//       return 'ios';
//     }
//     if (userAgent.contains('android')) {
//       return "Android";
//     }
//     return 'Web';
//   }

//   static int? get iosVersion {
//     if (!isIOS()) {
//       return null;
//     }
//     final agent = userAgent;
//     final versionPart = agent.split('version/')[1];
//     return int.tryParse(versionPart.substring(0, versionPart.indexOf('.'))) ??
//         -1;
//   }

//   static bool isIOS() {
//     return getOSInsideWeb() == 'ios';
//   }
// }

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
        title: "ChatGPT App",
        debugShowCheckedModeBanner: false,
        initialBinding: AppBinding(),
        home: const HomeScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
        });
  }
}
