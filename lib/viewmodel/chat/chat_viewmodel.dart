import 'package:flutter/material.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../../model/chat/chat_model.dart';
import '../../model/message/message_model.dart';

class ChatViewModel extends GetxController {
  // models
  late Rx<ChatModel>? _chatModel;
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final RxBool isChatModelInitialized = false.obs;
  final List<MessageModel> messagePlaceholder = <MessageModel>[
    MessageModel(
      message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다.",
      isFinished: true,
      isGptSpeaking: true,
    )
  ];
  bool _autoScroll = true;

  bool get isTalking => _chatModel?.value.isTalking ?? false;
  ScrollController get scrollController => _scrollController;
  bool get isTranslateToggled => _chatModel?.value.isTranslateToggled ?? false;
  int? get length => _chatModel?.value.messages.length;
  List<MessageModel>? get messages => _chatModel?.value.messages;
  @override
  void onInit() {
    super.onInit();
    _scrollController.addListener(
      () => {
        if (_scrollController.hasClients)
          {
            _scrollController.offset + Config.scrollOffset >=
                    _scrollController.position.maxScrollExtent
                ? _autoScroll = true
                : _autoScroll = false
          }
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
    messageController.dispose();
    messageFocusNode.dispose();
    _chatModel?.close();
  }

  void scrollToBottomCallback(Duration duration) {
    if (scrollController.hasClients &&
        _autoScroll &&
        scrollController.position.hasContentDimensions) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  Future<void> scrollToBottomAnimated() async {
    if (scrollController.hasClients &&
        _autoScroll &&
        scrollController.position.hasContentDimensions) {
      await scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void beginChat({required String apiKey, required int chatRoomId}) {
    Get.find<ThemeViewModel>().toggleTheme(true);
    // check channel is late initialized or not
    if (isChatModelInitialized.value) {
      _chatModel?.update((val) => val!.endChat());
    }
    _chatModel = ChatModel(
      chatRoomId: chatRoomId,
      onMessageCallback: (dynamic raw) {
        if (!isTalking) {
          _chatModel?.update((val) {});
        }
      },
    ).obs;
    _chatModel!.update(
      (val) => val!.beginChat(apiKey),
    );
    isChatModelInitialized(true);
  }

  void endChat() {
    Get.find<ThemeViewModel>().toggleTheme(false);
    _chatModel?.update((val) => val!.endChat());
  }

  void sendMessage() {
    _chatModel?.update((val) {
      if (val!.sendUserMessage(message: messageController.text)) {
        messageController.clear();
      }
    });
  }

  void resendMessage() {
    _chatModel?.update((val) => val!.resendUserMessage());
  }

  void clearChat() {
    _chatModel?.update((val) => val!.clearAllChat());
  }

  void toggleTranslate() {
    _chatModel?.update((val) => val!.toggleTranslate());
  }

  void uploadImage() {
    // TODO: Implement upload image logic
    _chatModel?.update(
      (val) => val!.addChatMessage(
        MessageModel(
          message: "이미지 업로드 [미지원]",
          isGptSpeaking: false,
          isFinished: true,
        ),
      ),
    );
  }

  void uploadAudio() {
    // TODO: Implement upload audio logic
    _chatModel?.update(
      (val) => val!.addChatMessage(
        MessageModel(
          message: "음원 업로드 [미지원]",
          isGptSpeaking: false,
          isFinished: true,
        ),
      ),
    );
  }
}
