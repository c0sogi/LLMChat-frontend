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
  ChatModel? _chatModel;
  bool _autoScroll = true;
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxInt tokens = 0.obs;
  final RxBool isChatModelInitialized = false.obs;
  final RxString selectedModel = "".obs;
  final RxBool isQuerying = false.obs;
  final RxBool isTranslateToggled = false.obs;
  final RxBool isQueryToggled = false.obs;
  final RxBool isBrowseToggled = false.obs;
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

  ScrollController get scrollController => _scrollController;
  RxList<String>? get models => _chatModel?.models;
  RxList<MessageModel>? get messages => _chatModel?.messages;
  RxList<ChatRoomModel>? get chatRooms => _chatModel?.chatRooms;
  void Function({
    required ChatAction action,
    String? chatRoomId,
    String? chatRoomName,
    String? chatModelName,
    String? messageRole,
    String? messageUuid,
  })? get performChatAction => _chatModel?.performChatAction;
  Function? get resendUserMessage => _chatModel?.resendUserMessage;
  Function? get clearChat => _chatModel?.clearChat;

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
    _chatModel?.clearChat(clearViewOnly: true);
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
      await _chatModel?.endChat();
    }
    _chatModel = ChatModel(
      tokens: tokens,
      selectedModel: selectedModel,
      isQuerying: isQuerying,
      isTranslateToggled: isTranslateToggled,
      isQueryToggled: isQueryToggled,
      isBrowseToggled: isBrowseToggled,
    );
    await _chatModel!.beginChat(apiKey);
    isChatModelInitialized(true);
  }

  Future<void> endChat() async {
    Get.find<ThemeViewModel>().toggleTheme(false);
    await _chatModel?.endChat();
  }

  void sendMessage() {
    if (messageController.text.isEmpty || _chatModel == null) {
      return;
    }
    if (_chatModel!.sendUserMessage(message: messageController.text)) {
      messageController.clear();
    }
  }

  Future<void> uploadFile() async {
    if (!isChatModelInitialized.value) {
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      await _chatModel?.uploadFile(
        filename: result.files.single.name,
        file: result.files.single.bytes,
      );
    }
  }

  void triggerAnimation() {
    tokens(tokens.value);
  }
}
