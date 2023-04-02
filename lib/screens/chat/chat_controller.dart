import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/html.dart';

import '../../app/app_config.dart';

class Message {
  RxString message;
  RxBool isFinished;
  final bool isGptSpeaking;

  Message({
    required String message,
    required bool isFinished,
    required this.isGptSpeaking,
  })  : message = message.obs,
        isFinished = isFinished.obs;
}

class ChatController extends GetxController {
  // controllers
  late TextEditingController messageController;
  late ScrollController scrollController;
  late FocusNode messageFocusNode;
  late HtmlWebSocketChannel channel;

  // observers
  late final RxBool isTranslateToggled;
  late final RxList<Message> messages;

  // variables
  late bool autoScroll;
  late bool isConnected;
  late bool isTalking;

  @override
  void onInit() {
    super.onInit();
    // initialize controllers
    messageController = TextEditingController();
    scrollController = ScrollController();
    scrollController.addListener(scrollCallback);
    messageFocusNode = FocusNode();

    // initialize observers
    isTranslateToggled = false.obs;
    messages = <Message>[].obs;

    // initialize variables
    autoScroll = true;
    isConnected = false;
    isTalking = false;
  }

  @override
  void onClose() {
    super.onClose();
    // unregister controllers
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    channel.sink.close();
  }

  void beginChat(String token) {
    // check channel is late initialized or not
    try {
      channel.sink.close();
    } catch (e) {
      print("channel is not initialized");
    }
    channel = HtmlWebSocketChannel.connect(
      "${Config.webSocketUrl}/$token",
    );
    onConnectWebSocket();
  }

  void onConnectWebSocket() {
    try {
      isConnected = true;
      channel.stream.listen(
        (message) => handleMessage(message),
        onDone: () {
          print("Websocket connection closed");
          isConnected = false;
          update();
        },
        onError: (e) {
          print("Websocket connection error: $e");
          isConnected = false;
          update();
        },
      );
    } catch (e) {
      print("connectWebsocket Error: $e");
      messages.add(
        Message(
          message: e.toString(),
          isGptSpeaking: true,
          isFinished: true,
        ),
      );
      isConnected = false;
    }
    messages.add(
      Message(
        message: '안녕하세요! 무엇을 도와드릴까요?',
        isGptSpeaking: true,
        isFinished: true,
      ),
    );
    update();
  }

  void scrollToBottom({double offset = 0, required bool animated}) {
    if (scrollController.hasClients &&
        autoScroll &&
        scrollController.position.hasContentDimensions) {
      animated
          ? scrollController.animateTo(
              scrollController.position.maxScrollExtent + offset,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
            )
          : scrollController.jumpTo(
              scrollController.position.maxScrollExtent + offset,
            );
    }
  }

  void scrollCallback() {
    if (scrollController.hasClients) {
      scrollController.offset + Config.scrollOffset >=
              scrollController.position.maxScrollExtent
          ? autoScroll = true
          : autoScroll = false;
    }
  }

  void handleMessage(dynamic message) {
    switch (message) {
      case "\n\n":
        // GPT starts speaking
        print("GPT start speaking");
        isTalking = true;
        messages.add(
          Message(
            message: "",
            isGptSpeaking: true,
            isFinished: false,
          ),
        );
        break;
      case "\n\n\n":
        // GPT stops speaking
        print("GPT stopped speaking");
        isTalking = false;
        try {
          final Message lastUnfinishedMessage = messages
              .lastWhere((element) => element.isFinished.value == false);
          lastUnfinishedMessage.isFinished(true);
        } on StateError {
          print("no message to update");
        }
        scrollToBottom(animated: true);
        break;
      default:
        try {
          final Message lastUnfinishedMessage = messages
              .lastWhere((element) => element.isFinished.value == false);
          lastUnfinishedMessage
              .message(lastUnfinishedMessage.message.value + message);
        } on StateError {
          print("no message to update");
        }
    }
    update();
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty && !isTalking) {
      // Send message to GPT, json format: {"user_message": "Hello GPT!"}
      // check if channel is initialized or not
      try {
        channel.sink.add(jsonEncode({"user_message": messageController.text}));
      } catch (e) {
        print("channel is not initialized");
        messages.add(Message(
          message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다.",
          isGptSpeaking: true,
          isFinished: true,
        ));
        return;
      }
      messages.add(
        Message(
          message: messageController.text,
          isGptSpeaking: false,
          isFinished: true,
        ),
      );
      messageController.clear();
      update();
      print("message sent");
      scrollToBottom(animated: true);
    }
  }

  void resendMessage() {
    // Implement resend message logic
    if (!isTalking) {
      try {
        final String lastUserMessage = messages
            .lastWhere((element) => element.isGptSpeaking == false)
            .message
            .value;
        try {
          channel.sink.add(jsonEncode({"user_message": "/retry"}));
          channel.sink.add(jsonEncode({"user_message": lastUserMessage}));
        } catch (e) {
          print("channel is not initialized");
          messages.add(
            Message(
              message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다.",
              isGptSpeaking: true,
              isFinished: true,
            ),
          );
          return;
        }

        update();
        print("message resent");
      } catch (e) {
        print("no message to resend");
      }
    }
  }

  void clearChat() {
    // Implement clear chat logic
    if (!isTalking) {
      messages.clear();
      try {
        channel.sink.add(jsonEncode({"user_message": "/clear"}));
      } catch (e) {
        print("channel is not initialized");
        messages.add(
          Message(
            message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다.",
            isGptSpeaking: true,
            isFinished: true,
          ),
        );
        return;
      }
      update();
      print("chat cleared");
    }
  }

  void toggleTranslate() {
    isTranslateToggled(!isTranslateToggled.value);
    update();
  }

  void uploadImage() {
    // TODO: Implement upload image logic
  }
  void uploadAudio() {
    // TODO: Implement upload audio logic
  }
}
