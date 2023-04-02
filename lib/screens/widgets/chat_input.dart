import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat/chat_controller.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                TextField(
                  focusNode: Get.find<ChatController>().messageFocusNode,
                  controller: Get.find<ChatController>().messageController,
                  decoration: InputDecoration(
                    hintText: '여기에 메시지를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (text) {
                    // assure that the focus on the textfield is not removed
                    FocusScope.of(context).requestFocus(
                      Get.find<ChatController>().messageFocusNode,
                    );
                    Get.find<ChatController>().sendMessage();
                  },
                ),
                const UploadButtons(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const MessageButtons(),
        ],
      ),
    );
  }
}

class UploadButtons extends StatelessWidget {
  const UploadButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Upload audio button
          IconButton(
            onPressed: () => Get.find<ChatController>().uploadAudio(),
            icon: const Icon(Icons.mic),
            tooltip: '음원 업로드',
          ),
          // Upload image button
          IconButton(
            onPressed: () => Get.find<ChatController>().uploadImage(),
            icon: const Icon(Icons.image),
            tooltip: '사진 업로드',
          ),
          // Expanded box
          Expanded(
            child: Container(),
          ),
          const Text('영어로 번역'),
          Switch(
            value: Get.find<ChatController>().isTranslateToggled.value,
            onChanged: (value) {
              Get.find<ChatController>().toggleTranslate();
            },
          ),
        ],
      ),
    );
  }
}

class MessageButtons extends StatelessWidget {
  const MessageButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => Get.find<ChatController>().clearChat(),
          icon: const Icon(Icons.clear_all),
          tooltip: '채팅 초기화',
        ),
        IconButton(
          onPressed: () => Get.find<ChatController>().resendMessage(),
          icon: const Icon(Icons.refresh),
          tooltip: '재전송',
        ),
        IconButton(
          onPressed: () => Get.find<ChatController>().sendMessage(),
          icon: const Icon(Icons.send),
          tooltip: '전송',
        ),
      ],
    );
  }
}
