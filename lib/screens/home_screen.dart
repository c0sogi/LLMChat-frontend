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
      appBar: AppBar(
        title: const Text('ChatGPT App'),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[200],
          child: const ConversationList(),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: GetBuilder<ChatController>(
              init: Get.find<ChatController>(),
              builder: (controller) {
                if (true) {
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
