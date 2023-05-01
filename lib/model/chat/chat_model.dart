import 'dart:convert';
import 'package:flutter_web/model/chat/websocket_model.dart';
import 'package:get/get.dart';
import '../../app/app_config.dart';
import '../../model/message/message_model.dart';

class ChatModel {
  bool isTranslateToggled = false;
  bool isTalking = false;
  bool _isQuerying = false;
  bool _isInitialized = false;
  WebSocketModel? _webSocketModel;
  String? _chatRoomId;
  final List<MessageModel> _messages = <MessageModel>[];
  final void Function(dynamic) _updateViewCallback;
  final RxList<String> _chatRoomIds;

  int get length => _messages.length;
  List<MessageModel> get messages => _messages;
  bool get ready =>
      !_isQuerying && (_webSocketModel?.isConnected ?? false) && _isInitialized;

  ChatModel({
    required void Function(dynamic) updateViewCallback,
    required RxList<String> chatRoomIds,
  })  : _updateViewCallback = updateViewCallback,
        _chatRoomIds = chatRoomIds;

  Future<void> beginChat(String apiKey) async {
    // print("beginning chat");
    _webSocketModel ??= WebSocketModel(
      onMessageCallback: (dynamic raw) {
        _messageHandler(raw);
        _updateViewCallback(raw);
      },
      onErrCallback: (dynamic err) => {
        _onMessageComplete(),
      },
      onSuccessConnectCallback: () => addChatMessage(
        message: 'Connected to server.',
        isGptSpeaking: true,
        isFinished: true,
      ),
      onFailConnectCallback: () => addChatMessage(
        message: "Couldn't connect to server.",
        isGptSpeaking: true,
        isFinished: true,
      ),
    );
    await _webSocketModel!.connect("${Config.webSocketUrl}/$apiKey");
  }

  Future<void> endChat() async {
    if (_webSocketModel != null) {
      // print("ending chat");
      await _webSocketModel!.close();
      addChatMessage(
        message: 'Disconnected from server.',
        isGptSpeaking: true,
        isFinished: true,
      );
    }
  }

  void toggleTranslate() {
    isTranslateToggled = !isTranslateToggled;
  }

  void changeChatRoom({
    required String chatRoomId,
  }) {
    if (!ready || _isQuerying || _chatRoomId == chatRoomId) {
      return;
    }
    clearAllChat(clearViewOnly: true);
    _chatRoomId = chatRoomId;
    _webSocketModel!.sendJson({
      "msg": "/echo You are now in chat room `$chatRoomId`",
      "translate": isTranslateToggled,
      "chat_room_id": chatRoomId
    });
    _startQuerying();
  }

  void deleteChatRoom({
    required String chatRoomId,
  }) {
    if (!ready) {
      return;
    }
    clearAllChat(clearViewOnly: true);
    _webSocketModel!.sendJson({
      "msg": "/deletechatroom",
      "translate": isTranslateToggled,
      "chat_room_id": chatRoomId
    });
    _startQuerying();
  }

  bool sendUserMessage({
    required String message,
  }) {
    if (!ready) {
      return false;
    }
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
    _webSocketModel!.sendJson({
      "msg": message,
      "translate": isTranslateToggled,
      "chat_room_id": _chatRoomId
    });
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
      "translate": isTranslateToggled,
      "chat_room_id": _chatRoomId,
    });
    _startQuerying();
  }

  void clearAllChat({required bool clearViewOnly}) {
    if (!ready) {
      return;
    }

    _messages.clear();
    if (clearViewOnly) {
      return;
    }
    addChatMessage(
      message: "",
      isGptSpeaking: true,
      isFinished: false,
      isLoading: true,
    );
    _webSocketModel!.sendJson({
      "msg": "/clear",
      "translate": isTranslateToggled,
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

  DateTime parseFromTimestamp(int timestamp) {
    final String timecode = timestamp.toString();
    return DateTime.parse(
        "${timecode.substring(0, 8)}T${timecode.substring(8)}");
  }

  void _messageHandler(dynamic rawText) {
    final Map<String, dynamic> rcvd = jsonDecode(rawText);
    // print("rcvd: $rcvd");
    _chatRoomId = rcvd["chat_room_id"];
    final bool isGptSpeaking = rcvd["is_user"] ? false : true;
    final String message = rcvd["msg"] ?? "";
    final bool isFinished = rcvd["finish"] ?? false;
    final bool init = rcvd["init"] ?? false;
    if (init) {
      // message is list of messages in format of JSON, so we need to parse it
      final Map<String, dynamic> initMsg = jsonDecode(message);
      final List<String> allChatRoomIds =
          List<String>.from(initMsg["chat_room_ids"]);
      _chatRoomIds.assignAll(allChatRoomIds);
      final List<Map<String, dynamic>> previousChats =
          List<Map<String, dynamic>>.from(initMsg["previous_chats"]);
      for (final Map<String, dynamic> msg in previousChats) {
        addChatMessage(
          message: msg["content"] ?? "",
          isGptSpeaking: msg["is_user"] ?? false ? false : true,
          isFinished: true,
          datetime: parseFromTimestamp(msg["timestamp"]),
        );
      }
      _isInitialized = true;
      _onMessageComplete();
      return;
    }
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
    _isQuerying = false;
    lastChatMessageWhere((mm) => mm.isFinished == false)?.isFinished = true;
  }

  void _startQuerying() {
    _isQuerying = true;
  }
}
