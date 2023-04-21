import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodel/chat/chat_viewmodel.dart';

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
                  autofocus: true,
                  focusNode: Get.find<ChatViewModel>().messageFocusNode,
                  maxLines: 3,
                  minLines: 3,
                  textAlignVertical: TextAlignVertical.center,
                  controller: Get.find<ChatViewModel>().messageController,
                  decoration: InputDecoration(
                    hintText: '여기에 메시지를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const BottomToolbar(),
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

class BottomToolbar extends StatelessWidget {
  const BottomToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Upload audio button
        IconButton(
          onPressed: () => Get.find<ChatViewModel>().uploadAudio(),
          icon: const Icon(Icons.mic),
          tooltip: '음원 업로드',
        ),
        // Upload image button
        IconButton(
          onPressed: () => Get.find<ChatViewModel>().uploadImage(),
          icon: const Icon(Icons.image),
          tooltip: '사진 업로드',
        ),
        // Expanded box
        Expanded(
          child: Container(),
        ),
        const Text('영어로 번역'),
        Obx(
          () => Get.find<ChatViewModel>().isChatModelInitialized.value
              ? Switch(
                  value: Get.find<ChatViewModel>().isTranslateToggled,
                  onChanged: (value) =>
                      Get.find<ChatViewModel>().toggleTranslate(),
                )
              : Container(),
        ),
      ],
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
          onPressed: () => Get.find<ChatViewModel>().clearChat(),
          icon: const Icon(Icons.clear_all),
          tooltip: '채팅 초기화',
        ),
        IconButton(
          onPressed: () => Get.find<ChatViewModel>().resendMessage(),
          icon: const Icon(Icons.refresh),
          tooltip: '재전송',
        ),
        IconButton(
          onPressed: () => Get.find<ChatViewModel>().sendMessage(),
          icon: const Icon(Icons.send),
          tooltip: '전송',
        ),
      ],
    );
  }
}
