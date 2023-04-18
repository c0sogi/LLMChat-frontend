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
  bool get ready => !isQuerying && (_webSocketModel?.isConnected ?? false);

  ChatModel({
    required int chatRoomId,
    required void Function(dynamic) onMessageCallback,
  })  : _chatRoomId = chatRoomId,
        _onMessageCallback = onMessageCallback;

  Future<void> beginChat(String apiKey) async {
    print("beginning chat");
    _webSocketModel ??= WebSocketModel(
      onMessageCallback: (dynamic raw) {
        _messageHandler(raw);
        _onMessageCallback(raw);
      },
      onErrCallback: (dynamic err) => {
        _onMessageComplete(),
      },
      onSuccessConnectCallback: () => addChatMessage(
        message: '서버 연결에 성공했습니다.',
        isGptSpeaking: true,
        isFinished: true,
      ),
      onFailConnectCallback: () => addChatMessage(
        message: "서버 연결에 실패했습니다.",
        isGptSpeaking: true,
        isFinished: true,
      ),
    );
    await _webSocketModel!.connect("${Config.webSocketUrl}/$apiKey");
  }

  Future<void> endChat() async {
    if (_webSocketModel != null) {
      print("ending chat");
      await _webSocketModel!.close();
      addChatMessage(
        message: '채팅이 종료되었습니다.',
        isGptSpeaking: true,
        isFinished: true,
      );
    }
  }

  void toggleTranslate() {
    isTranslateToggled = !isTranslateToggled;
  }

  bool sendUserMessage({
    required String message,
  }) {
    if (message.isEmpty || !ready) {
      return false;
    }

    _webSocketModel!.sendJson({
      "msg": message,
      "translate": isTranslateToggled,
      "chat_room_id": _chatRoomId
    });
    addChatMessage(
      message: message,
      isGptSpeaking: false,
      isFinished: true,
    );
    addChatMessage(
      message: "",
      isGptSpeaking: true,
      isFinished: false,
      isLoading: true,
    );
    _startQuerying();
    return true;
  }

  void resendUserMessage() {
    // Implement resend message logic
    if (!ready) {
      return;
    }

    final String? lastUserMessage =
        lastChatMessageWhere((mm) => mm.isGptSpeaking == false)?.message.value;
    if (lastUserMessage == null) {
      return;
    }

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
    _startQuerying();
  }

  void clearAllChat() {
    if (!ready) {
      return;
    }

    _messages.clear();
    addChatMessage(
      message: "",
      isGptSpeaking: true,
      isFinished: false,
      isLoading: true,
    );
    _webSocketModel!.sendJson({
      "msg": "/clear",
      "translate": false,
      "chat_room_id": _chatRoomId,
    });
    _startQuerying();
  }

  void uploadImage() {
    // TODO: Implement upload image logic
  }
  void uploadAudio() {
    // TODO: Implement upload audio logic
  }

  void addChatMessage({
    required String message,
    required bool isFinished,
    required bool isGptSpeaking,
    bool? isLoading,
    DateTime? datetime,
  }) {
    _messages.add(MessageModel(
      message: message,
      isFinished: isFinished,
      isGptSpeaking: isGptSpeaking,
      isLoading: isLoading,
      datetime: datetime,
    ));
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

  MessageModel? lastChatMessageWhere(bool Function(MessageModel) test) {
    // get last element where test is true
    try {
      return _messages.lastWhere(test);
    } on StateError {
      return null;
    }
  }

  void _messageHandler(dynamic rawText) {
    final Map<String, dynamic> rcvd = jsonDecode(rawText);
    final int chatRoomId = rcvd["chatRoomId"] ?? -1;
    final String message = rcvd["msg"] ?? "";
    final bool isFinished = rcvd["finish"] ?? false;
    final bool isGptSpeaking = rcvd["is_user"] ?? false ? false : true;
    // if (chatRoomId != _chatRoomId) {
    //   return;
    // }
    print("Received: $rcvd");
    isTalking
        ? _onMessageAppend(appendMessage: message)
        : _onMessageCreate(
            message: message,
            isFinished: isFinished,
            isGptSpeaking: isGptSpeaking,
          );
    if (isFinished) {
      _onMessageComplete();
    }
  }

  void _onMessageAppend({required String appendMessage}) {
    print("Appending message: $appendMessage");
    final int index = _messages.lastIndexWhere((mm) => mm.isFinished == false);
    if (index != -1) {
      _messages[index].message(_messages[index].message.value + appendMessage);
      return;
    }
    addChatMessage(
      message: appendMessage,
      isGptSpeaking: true,
      isFinished: false,
    );
  }

  void _onMessageCreate({
    required String message,
    required bool isFinished,
    required bool isGptSpeaking,
  }) {
    print(
        "Creating message: $message, isFinished: $isFinished, isGptSpeaking: $isGptSpeaking");
    final int index =
        _messages.lastIndexWhere((mm) => mm.isLoading.value == true);
    if (index == -1) {
      addChatMessage(
        message: message,
        isFinished: isFinished,
        isGptSpeaking: isGptSpeaking,
      );
      isTalking = true;
      return;
    }
    _messages[index]
      ..isGptSpeaking = isGptSpeaking
      ..isFinished = isFinished
      ..message(message)
      ..isLoading(false);
    isTalking = true;
  }

  void _onMessageComplete() {
    isTalking = false;
    isQuerying = false;
    lastChatMessageWhere((mm) => mm.isFinished == false)?.isFinished = true;
  }

  void _startQuerying() {
    isQuerying = true;
  }
}
