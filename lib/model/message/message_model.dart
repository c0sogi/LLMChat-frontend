import 'package:get/get.dart';

class MessageModel {
  RxString message;
  bool isFinished;
  bool isGptSpeaking;
  RxBool isLoading;
  // final DateTime datetime;

  MessageModel({
    required String message,
    required this.isFinished,
    required this.isGptSpeaking,
    // required this.datetime,
    bool isLoading = false,
  })  : message = message.obs,
        isLoading = isLoading.obs;
}
