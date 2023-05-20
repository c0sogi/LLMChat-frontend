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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          // Upload file button
          UploadFileBox(),
          // if (Localizations.localeOf(context) == const Locale('ko', 'KR'))
          TranslateBox(),
          Expanded(child: SizedBox()),
          TokenShowBox(),
        ],
      ),
    );
  }
}

class TranslateBox extends StatelessWidget {
  const TranslateBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Transform.translate(
        offset: const Offset(0, -12),
        child: Obx(
          () => Get.find<ChatViewModel>().isChatModelInitialized.value
              ? Switch(
                  activeColor: ThemeViewModel.idleColor,
                  value: Get.find<ChatViewModel>().isTranslateToggled!.value,
                  onChanged: Get.find<ChatViewModel>().toggleTranslate!,
                )
              : Container(),
        ),
      ),
      Transform.translate(
          offset: const Offset(0, 24),
          child: const Text('영어로 번역', style: TextStyle(fontSize: 12))),
    ]);
  }
}

class UploadFileBox extends StatelessWidget {
  const UploadFileBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Upload PDF, TXT, or other text-included file to embed",
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
          Text('Embed\nDocument',
              textAlign: TextAlign.left, style: TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }
}

class TokenShowBox extends StatefulWidget {
  const TokenShowBox({Key? key}) : super(key: key);

  @override
  State<TokenShowBox> createState() => _TokenShowBoxState();
}

class _TokenShowBoxState extends State<TokenShowBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = ColorTween(
      begin: Colors.white,
      end: ThemeViewModel.idleColor,
    ).animate(_controller);

    // Listen to the tokens value change
    Get.find<ChatViewModel>().tokens.listen((_) {
      _controller
        ..reset()
        ..forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _animation.value,
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        );
      },
      child: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You've spent",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Get.find<ChatViewModel>().tokens.value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                ),
                const Text(
                  " Tokens",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
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
            onPressed: () => chatViewModel.clearChat!(clearViewOnly: false),
            icon: const Icon(Icons.clear_all),
          ),
        ),
        Tooltip(
          message: "Resend message",
          showDuration: const Duration(milliseconds: 0),
          waitDuration: const Duration(milliseconds: 500),
          child: IconButton(
            onPressed: () => chatViewModel.resendUserMessage!(),
            icon: const Icon(Icons.refresh),
          ),
        ),
        Obx(
          () => chatViewModel.isQuerying?.value ?? false
              ? Tooltip(
                  message: "Stop query",
                  showDuration: const Duration(milliseconds: 0),
                  child: IconButton(
                    onPressed: () => chatViewModel.sendText!("stop"),
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
