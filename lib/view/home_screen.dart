import 'package:flutter/material.dart';
import './widgets/conversation_list.dart';
import 'chat/chat_view.dart';

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
        children: const [
          Expanded(
            flex: 3,
            child: ChatScreen(),
          ),
        ],
      ),
    );
  }
}
