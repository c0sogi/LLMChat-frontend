import 'package:get/get.dart';

class MessageModel {
  RxString message;
  bool isFinished;
  bool isGptSpeaking;
  RxBool isLoading;
  final DateTime dateTime;

  MessageModel({
    required String message,
    required this.isFinished,
    required this.isGptSpeaking,
    DateTime? datetime,
    bool isLoading = false,
  })  : message = message.obs,
        isLoading = isLoading.obs,
        dateTime = datetime ?? DateTime.now();
}
