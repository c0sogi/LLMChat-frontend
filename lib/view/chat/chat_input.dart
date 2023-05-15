import 'package:flutter/material.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
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
                RepaintBoundary(
                  child: TextFormField(
                    autofocus: true,
                    focusNode: Get.find<ChatViewModel>().messageFocusNode,
                    maxLines: 20,
                    minLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    controller: Get.find<ChatViewModel>().messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Upload file button
          FilledButton(
            style: ElevatedButton.styleFrom(
              surfaceTintColor: ThemeViewModel.idleColor,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Get.find<ChatViewModel>().uploadFile(),
            child: Row(children: const [
              Icon(Icons.document_scanner),
              SizedBox(width: 8),
              Text('Embed document'),
            ]),
          ),
          // Upload audio button
          // IconButton(
          //   onPressed: () => Get.find<ChatViewModel>().uploadAudio(),
          //   icon: const Icon(Icons.mic),
          // ),
          // // Upload image button
          // IconButton(
          //   onPressed: () => Get.find<ChatViewModel>().uploadImage(),
          //   icon: const Icon(Icons.image),
          // ),
          // Expanded box
          Expanded(
            child: Container(),
          ),
          const Text('영어로 번역'),
          Obx(
            () => Get.find<ChatViewModel>().isChatModelInitialized.value
                ? Switch(
                    activeColor: ThemeViewModel.idleColor,
                    value: Get.find<ChatViewModel>().isTranslateToggled,
                    onChanged: (value) =>
                        Get.find<ChatViewModel>().toggleTranslate(),
                  )
                : Container(),
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
          onPressed: () =>
              Get.find<ChatViewModel>().clearChat(clearViewOnly: false),
          icon: const Icon(Icons.clear_all),
        ),
        IconButton(
          onPressed: () => Get.find<ChatViewModel>().resendMessage(),
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          onPressed: () => Get.find<ChatViewModel>().sendMessage(),
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}
