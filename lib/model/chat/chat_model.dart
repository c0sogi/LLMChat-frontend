import 'dart:convert';
import 'package:flutter_web/model/chat/websocket_model.dart';
import '../../app/app_config.dart';
import '../../model/message/message_model.dart';

class ChatModel {
  bool isTranslateToggled = false;
  bool isTalking = false;
  bool isQuerying = false;
  WebSocketModel? _webSocketModel;
  final int _chatRoomId;
  final List<MessageModel> _messages = <MessageModel>[];
  final void Function(dynamic) _onMessageCallback;

  int get length => _messages.length;
  List<MessageModel> get messages => _messages;

  ChatModel({
    required int chatRoomId,
    required void Function(dynamic) onMessageCallback,
  })  : _chatRoomId = chatRoomId,
        _onMessageCallback = onMessageCallback;

  void messageHandler(dynamic rawText) {
    final Map<String, dynamic> rcvd = jsonDecode(rawText);
    // if (rcvd["chatRoomId"] != _chatRoomId) {
    //   return; // ignore messages from other chat rooms
    // }
    print(rcvd);
    if (rcvd["msg"] != null) {
      // 메시지가 포함된 경우
      if (isTalking) {
        // 이미 말하고 있는 경우 (이어서 말하기)
        appendToLastChatMessageWhere(
            (mm) => mm.isFinished == false, rcvd["msg"]);
      } else {
        // 말하고 있지 않은 경우 (새로운 대화)
        isTalking = true;
        setLastLoadingMessage(
            message: rcvd["msg"],
            isFinished: rcvd["finish"],
            isGptSpeaking: rcvd["is_user"] ?? false ? false : true);
      }
    }
    if (rcvd["finish"] == true) {
      // 대화가 끝난 경우
      lastChatMessageWhere((mm) => mm.isFinished == false)?.isFinished = true;
      isTalking = false;
      isQuerying = false;
    }
  }

  Future<void> beginChat(String apiKey) async {
    // ensure there's no duplicated channel
    if (_webSocketModel?.isConnected ?? false) {
      await _webSocketModel!.close();
      _webSocketModel = null;
    }
    // initialize channel
    _webSocketModel = WebSocketModel(
      url: "${Config.webSocketUrl}/$apiKey",
      onMessageCallback: (dynamic raw) {
        messageHandler(raw);
        _onMessageCallback(raw);
      },
      onErrCallback: (dynamic err) => {
        isQuerying = false,
        isTalking = false,
      },
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
    await _webSocketModel!.listen();
  }

  Future<void> endChat() async {
    if (_webSocketModel != null) {
      await _webSocketModel!.close();
      _webSocketModel = null;
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
      _messages[index].message(_messages[index].message.value + message);
    }
  }

  void setLastLoadingMessage({
    required String message,
    bool isGptSpeaking = true,
    isFinished = false,
  }) {
    final int index =
        _messages.lastIndexWhere((mm) => mm.isLoading.value == true);
    if (index != -1) {
      _messages[index].isGptSpeaking = isGptSpeaking;
      _messages[index].isFinished = isFinished;
      _messages[index].message(message);
      _messages[index].isLoading(false);
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

  void clearChatMessageExceptLoading() {
    _messages.removeWhere((mm) => mm.isLoading.value == false);
  }

  void toggleTranslate() {
    isTranslateToggled = !isTranslateToggled;
  }

  bool sendUserMessage({
    required String message,
  }) {
    if (message.isNotEmpty && !isQuerying && _webSocketModel != null) {
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
      addChatMessage(
        MessageModel(
          message: "",
          isGptSpeaking: true,
          isFinished: false,
          isLoading: true,
        ),
      );
      isQuerying = true;
      return true;
    }
    return false;
  }

  void resendUserMessage() {
    // Implement resend message logic
    if (!isQuerying && _webSocketModel != null) {
      final String? lastUserMessage =
          lastChatMessageWhere((mm) => mm.isGptSpeaking == false)
              ?.message
              .value;
      if (lastUserMessage != null) {
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
      isQuerying = true;
    }
  }

  void clearAllChat() {
    // Implement clear chat logic
    if (!isQuerying && _webSocketModel != null) {
      _messages.clear();
      addChatMessage(MessageModel(
        message: "",
        isGptSpeaking: true,
        isFinished: false,
        isLoading: true,
      ));
      _webSocketModel!.sendJson({
        "msg": "/clear",
        "translate": false,
        "chat_room_id": _chatRoomId,
      });
      isQuerying = true;
    }
  }

  void uploadImage() {
    // TODO: Implement upload image logic
  }
  void uploadAudio() {
    // TODO: Implement upload audio logic
  }
}
