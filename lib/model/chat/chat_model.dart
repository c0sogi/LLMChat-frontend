import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_web/model/chat/websocket_model.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../app/app_config.dart';
import '../../main.dart';
import '../../model/message/message_model.dart';
import '../../viewmodel/chat/chat_viewmodel.dart';

enum ChatAction {
  changeChatModel,
  changeChatRoom,
  changeChatRoomName,
  deleteChatRoom,
  deleteMessage,
  interruptChat;
}

class ChatModel {
  WebSocketModel? webSocketModel;
  bool _isInitialized = false;
  String? _chatRoomId;
  final RxInt tokens;

  final RxBool isQuerying;
  final RxBool isTranslateToggled;
  final RxBool isQueryToggled;
  final RxBool isBrowseToggled;

  final RxString selectedModel;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxList<ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;
  final RxList<String> models = <String>[].obs;

  ChatModel({
    required this.tokens,
    required this.selectedModel,
    required this.isQuerying,
    required this.isTranslateToggled,
    required this.isQueryToggled,
    required this.isBrowseToggled,
  });

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
    // final String? actualRole = rcvd["actual_role"];
    final String? message = rcvd["msg"];
    final bool isFinished = rcvd["finish"] ?? false;
    final bool init = rcvd["init"] ?? false;
    final String? modelName = rcvd["model_name"];
    final String? uuid = rcvd["uuid"];
    final bool? waitNextQuery = rcvd["wait_next_query"];

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
            isGptSpeaking: msg["actual_role"] != "user" ? true : false,
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
      _isInitialized = true;
      _stopQuerying(finishedMessage: false, waitNextQuery: waitNextQuery);
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
      _stopQuerying(finishedMessage: true, waitNextQuery: waitNextQuery);
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
    if (webSocketModel == null) return;
    await webSocketModel!.close();
    addChatMessage(
      message: 'Disconnected from server.',
      isGptSpeaking: true,
      isFinished: true,
    );
  }

  void performChatAction({
    required ChatAction action,
    String? chatRoomId,
    String? chatRoomName,
    String? chatModelName,
    String? messageRole,
    String? messageUuid,
  }) {
    if (action != ChatAction.interruptChat) {
      if (!_ready) return;
      _startQuerying();
    }

    switch (action) {
      case ChatAction.changeChatRoom:
        if (_chatRoomId == chatRoomId) return;
        webSocketModel!.sendJson({
          "msg": "",
          "chat_room_id": chatRoomId,
        });
        break;

      case ChatAction.deleteChatRoom:
        webSocketModel!.sendJson({
          "msg": "/deletechatroom $chatRoomId",
          "chat_room_id": _chatRoomId,
        });
        break;

      case ChatAction.deleteMessage:
        webSocketModel!.sendJson({
          "msg": "/deletemessage $messageRole $messageUuid",
          "chat_room_id": _chatRoomId,
        });
        break;
      case ChatAction.changeChatModel:
        webSocketModel!.sendJson({"model": chatModelName});
        break;
      case ChatAction.changeChatRoomName:
        webSocketModel!.sendJson({
          "chat_room_name": chatRoomName,
          "chat_room_id": chatRoomId,
        });
        break;
      case ChatAction.interruptChat:
        webSocketModel!.sendText("stop");
    }
  }

  bool sendUserMessage({required String message}) {
    if (!_ready) return false;
    final String uuid = const Uuid().v4().replaceAll("-", "");
    addChatMessage(
      message: message,
      isGptSpeaking: false,
      isFinished: true,
      uuid: uuid,
    );
    addChatMessage(
      message: "",
      isGptSpeaking: true,
      isFinished: false,
      isLoading: true,
    );
    _startQuerying();
    webSocketModel!.sendJson({
      "msg": isQueryToggled.value
          ? "/query $message"
          : isBrowseToggled.value
              ? "/browse $message"
              : message,
      "translate": isTranslateToggled.value ? languageCode : null,
      "chat_room_id": _chatRoomId,
      "uuid": uuid,
    });
    return true;
  }

  void resendUserMessage() {
    if (!_ready) return;

    if (lastChatMessageWhere((mm) => mm.isGptSpeaking == false)
            ?.message
            .value ==
        null) return;
    addChatMessage(
      message: "",
      isGptSpeaking: true,
      isFinished: false,
      isLoading: true,
    );
    _startQuerying();
    webSocketModel!.sendJson({
      "msg": "/retry",
      "translate": isTranslateToggled.value ? languageCode : null,
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
      // append message to last message if it is not finished
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
    // if empty or last message is finished
    if (appendMessage.isEmpty) {
      // do nothing if message is empty
      return;
    }
    // add new message if message is not empty
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
    addChatMessage(
      message: "",
      isFinished: false,
      isGptSpeaking: true,
      isLoading: true,
      modelName: modelName,
      uuid: uuid,
    );
  }

  void _stopQuerying({required bool finishedMessage, bool? waitNextQuery}) {
    if (finishedMessage) {
      lastChatMessageWhere((mm) => mm.isFinished == false)?.isFinished = true;
    }
    if (waitNextQuery == true) {
      return;
    } else {
      isQuerying(false);
    }
  }

  void _startQuerying() {
    isQuerying(true);
  }

  Future<void> uploadFile({required String filename, Uint8List? file}) async {
    _startQuerying();
    addChatMessage(
      message: "\n```lottie-file-upload\n### File Uploaded!\n$filename\n```",
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
