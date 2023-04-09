import 'dart:convert';
import 'package:flutter_web/model/chat/websocket_model.dart';
import '../../app/app_config.dart';
import '../../model/message/message_model.dart';

class ChatModel {
  bool isTranslateToggled = false;
  bool isTalking = false;
  WebSocketModel? _webSocketModel;
  final int _chatRoomId;
  final List<MessageModel> _messages = <MessageModel>[];
  final void Function(dynamic) _onMessageCallback;

  int get length => _messages.length;
  List get messages => _messages;

  ChatModel({
    required int chatRoomId,
    required void Function(dynamic) onMessageCallback,
  })  : _chatRoomId = chatRoomId,
        _onMessageCallback = onMessageCallback;

  void _messageHandler(dynamic rawText) {
    final Map<String, dynamic> receivedChatMessage = jsonDecode(rawText);
    final String? msg = receivedChatMessage["msg"];
    final bool? finish = receivedChatMessage["finish"];
    final bool? isUser = receivedChatMessage["isUser"];
    final int? chatRoomId = receivedChatMessage["chatRoomId"];

    if (msg != null) {
      // 메시지가 포함된 경우
      isTalking
          ? appendToLastChatMessageWhere((mm) => mm.isFinished == false, msg)
          : () {
              addChatMessage(
                MessageModel(
                  message: msg,
                  isGptSpeaking: isUser ?? false ? false : true,
                  isFinished: finish ?? false,
                ),
              );
              isTalking = true;
            }();
    }

    if (finish == true) {
      // GPT가 말을 끝낸 경우
      lastChatMessageWhere((mm) => mm.isFinished == false)?.isFinished = true;
      isTalking = false;
    }
  }

  void beginChat(String apiKey) {
    print("웹소켓 연결됨?");
    // ensure there's no duplicated channel
    if (_webSocketModel?.isConnected ?? false) {
      print("closing channel...");
      _webSocketModel!.close();
    }
    // initialize channel
    _webSocketModel = WebSocketModel(
      url: "${Config.webSocketUrl}/$apiKey",
      onMessageCallback: (dynamic raw) {
        _messageHandler(raw);
        _onMessageCallback(raw);
      },
      onErrCallback: (dynamic err) => print(err),
      onSuccessConnectCallback: () => addChatMessage(
        MessageModel(
          message: '안녕하세요! 무엇을 도와드릴까요?',
          isGptSpeaking: true,
          isFinished: true,
        ),
      ),
      onFailConnectCallback: () => addChatMessage(
        MessageModel(
          message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다!!",
          isGptSpeaking: true,
          isFinished: true,
        ),
      ),
    );
    _webSocketModel!.listen();
    print("connected to ${Config.webSocketUrl}/$apiKey");
    print("웹소켓 연결됨");
  }

  void endChat() {
    if (_webSocketModel != null) {
      _webSocketModel!.close();
      _messages.add(
        MessageModel(
          message: '채팅이 종료되었습니다.',
          isGptSpeaking: true,
          isFinished: true,
        ),
      );
    }
  }

  void addChatMessage(MessageModel message) {
    _messages.add(message);
  }

  void popChatMessage() {
    if (_messages.isNotEmpty) {
      _messages.removeLast();
    }
  }

  void popChatMessageWhere(bool Function(MessageModel) test) {
    _messages.removeWhere(test);
  }

  void popLastChatMessageWhere(bool Function(MessageModel) test) {
    final int index = _messages.lastIndexWhere(test);
    if (index != -1) {
      _messages.removeAt(index);
    }
  }

  void appendToLastChatMessageWhere(
      bool Function(MessageModel) test, String message) {
    final int index = _messages.lastIndexWhere(test);
    if (index != -1) {
      _messages[index].message += message;
    }
  }

  MessageModel? lastChatMessageWhere(bool Function(MessageModel) test) {
    // get last element where test is true
    try {
      return _messages.lastWhere(test);
    } on StateError {
      return null;
    }
  }

  void clearChatMessage() {
    _messages.clear();
  }

  void toggleTranslate() {
    isTranslateToggled = !isTranslateToggled;
  }

  void sendUserMessage({
    required String message,
  }) {
    if (message.isNotEmpty && !isTalking) {
      _webSocketModel != null
          ? () {
              _webSocketModel!.sendJson({
                "msg": message,
                "translate": isTranslateToggled,
                "chat_room_id": _chatRoomId
              });
              addChatMessage(
                MessageModel(
                  message: message,
                  isGptSpeaking: false,
                  isFinished: isTranslateToggled ? false : true,
                ),
              );
            }()
          : addChatMessage(
              MessageModel(
                message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다..",
                isGptSpeaking: true,
                isFinished: true,
              ),
            );
    }
  }

  void resendUserMessage() {
    // Implement resend message logic
    if (!isTalking) {
      final String? lastUserMessage =
          lastChatMessageWhere((mm) => mm.isGptSpeaking == false)?.message;
      if (_webSocketModel != null && lastUserMessage != null) {
        _webSocketModel!.sendJson({
          "msg": "/retry",
          "translate": false,
          "chat_room_id": _chatRoomId,
        });
        _webSocketModel!.sendJson({
          "msg": lastUserMessage,
          "translate": isTranslateToggled,
          "chat_room_id": _chatRoomId,
        });
      }
      if (_webSocketModel == null) {
        addChatMessage(
          MessageModel(
            message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다.",
            isGptSpeaking: true,
            isFinished: true,
          ),
        );
      }
    }
  }

  void clearAllChat() {
    // Implement clear chat logic
    if (!isTalking) {
      _messages.clear();
      _webSocketModel != null
          ? _webSocketModel!.sendJson({
              "msg": "/clear",
              "translate": false,
              "chat_room_id": _chatRoomId,
            })
          : addChatMessage(
              MessageModel(
                message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다.",
                isGptSpeaking: true,
                isFinished: true,
              ),
            );
    }
  }

  void uploadImage() {
    // TODO: Implement upload image logic
  }
  void uploadAudio() {
    // TODO: Implement upload audio logic
  }
}
