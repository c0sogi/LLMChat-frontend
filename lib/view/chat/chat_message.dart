import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
import 'package:get/get.dart';

class ChatMessagePlaceholder extends StatelessWidget {
  final String message;
  final bool isGptSpeaking;
  const ChatMessagePlaceholder({
    super.key,
    required this.message,
    required this.isGptSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isGptSpeaking ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment:
            isGptSpeaking ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isGptSpeaking ? Colors.orange[600] : Colors.blue[600],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isGptSpeaking
                    ? const Radius.circular(0)
                    : const Radius.circular(12),
                bottomRight: isGptSpeaking
                    ? const Radius.circular(12)
                    : const Radius.circular(0),
              ),
            ),
            child: Text(message, style: const TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

class ChatMessage extends StatefulWidget {
  final int index;
  const ChatMessage({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RegExp langRegExp = RegExp(r'^(\w+)\n');
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();
    final bool isGptSpeaking =
        chatViewModel.messages![widget.index].isGptSpeaking;

    return Container(
      alignment: isGptSpeaking ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isGptSpeaking ? Colors.grey[600] : Colors.blue[600],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isGptSpeaking
                      ? const Radius.circular(0)
                      : const Radius.circular(12),
                  bottomRight: isGptSpeaking
                      ? const Radius.circular(12)
                      : const Radius.circular(0),
                ),
              ),
              child: Obx(() {
                SchedulerBinding.instance
                    .addPostFrameCallback(chatViewModel.scrollToBottomCallback);
                final List<String> msgParts = chatViewModel
                    .messages![widget.index].message.value
                    .split('```');
                if (chatViewModel.messages![widget.index].isLoading.value) {
                  return Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.3,
                    ),
                    child: const Center(
                      child: LinearProgressIndicator(),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: msgParts.asMap().entries.map<Widget>(
                    (entry) {
                      if (entry.key % 2 == 0) {
                        return Text(
                          entry.value,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        );
                      } else {
                        final lang = langRegExp.firstMatch(msgParts[entry.key]);
                        return lang != null
                            ? CodeBlock(
                                code: msgParts[entry.key]
                                    .substring(lang.end)
                                    .trim(),
                                language: lang.group(1),
                              )
                            : CodeBlock(
                                code: msgParts[entry.key].trim(),
                                language: '',
                              );
                      }
                    },
                  ).toList(),
                );
              }),
            ),
          ),
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
