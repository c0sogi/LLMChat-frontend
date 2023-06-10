import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_web/model/chat/websocket_model.dart';
import 'package:get/get.dart';
import '../../app/app_config.dart';
import '../../model/message/message_model.dart';
import '../../viewmodel/chat/chat_viewmodel.dart';

class ChatModel {
  WebSocketModel? webSocketModel;
  bool _isInitialized = false;
  String? _chatRoomId;
  final RxInt tokens;

  final RxBool isQuerying;
  final RxBool isTranslateToggled;
  final RxBool isQueryToggled;

  final RxString selectedModel;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxList<ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;
  final RxList<String> models = <String>[].obs;

  ChatModel(
      {required this.tokens,
      required this.selectedModel,
      required this.isQuerying,
      required this.isTranslateToggled,
      required this.isQueryToggled});

  bool get _ready =>
      !isQuerying.value &&
      (webSocketModel?.isConnected ?? false) &&
      _isInitialized;

  void _messageHandler(dynamic rawText) {
    final Map<String, dynamic> rcvd = jsonDecode(rawText);
    if (rcvd["chat_room_id"] != null && rcvd["chat_room_id"] != _chatRoomId) {
      _chatRoomId = rcvd["chat_room_id"];
      messages.clear();
      final String chatRoomName = chatRooms
          .firstWhere((element) => element.chatRoomId == _chatRoomId,
              orElse: () => ChatRoomModel(chatRoomId: _chatRoomId ?? ""))
          .chatRoomName
          .value;
      addChatMessage(
        message: chatRoomName.isEmpty
            ? "You are now in new chat"
            : "You are now in chat **$chatRoomName**",
        isFinished: true,
        isGptSpeaking: true,
      );
    }
    // final bool isGptSpeaking = rcvd["is_user"] ? false : true;
    final String? message = rcvd["msg"];
    final bool isFinished = rcvd["finish"] ?? false;
    final bool init = rcvd["init"] ?? false;
    final String? modelName = rcvd["model_name"];
    final String? uuid = rcvd["uuid"];

    if (init && message != null) {
      // message is list of messages in format of JSON, so we need to parse it
      final Map<String, dynamic> initMsg = jsonDecode(message);
      if (initMsg["chat_rooms"] != null) {
        List<Map<String, dynamic>>.from(initMsg["chat_rooms"]);
        chatRooms.assignAll(
          List<Map<String, dynamic>>.from(initMsg["chat_rooms"]).map(
            (e) => ChatRoomModel(
              chatRoomId: e["chat_room_id"]!,
              chatRoomName: e["chat_room_name"],
            ),
          ),
        );
      }
      if (initMsg["previous_chats"] != null) {
        clearChat(clearViewOnly: true);
        for (final Map<String, dynamic> msg
            in List<Map<String, dynamic>>.from(initMsg["previous_chats"])) {
          addChatMessage(
            message: msg["content"] ?? "",
            isGptSpeaking: msg["is_user"] ?? false ? false : true,
            isFinished: true,
            datetime: parseLocaltimeFromTimestamp(msg["timestamp"]),
            modelName: msg["model_name"],
            uuid: msg["uuid"],
          );
        }
      }
      if (initMsg["selected_model"] != null) {
        selectedModel(initMsg["selected_model"]);
      }
      if (initMsg["models"] != null) {
        models.assignAll(List<String>.from(initMsg["models"]));
      }
      if (initMsg["tokens"] != null) {
        tokens(initMsg["tokens"]);
      }
      if (initMsg["wait_next_query"] ?? false) {
        return;
      }
      _isInitialized = true;
      _stopQuerying(finishedMessage: false);
      return;
    }
    message != null
        ? _onMessageAppend(
            appendMessage: message,
            modelName: modelName,
            uuid: uuid,
          )
        : _onHandShake(modelName: modelName, uuid: uuid);
    if (isFinished) {
      _stopQuerying(finishedMessage: true);
    }
  }

  Future<void> beginChat(String apiKey) async {
    // print("beginning chat");
    webSocketModel ??= WebSocketModel(
      onMessageCallback: (dynamic raw) {
        _messageHandler(raw);
      },
      onErrCallback: (dynamic err) => {_stopQuerying(finishedMessage: true)},
      onSuccessConnectCallback: () => {
        addChatMessage(
          message: 'Connected to server.',
          isGptSpeaking: true,
          isFinished: true,
        )
      },
      onFailConnectCallback: () => {
        addChatMessage(
          message: "Couldn't connect to server.",
          isGptSpeaking: true,
          isFinished: true,
        ),
      },
    );
    await webSocketModel!.connect("${Config.webSocketUrl}/$apiKey");
  }

  Future<void> endChat() async {
    if (webSocketModel != null) {
      // print("ending chat");
      await webSocketModel!.close();
      addChatMessage(
        message: 'Disconnected from server.',
        isGptSpeaking: true,
        isFinished: true,
      );
    }
  }

  void changeChatRoom({required String chatRoomId}) {
    if (!_ready || _chatRoomId == chatRoomId) {
      return;
    }
    _startQuerying();
    webSocketModel!.sendJson({
      "msg": "",
      "translate": isTranslateToggled.value,
      "chat_room_id": chatRoomId
    });
  }

  void deleteChatRoom({required String chatRoomId}) {
    if (!_ready) {
      return;
    }
    _startQuerying();
    webSocketModel!.sendJson({
      "msg": "/deletechatroom $chatRoomId",
      "translate": isTranslateToggled.value,
      "chat_room_id": _chatRoomId
    });
  }

  void sendText(String text) {
    webSocketModel?.sendText(text);
  }

  void sendJson(Map<String, dynamic> json) {
    webSocketModel?.sendJson(json);
  }

  bool sendUserMessage({required String message}) {
    if (!_ready) {
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
    _startQuerying();
    webSocketModel!.sendJson({
      "msg": isQueryToggled.value ? "/query $message" : message,
      "translate": isTranslateToggled.value,
      "chat_room_id": _chatRoomId
    });
    return true;
  }

  void resendUserMessage() {
    // Implement resend message logic
    if (!_ready) {
      return;
    }

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
    _startQuerying();
    webSocketModel!.sendJson({
      "msg": "/retry",
      "translate": isTranslateToggled.value,
      "chat_room_id": _chatRoomId,
    });
  }

  void clearChat({required bool clearViewOnly}) {
    if (!_ready) {
      return;
    }

    messages.clear();
    if (clearViewOnly) {
      return;
    }
    addChatMessage(
      message: "",
      isGptSpeaking: true,
      isFinished: false,
      isLoading: true,
    );
    _startQuerying();
    webSocketModel!.sendJson({
      "msg": "/clear",
      "translate": isTranslateToggled.value,
      "chat_room_id": _chatRoomId,
    });
  }

  void addChatMessage({
    required String message,
    required bool isFinished,
    required bool isGptSpeaking,
    bool? isLoading,
    DateTime? datetime,
    String? modelName,
    String? uuid,
  }) {
    messages.add(MessageModel(
      message: message,
      isFinished: isFinished,
      isGptSpeaking: isGptSpeaking,
      isLoading: isLoading,
      datetime: datetime,
      modelName: modelName,
      uuid: uuid,
    ));
  }

  MessageModel? lastChatMessageWhere(bool Function(MessageModel) test) {
    // get last element where test is true
    try {
      return messages.lastWhere(test);
    } on StateError {
      return null;
    }
  }

  void _onMessageAppend(
      {required String appendMessage, String? modelName, String? uuid}) {
    if (messages.isNotEmpty && messages.last.isFinished == false) {
      messages.last.message(messages.last.message.value + appendMessage);
      messages.last.isLoading(false);
      if (modelName != null) {
        messages.last.modelName(modelName);
      }
      if (uuid != null) {
        messages.last.uuid = uuid;
      }
      return;
    }
    addChatMessage(
      message: appendMessage,
      isGptSpeaking: true,
      isFinished: false,
      modelName: modelName,
      uuid: uuid,
    );
  }

  void _onHandShake({String? modelName, String? uuid}) {
    final int index =
        messages.lastIndexWhere((mm) => mm.isLoading.value == true);
    if (index != -1) {
      messages[index].modelName(modelName);
      messages[index].uuid = uuid;
      return;
    }
  }

  void _stopQuerying({required bool finishedMessage}) {
    isQuerying(false);
    if (finishedMessage) {
      lastChatMessageWhere((mm) => mm.isFinished == false)?.isFinished = true;
    }
  }

  void _startQuerying() {
    isQuerying(true);
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
    webSocketModel?.sendJson({"filename": filename});
    webSocketModel?.sendBytes(file);
  }

  static DateTime parseLocaltimeFromTimestamp(int timestamp) {
    final String timecode = timestamp.toString();
    return DateTime.parse(
      "${timecode.substring(0, 8)}T${timecode.endsWith('Z') ? timecode.substring(8) : '${timecode.substring(8)}Z'}",
    ).toLocal();
  }
}
