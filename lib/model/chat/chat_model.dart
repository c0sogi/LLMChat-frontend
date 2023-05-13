import 'dart:convert';
import 'dart:typed_data';
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
  String? get chatRoomId => _chatRoomId;
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
    _startQuerying();
    _webSocketModel!.sendJson({
      "msg": "",
      "translate": isTranslateToggled,
      "chat_room_id": chatRoomId
    });
  }

  void deleteChatRoom({
    required String chatRoomId,
  }) {
    if (!ready) {
      return;
    }
    _startQuerying();
    _webSocketModel!.sendJson({
      "msg": "/deletechatroom $chatRoomId",
      "translate": isTranslateToggled,
      "chat_room_id": _chatRoomId
    });
  }

  bool sendUserMessage({
    required String message,
  }) {
    if (!ready) {
      return false;
    }
    _startQuerying();
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
    return true;
  }

  void resendUserMessage() {
    // Implement resend message logic
    if (!ready) {
      return;
    }
    _startQuerying();

    final String? lastUserMessage =
        lastChatMessageWhere((mm) => mm.isGptSpeaking == false)?.message.value;
    if (lastUserMessage == null) {
      return;
    }
    addChatMessage(
      message: "",
      isGptSpeaking: true,
      isFinished: false,
      isLoading: true,
    );
    _webSocketModel!.sendJson({
      "msg": "/retry",
      "translate": isTranslateToggled,
      "chat_room_id": _chatRoomId,
    });
  }

  void clearChat({required bool clearViewOnly}) {
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
    String? modelName,
  }) {
    _messages.add(MessageModel(
      message: message,
      isFinished: isFinished,
      isGptSpeaking: isGptSpeaking,
      isLoading: isLoading,
      datetime: datetime,
      modelName: modelName,
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
    // print(rcvd);
    if (rcvd["chat_room_id"] != null && rcvd["chat_room_id"] != _chatRoomId) {
      _chatRoomId = rcvd["chat_room_id"];
      messages.clear();
      addChatMessage(
        message: "You are now in chat room $_chatRoomId",
        isFinished: true,
        isGptSpeaking: true,
      );
    }
    final bool isGptSpeaking = rcvd["is_user"] ? false : true;
    final String? message = rcvd["msg"];
    final bool isFinished = rcvd["finish"] ?? false;
    final bool init = rcvd["init"] ?? false;
    final String? modelName = rcvd["model_name"];
    if (init && message != null) {
      // message is list of messages in format of JSON, so we need to parse it
      final Map<String, dynamic> initMsg = jsonDecode(message);
      if (initMsg["chat_room_ids"] != null) {
        final List<String> allChatRoomIds =
            List<String>.from(initMsg["chat_room_ids"]);
        _chatRoomIds.assignAll(allChatRoomIds);
      }
      if (initMsg["previous_chats"] != null) {
        final List<Map<String, dynamic>> previousChats =
            List<Map<String, dynamic>>.from(initMsg["previous_chats"]);
        for (final Map<String, dynamic> msg in previousChats) {
          addChatMessage(
            message: msg["content"] ?? "",
            isGptSpeaking: msg["is_user"] ?? false ? false : true,
            isFinished: true,
            datetime: parseFromTimestamp(msg["timestamp"]),
            modelName: msg["model_name"],
          );
        }
      }
      _isInitialized = true;
      _onMessageComplete();
      return;
    }
    message != null
        ? isTalking
            ? _onMessageAppend(appendMessage: message, modelName: modelName)
            : _onMessageCreate(
                message: message,
                isFinished: isFinished,
                isGptSpeaking: isGptSpeaking,
                modelName: modelName,
              )
        : _onNullMessage(modelName: modelName);
    if (isFinished) {
      _onMessageComplete();
    }
  }

  void _onMessageAppend({required String appendMessage, String? modelName}) {
    final int index = _messages.lastIndexWhere((mm) => mm.isFinished == false);
    if (index != -1) {
      _messages[index].message(_messages[index].message.value + appendMessage);
      return;
    }
    addChatMessage(
      message: appendMessage,
      isGptSpeaking: true,
      isFinished: false,
      modelName: modelName,
    );
  }

  void _onMessageCreate({
    required String message,
    required bool isFinished,
    required bool isGptSpeaking,
    String? modelName,
  }) {
    final int index =
        _messages.lastIndexWhere((mm) => mm.isLoading.value == true);
    // print("_onMessageCreate: $index");
    if (index == -1) {
      addChatMessage(
        message: message,
        isFinished: isFinished,
        isGptSpeaking: isGptSpeaking,
        modelName: modelName,
      );
      isTalking = true;
      return;
    }
    _messages[index]
      ..isGptSpeaking = isGptSpeaking
      ..isFinished = isFinished
      ..message(message)
      ..isLoading(false)
      ..modelName(modelName);
    isTalking = true;
  }

  void _onNullMessage({
    String? modelName,
  }) {
    if (modelName != null) {
      final int index =
          _messages.lastIndexWhere((mm) => mm.isLoading.value == true);
      if (index != -1) {
        _messages[index].modelName(modelName);
        return;
      }
    }
    if (!isTalking) {
      addChatMessage(
        message: "",
        isFinished: false,
        isGptSpeaking: true,
        isLoading: true,
        modelName: modelName,
      );
    }
  }

  void _onMessageComplete() {
    isTalking = false;
    _isQuerying = false;
    lastChatMessageWhere((mm) => mm.isFinished == false)?.isFinished = true;
  }

  void _startQuerying() {
    _isQuerying = true;
  }

  Future<void> uploadFile({required String filename, Uint8List? file}) async {
    _startQuerying();
    addChatMessage(
      message: "📄 **$filename**",
      isGptSpeaking: false,
      isFinished: true,
    );
    addChatMessage(
      message: "",
      isGptSpeaking: true,
      isFinished: false,
      isLoading: true,
    );
    _webSocketModel?.sendJson({"filename": filename});
    _webSocketModel?.sendBytes(file);
  }
}
