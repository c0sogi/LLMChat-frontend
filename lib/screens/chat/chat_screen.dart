import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_message.dart';
import 'chat_controller.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(
            () => ListView.builder(
              controller: Get.find<ChatController>().scrollController,
              itemCount: Get.find<ChatController>().messages.length,
              itemBuilder: (context, index) {
                return ChatMessage(
                  chatController: Get.find<ChatController>(),
                  message: Get.find<ChatController>().messages[index].message,
                  isFinished:
                      Get.find<ChatController>().messages[index].isFinished,
                  isGptSpeaking:
                      Get.find<ChatController>().messages[index].isGptSpeaking,
                );
              },
            ),
          ),
        ),
        const ChatInput(),
      ],
    );
  }
}
