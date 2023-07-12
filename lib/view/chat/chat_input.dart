import 'package:flutter/material.dart';
import 'package:flutter_web/model/chat/chat_image_model.dart';
import 'package:flutter_web/model/chat/chat_model.dart';
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
                      hintText: 'Send a message',
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
    final chatViewModel = Get.find<ChatViewModel>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Upload file button
          const UploadFileBox(),
          // if (Localizations.localeOf(context) == const Locale('ko', 'KR'))
          ToggleBox(
            icon: const SizedBox(width: 20, child: Icon(Icons.translate)),
            text: "Translate",
            isToggled: chatViewModel.isTranslateToggled,
          ),
          ToggleBox(
            icon: const SizedBox(width: 20, child: Icon(Icons.search)),
            text: "Query",
            isToggled: chatViewModel.isQueryToggled,
            onChanged: (isQueryToggled) {
              if (isQueryToggled) {
                chatViewModel.isBrowseToggled(false);
              }
              chatViewModel.isQueryToggled(isQueryToggled);
            },
          ),
          ToggleBox(
            icon: ChatImageModel.searchWebSvg,
            text: "Browse",
            isToggled: chatViewModel.isBrowseToggled,
            onChanged: (isBrowseToggled) {
              if (isBrowseToggled) {
                chatViewModel.isQueryToggled(false);
              }
              chatViewModel.isBrowseToggled(isBrowseToggled);
            },
          ),
          const Expanded(child: SizedBox()),
          const TokenShowBox(),
        ],
      ),
    );
  }
}

class ToggleBox extends StatelessWidget {
  final Widget icon;
  final String text;
  final RxBool isToggled;
  final void Function(bool)? onChanged;
  const ToggleBox({
    super.key,
    required this.icon,
    required this.text,
    required this.isToggled,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Obx(
        () => Get.find<ChatViewModel>().isChatModelInitialized.value
            ? SizedBox(
                height: 20,
                child: Switch(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: ThemeViewModel.idleColor,
                  value: isToggled.value,
                  onChanged: (value) => {
                    onChanged == null ? isToggled.toggle() : onChanged!(value),
                  },
                ),
              )
            : Container(),
      ),
      Row(
        children: [icon, Text(text, style: const TextStyle(fontSize: 12))],
      ),
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
        child: const Row(children: [
          Icon(Icons.document_scanner),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: 'Embed\n',
                style: TextStyle(fontSize: 14),
              ),
              TextSpan(
                text: 'Document',
                style: TextStyle(fontSize: 10),
              ),
            ]),
            textAlign: TextAlign.left,
          ),
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
  late final AnimationController controller;
  late final Animation<Color?> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    animation = ColorTween(
      begin: ThemeViewModel.idleColor,
      end: Colors.white,
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();

    return Obx(() {
      final tokens = chatViewModel.tokens.value.toString();
      controller
        ..reset()
        ..forward();

      return Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You used",
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
                AnimatedBuilder(
                  animation: controller,
                  builder: (BuildContext context, Widget? child) {
                    return Text(
                      tokens,
                      style: TextStyle(
                        fontSize: 16,
                        color: animation.value,
                      ),
                      maxLines: 1,
                    );
                  },
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
      );
    });
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
          () => chatViewModel.isQuerying.value
              ? Tooltip(
                  message: "Stop query",
                  showDuration: const Duration(milliseconds: 0),
                  child: IconButton(
                    onPressed: () => chatViewModel.performChatAction!(
                      action: ChatAction.interruptChat,
                    ),
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
