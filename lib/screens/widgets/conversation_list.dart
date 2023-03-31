import 'package:flutter/material.dart';
import 'package:flutter_web/screens/login/login_screen.dart';

class ConversationList extends StatelessWidget {
  const ConversationList({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace this with the actual list of conversations received via WebSocket
    List<String> conversations = [
      'Sample Text1',
      'Sample Text2',
      'Sample Text3',
      'Sample Text4',
      'Sample Text5',
      'Sample Text6',
      'Sample Text7',
      'Sample Text8',
      'Sample Text9',
      'Sample Text10',
    ];
    return Column(
      children: [
        const Flexible(flex: 1, child: LoginDrawer()),
        Flexible(
          flex: 1,
          child: ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(conversations[index]),
                onTap: () {
                  // Handle conversation selection here
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
