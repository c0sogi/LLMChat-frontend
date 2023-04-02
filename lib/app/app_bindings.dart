import 'package:flutter_web/screens/login/login_controller.dart';
import 'package:get/get.dart';
import '../screens/chat/chat_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
    Get.put<LoginController>(LoginController());
  }
}
