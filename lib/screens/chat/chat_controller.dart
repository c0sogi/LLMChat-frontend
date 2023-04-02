import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/html.dart';

import '../../app/app_config.dart';

class ViewMessage {
  RxString message;
  RxBool isFinished;
  final bool isGptSpeaking;

  ViewMessage({
    required String message,
    required bool isFinished,
    required this.isGptSpeaking,
  })  : message = message.obs,
        isFinished = isFinished.obs;
}

Map<String, dynamic> toReceivedChatMessage(String rawText) {
  Map<String, dynamic> json = jsonDecode(rawText);
  return {
    'msg': json['msg'],
    'finish': json['finish'],
    'isUser': json['is_user'],
    'chatRoomId': json['chat_room_id'],
  };
}

String toSendChatMessage({
  required String msg,
  required bool translate,
  required int chatRoomId,
}) {
  return jsonEncode({
    'msg': msg,
    'translate': translate,
    'chat_room_id': chatRoomId,
  });
}

class ChatController extends GetxController {
  // controllers
  late TextEditingController messageController;
  late ScrollController scrollController;
  late FocusNode messageFocusNode;
  late HtmlWebSocketChannel channel;

  // observers
  late final RxBool isTranslateToggled;
  late final RxList<ViewMessage> messages;

  // variables
  late bool autoScroll;
  late bool isConnected;
  late bool isTalking;
  late int chatRoomId;

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
    messages = <ViewMessage>[].obs;

    // initialize variables
    autoScroll = true;
    isConnected = false;
    isTalking = false;
    chatRoomId = 0;
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

  void beginChat(String apiKey) {
    // check channel is late initialized or not
    try {
      print("closing channel...");
      channel.sink.close();
    } catch (e) {
      print("channel is not initialized");
    }
    channel = HtmlWebSocketChannel.connect(
      "${Config.webSocketUrl}/$apiKey",
    );
    onConnectWebSocket();
    update();
  }

  void endChat() {
    try {
      print("closing channel...");
      channel.sink.close();
      messages.add(
        ViewMessage(
          message: '채팅이 종료되었습니다.',
          isGptSpeaking: true,
          isFinished: true,
        ),
      );
    } catch (e) {
      print("channel is not initialized");
    }
    update();
  }

  void onConnectWebSocket() {
    try {
      isConnected = true;
      channel.stream.listen(
        (rawText) => handleRawText(rawText),
        onDone: () {
          print("Websocket connection closed");
          isConnected = false;
        },
        onError: (e) {
          print("Websocket connection error: $e");
          isConnected = false;
        },
      );
    } catch (e) {
      print("connectWebsocket Error: $e");
      messages.add(
        ViewMessage(
          message: e.toString(),
          isGptSpeaking: true,
          isFinished: true,
        ),
      );
      isConnected = false;
    }
    messages.add(
      ViewMessage(
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
    update();
  }

  void handleRawText(dynamic rawText) {
    final Map<String, dynamic> receivedChatMessage =
        toReceivedChatMessage(rawText);
    final String? msg = receivedChatMessage["msg"];
    final bool? finish = receivedChatMessage["finish"];
    final bool? isUser = receivedChatMessage["isUser"];
    final int? chatRoomId = receivedChatMessage["chatRoomId"];

    if (msg != null) {
      // 메시지가 포함된 경우
      if (isTalking) {
        try {
          final lastUnfinishedMessage = messages.lastWhere(
            (element) => element.isFinished.value == false,
          );
          lastUnfinishedMessage
              .message(lastUnfinishedMessage.message.value + msg);
        } on StateError {
          print("no message to update");
        }
      } else {
        messages.add(
          ViewMessage(
            message: msg,
            isGptSpeaking: isUser ?? false ? false : true,
            isFinished: finish ?? false,
          ),
        );
        isTalking = true;
      }
    }

    if (finish == true) {
      // GPT가 말을 끝낸 경우
      isTalking = false;
      try {
        messages
            .lastWhere((element) => element.isFinished.value == false)
            .isFinished(true);
      } on StateError {
        print("no message to update");
      }
    }
    scrollToBottom(animated: true);
    update();
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty && !isTalking) {
      // Send message to GPT, json format: {"msg": "Hello GPT!"}
      // check if channel is initialized or not
      // if not, show error message
      try {
        channel.sink.add(
          toSendChatMessage(
              msg: messageController.text,
              translate: isTranslateToggled.value,
              chatRoomId: chatRoomId),
        );
      } catch (e) {
        print("channel is not initialized");
        messages.add(
          ViewMessage(
            message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다.",
            isGptSpeaking: true,
            isFinished: true,
          ),
        );
        return;
      }

      // Add message to message list
      messages.add(
        ViewMessage(
          message: messageController.text,
          isGptSpeaking: false,
          isFinished: isTranslateToggled.value ? false : true,
        ),
      );
      messageController.clear();
      print("message sent");
      scrollToBottom(animated: true);
      update();
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
          channel.sink.add(toSendChatMessage(
            msg: "/clear",
            translate: false,
            chatRoomId: chatRoomId,
          ));
          channel.sink.add(toSendChatMessage(
            msg: lastUserMessage,
            translate: isTranslateToggled.value,
            chatRoomId: chatRoomId,
          ));
        } catch (e) {
          print("channel is not initialized");
          messages.add(
            ViewMessage(
              message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다.",
              isGptSpeaking: true,
              isFinished: true,
            ),
          );
          return;
        }

        print("message resent");
      } catch (e) {
        print("no message to resend");
      }
    }
    update();
  }

  void clearChat() {
    // Implement clear chat logic
    if (!isTalking) {
      messages.clear();
      try {
        channel.sink.add(toSendChatMessage(
          msg: "/clear",
          translate: false,
          chatRoomId: chatRoomId,
        ));
      } catch (e) {
        print("channel is not initialized");
        messages.add(
          ViewMessage(
            message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다.",
            isGptSpeaking: true,
            isFinished: true,
          ),
        );
        return;
      }
      print("chat cleared");
    }
    update();
  }

  void toggleTranslate() {
    isTranslateToggled(!isTranslateToggled.value);
  }

  void uploadImage() {
    // TODO: Implement upload image logic
  }
  void uploadAudio() {
    // TODO: Implement upload audio logic
  }
}
