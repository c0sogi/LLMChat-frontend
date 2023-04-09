import 'package:flutter/widgets.dart';
import 'package:flutter_web/model/chat/scroll_model.dart';
import 'package:flutter_web/viewmodel/chat/scroll_viewmodel.dart';
import 'package:get/get.dart';
import '../viewmodel/chat/chat_viewmodel.dart';
import '../viewmodel/login/login_viewmodel.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatViewModel>(ChatViewModel());
    Get.put<LoginViewModel>(LoginViewModel());
    Get.put<ScrollViewModel>(
      ScrollViewModel(
        scrollModel: ScrollModel(
          scrollController: ScrollController(),
        ),
      ),
    );
  }
}
