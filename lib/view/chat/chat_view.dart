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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff1f005a),
            Color(0xff5b0060),
            Color(0xff870160),
            Color(0xffac255e),
            Color(0xffca485c),
            Color(0xffe16b5c),
            Color(0xfff39060),
            Color(0xffffb56b),
          ],
        ),
      ),
      child: Column(
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
      ),
    );
  }
}
