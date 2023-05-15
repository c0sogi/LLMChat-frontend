import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../../model/chat/chat_model.dart';
import '../../model/message/message_model.dart';

class ChatRoomModel {
  final String chatRoomId;
  final RxString chatRoomName;
  final RxBool isChatRoomNameEditing = false.obs;
  ChatRoomModel({
    required this.chatRoomId,
    String? chatRoomName,
  }) : chatRoomName = (chatRoomName ?? "").obs;
}

class ChatViewModel extends GetxController {
  // models
  Rx<ChatModel>? _chatModel;
  final TextEditingController messageController = TextEditingController();
  late final FocusNode messageFocusNode = FocusNode(
      debugLabel: "messageFocusNode",
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event.isShiftPressed || !(event.logicalKey.keyLabel == 'Enter')) {
          return KeyEventResult.ignored;
        }
        if (event is RawKeyDownEvent) {
          sendMessage();
        }
        return KeyEventResult.handled;
      });
  final ScrollController _scrollController = ScrollController();
  final RxBool isChatModelInitialized = false.obs;
  final RxList<ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;
  final RxInt lengthOfMessages = 0.obs;
  final List<MessageModel> messagePlaceholder = <MessageModel>[
    MessageModel(
      message:
          "You can start chat by select API key from the top left side. If the API key does not exist, you must create an API key through the website administrator. \n\n왼쪽 상단에서 API 키를 선택하여 채팅을 시작할 수 있습니다. 만약 API키가 존재하지 않는 경우, 사이트 관리자를 통해 API키를 생성해야 합니다.",
      isFinished: true,
      isGptSpeaking: true,
    ),
    MessageModel(
        message: Config.markdownExample, isFinished: true, isGptSpeaking: true)
  ];
  bool _autoScroll = true;

  bool get isTalking => _chatModel?.value.isTalking ?? false;
  bool get isQuerying => _chatModel?.value.isQuerying ?? false;
  ScrollController get scrollController => _scrollController;
  bool get isTranslateToggled => _chatModel?.value.isTranslateToggled ?? false;
  int get length => lengthOfMessages.value;
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

  void onKeyFocusNode(
      {required RawKeyEvent event, required BuildContext? context}) {
    if (!event.isKeyPressed(LogicalKeyboardKey.enter) || event.isShiftPressed) {
      return;
    }
    // unfocus textfield when mobile device
    if (context != null) {
      GetPlatform.isMobile
          ? FocusScope.of(context).unfocus()
          : FocusScope.of(context).requestFocus(messageFocusNode);
    }
    // send message
    sendMessage();
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

  Future<void> beginChat({
    required String apiKey,
  }) async {
    Get.find<ThemeViewModel>().toggleTheme(true);
    // check channel is late initialized or not
    if (isChatModelInitialized.value) {
      await _chatModel?.value.endChat();
      _chatModel?.update((_) => {});
    }
    _chatModel = ChatModel(
      updateViewCallback: (dynamic raw) => _chatModel?.update((val) {}),
      chatRooms: chatRooms,
      lengthOfMessages: lengthOfMessages,
    ).obs;
    await _chatModel!.value.beginChat(apiKey);
    _chatModel!.update((_) {});
    isChatModelInitialized(true);
  }

  Future<void> endChat() async {
    Get.find<ThemeViewModel>().toggleTheme(false);
    await _chatModel?.value.endChat();
    _chatModel?.update((_) {});
  }

  void changeChatRoom({required String chatRoomId}) {
    _chatModel?.update((val) => val!.changeChatRoom(
          chatRoomId: chatRoomId,
        ));
  }

  void deleteChatRoom({required String chatRoomId}) {
    _chatModel?.update((val) {
      val!.deleteChatRoom(chatRoomId: chatRoomId);
    });
  }

  void sendMessage() {
    if (messageController.text.isEmpty) {
      return;
    }
    _chatModel?.update((val) {
      if (val!.sendUserMessage(message: messageController.text)) {
        messageController.clear();
      }
    });
  }

  void sendText(String text) {
    _chatModel?.value.sendText(text);
  }

  void sendJson(Map<String, dynamic> json) {
    _chatModel?.value.sendJson(json);
  }

  void resendMessage() {
    _chatModel?.update((val) => val!.resendUserMessage());
  }

  void clearChat({required bool clearViewOnly}) {
    _chatModel?.update((val) => val!.clearChat(
          clearViewOnly: clearViewOnly,
        ));
  }

  void toggleTranslate() {
    _chatModel?.update((val) => val!.toggleTranslate());
  }

  Future<void> uploadFile() async {
    if (!isChatModelInitialized.value) {
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      await _chatModel?.value.uploadFile(
        filename: result.files.single.name,
        file: result.files.single.bytes,
      );
      _chatModel?.update((val) {});
    }
  }

  void uploadImage() {
    // TODO: Implement upload image logic
    _chatModel?.update(
      (val) => val!.addChatMessage(
        message: "Uploading image not supported yet",
        isGptSpeaking: false,
        isFinished: true,
      ),
    );
  }

  void uploadAudio() {
    // TODO: Implement upload audio logic
    _chatModel?.update(
      (val) => val!.addChatMessage(
        message: "Uploading audio not supported yet",
        isGptSpeaking: false,
        isFinished: true,
      ),
    );
  }
}
