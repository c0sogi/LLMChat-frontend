import 'package:flutter/material.dart';

class ConversationList extends StatelessWidget {
  const ConversationList({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace this with the actual list of conversations received via WebSocket
    List<String> conversations = ['user1', 'user2', 'user3'];
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(conversations[index]),
          onTap: () {
            // Handle conversation selection here
          },
        );
      },
    );
  }
}
