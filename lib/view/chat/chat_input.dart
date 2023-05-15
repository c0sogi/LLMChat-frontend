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
          Tooltip(
            message: "'Upload PDF, TXT, or other text-included file to embed'",
            waitDuration: const Duration(milliseconds: 500),
            showDuration: const Duration(milliseconds: 0),
            child: FilledButton(
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
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Tooltip(
          message: "Clear chat",
          showDuration: const Duration(milliseconds: 0),
          waitDuration: const Duration(milliseconds: 500),
          child: IconButton(
            onPressed: () => chatViewModel.clearChat(clearViewOnly: false),
            icon: const Icon(Icons.clear_all),
          ),
        ),
        Tooltip(
          message: "Resend message",
          showDuration: const Duration(milliseconds: 0),
          waitDuration: const Duration(milliseconds: 500),
          child: IconButton(
            onPressed: () => chatViewModel.resendMessage(),
            icon: const Icon(Icons.refresh),
          ),
        ),
        Obx(
          () => chatViewModel.isQuerying
              ? Tooltip(
                  message: "Stop query",
                  showDuration: const Duration(milliseconds: 0),
                  child: IconButton(
                    onPressed: () => chatViewModel.sendText("stop"),
                    icon: const Icon(Icons.stop),
                  ),
                )
              : Tooltip(
                  message: "Send message",
                  showDuration: const Duration(milliseconds: 0),
                  waitDuration: const Duration(milliseconds: 500),
                  child: IconButton(
                    onPressed: chatViewModel.sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ),
        ),
      ],
    );
  }
}
