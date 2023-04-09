import 'package:flutter/material.dart';
import 'package:flutter_web/viewmodel/chat/scroll_viewmodel.dart';
import 'package:get/get.dart';

import '../../model/chat/chat_model.dart';

class ChatViewModel extends GetxController {
  // models
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  Rx<ChatModel>? _chatModel;
  RxBool isChatModelInitialized = false.obs;

  bool get isTranslateToggled => _chatModel?.value.isTranslateToggled ?? false;
  int get length => _chatModel?.value.messages.length ?? 0;
  List get messages => _chatModel?.value.messages ?? [];
  // RxBool get isChatModelInitialized => _chatModel != null;

  @override
  void onClose() {
    super.onClose();
    messageController.dispose();
    messageFocusNode.dispose();
    _chatModel?.close();
  }

  void beginChat({required String apiKey, required int chatRoomId}) {
    // check channel is late initialized or not
    print("beginChat() called");
    _chatModel = ChatModel(
      chatRoomId: chatRoomId,
      onMessageCallback: (dynamic raw) =>
          Get.find<ScrollViewModel>().scrollToBottom(animated: false),
    ).obs;
    isChatModelInitialized(true);
    _chatModel!.update(
      (val) => val!.beginChat(apiKey),
    );
    Get.find<ScrollViewModel>().scrollToBottom(animated: false);
  }

  void endChat() {
    _chatModel?.update((val) => val!.endChat());
  }

  void sendMessage() {
    _chatModel?.update(
      (val) => val!.sendUserMessage(message: messageController.text),
    );
    messageController.clear();
    Get.find<ScrollViewModel>().scrollToBottom(animated: false);
  }

  void resendMessage() {
    _chatModel?.update((val) => val!.resendUserMessage());
    Get.find<ScrollViewModel>().scrollToBottom(animated: false);
  }

  void clearChat() {
    _chatModel?.update((val) => val!.clearAllChat());
  }

  void toggleTranslate() {
    _chatModel?.update((val) => val!.toggleTranslate());
  }

  void uploadImage() {
    // TODO: Implement upload image logic
  }
  void uploadAudio() {
    // TODO: Implement upload audio logic
  }
}
