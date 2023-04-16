import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:get/get.dart';
import '../viewmodel/chat/chat_viewmodel.dart';
import '../viewmodel/login/login_viewmodel.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeViewModel>(ThemeViewModel());
    Get.put<ChatViewModel>(ChatViewModel());
    Get.put<LoginViewModel>(LoginViewModel());
  }
}
