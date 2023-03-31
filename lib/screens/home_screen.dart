import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './widgets/conversation_list.dart';
import './chat/chat_controller.dart';
import './chat/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: const ConversationList(),
            ),
          ),
          Expanded(
            flex: 3,
            child: GetBuilder<ChatController>(
              init: Get.find<ChatController>(),
              builder: (controller) {
                if (controller.isConnected) {
                  return const ChatScreen();
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
