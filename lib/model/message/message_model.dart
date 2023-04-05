class MessageModel {
  String message;
  bool isFinished;
  bool isGptSpeaking;

  MessageModel({
    required this.message,
    required this.isFinished,
    required this.isGptSpeaking,
  });
}
