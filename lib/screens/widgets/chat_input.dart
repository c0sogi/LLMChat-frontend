import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat/chat_controller.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: chatController.messageController,
              decoration: InputDecoration(
                hintText: '여기에 메시지를 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (text) => chatController.sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => Get.find<ChatController>().clearChat(),
                icon: const Icon(Icons.clear_all),
                tooltip: 'Clear chat',
              ),
              IconButton(
                onPressed: () => Get.find<ChatController>().resendMessage(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Resend message',
              ),
              IconButton(
                onPressed: () => Get.find<ChatController>().sendMessage(),
                icon: const Icon(Icons.send),
                tooltip: 'Send',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
