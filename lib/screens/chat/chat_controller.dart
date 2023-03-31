import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/html.dart';

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
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  // scroll event listener

  bool autoScroll = true;
  bool isConnected = false;
  bool isTalking = false;
  double scrollOffset = 0;
  static const String startMessageWith = "\n\n";
  static const String endMessageWith = "\n\n\n";

  RxList<Message> messages = <Message>[].obs;
  late HtmlWebSocketChannel channel = HtmlWebSocketChannel.connect(
      'wss://YOUR_API_URL');

  @override
  void onInit() {
    super.onInit();
    connectWebSocket();
    scrollController.addListener(scrollCallback);
  }

  void connectWebSocket() {
    try {
      isConnected = true;
      messages.add(
        Message(
          message: '안녕하세요! 무엇을 도와드릴까요?',
          isGptSpeaking: true,
          isFinished: true,
        ),
      );
      channel.stream.listen((message) {
        handleMessage(message);
      });
    } catch (e) {
      messages.add(Message(
        message: e.toString(),
        isGptSpeaking: true,
        isFinished: true,
      ));
      isConnected = false;
    }
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
      scrollController.offset + 100 >= scrollController.position.maxScrollExtent
          ? autoScroll = true
          : autoScroll = false;
    }
  }

  void handleMessage(String message) {
    switch (message) {
      case startMessageWith:
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
      case endMessageWith:
        // GPT stops speaking
        print("GPT stopped speaking");
        isTalking = false;
        messages[messages.length - 1].isFinished(true);
        scrollToBottom(animated: true);
        break;
      default:
        messages[messages.length - 1]
            .message("${messages[messages.length - 1].message.value}$message");
    }
    update();
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty && !isTalking) {
      // Send message to GPT, json format: {"user_message": "Hello GPT!"}
      channel.sink.add(jsonEncode({"user_message": messageController.text}));
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
        channel.sink.add(jsonEncode({"user_message": "/retry"}));
        channel.sink.add(jsonEncode({"user_message": lastUserMessage}));
        messages[messages.length - 1].isFinished(false);
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
      channel.sink.add(jsonEncode({"user_message": "/clear"}));
      update();
      print("chat cleared");
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    channel.sink.close();
    super.onClose();
  }
}
