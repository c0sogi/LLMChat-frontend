import 'package:get/get.dart';

class MessageModel {
  RxString message;
  bool isFinished;
  bool isGptSpeaking;
  RxBool isLoading;

  MessageModel({
    required String message,
    required this.isFinished,
    required this.isGptSpeaking,
    bool isLoading = false,
  })  : message = message.obs,
        isLoading = isLoading.obs;
}
