import 'package:get/get.dart';

class MessageModel {
  RxString message;
  bool isFinished;
  bool isGptSpeaking;
  final RxBool isLoading;
  final DateTime dateTime;
  final RxString modelName;

  MessageModel({
    required String message,
    required this.isFinished,
    required this.isGptSpeaking,
    DateTime? datetime,
    bool? isLoading,
    String? modelName,
  })  : message = message.obs,
        isLoading = (isLoading ?? false).obs,
        dateTime = datetime ?? DateTime.now(),
        modelName = (modelName ?? "").obs;
}
