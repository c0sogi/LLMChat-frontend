import 'package:flutter/material.dart';
import 'package:flutter_web/viewmodel/chat/scroll_viewmodel.dart';
import 'package:get/get.dart';
import '../../viewmodel/chat/chat_viewmodel.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(
            () => ListView.builder(
              controller: Get.find<ScrollViewModel>().scrollController,
              itemCount: Get.find<ChatViewModel>().length,
              itemBuilder: (context, index) {
                return ChatMessage(
                  message: Get.find<ChatViewModel>().messages[index],
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
