import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web/viewmodel/chat/scroll_viewmodel.dart';
import 'package:get/get.dart';
import '../../model/message/message_model.dart';

class ChatMessage extends StatelessWidget {
  final MessageModel message;
  const ChatMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final messageParts = message.message.split('```');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<ScrollViewModel>().scrollToBottom(animated: false);
    });
    return Container(
      alignment:
          message.isGptSpeaking ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: message.isGptSpeaking
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  message.isGptSpeaking ? Colors.grey[300] : Colors.green[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: message.isGptSpeaking
                    ? const Radius.circular(0)
                    : const Radius.circular(12),
                bottomRight: message.isGptSpeaking
                    ? const Radius.circular(12)
                    : const Radius.circular(0),
              ),
            ),
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: messageParts.asMap().entries.map<Widget>(
                (entry) {
                  int index = entry.key;
                  String part = entry.value;
                  if (index % 2 == 0) {
                    return Text(
                      part,
                      style: TextStyle(
                        color:
                            message.isGptSpeaking ? Colors.black : Colors.white,
                      ),
                    );
                  } else {
                    final languageMatch =
                        RegExp(r'^(\w+)\n').firstMatch(messageParts[index]);
                    final code = languageMatch != null
                        ? messageParts[index].substring(languageMatch.end)
                        : messageParts[index];
                    return CodeBlock(
                      code: code.trim(),
                      language:
                          languageMatch != null ? languageMatch.group(1) : '',
                    );
                  }
                },
              ).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class CodeBlock extends StatelessWidget {
  final String code;
  final String? language;

  const CodeBlock({super.key, required this.code, this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language ?? "코드",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.content_copy,
                      color: Colors.white,
                      size: 18,
                    ),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied to clipboard'),
                          ),
                        );
                      },
                      child: const Text(
                        '복사',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              code,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
