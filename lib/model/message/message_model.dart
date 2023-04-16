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
    bool? isLoading,
  })  : message = message.obs,
        isLoading = (isLoading ?? false).obs,
        dateTime = datetime ?? DateTime.now();
}
