import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web/model/chat/chat_image_model.dart';
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/message/message_model.dart';
import 'chat_input.dart';
import 'chat_message.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();
    final ThemeViewModel themeViewModel = Get.find<ThemeViewModel>();
    return Obx(() {
      return AnimatedContainer(
        // black gradient background
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: themeViewModel.begin.value,
            end: themeViewModel.end.value,
            stops: themeViewModel.stops.toList(),
            colors: ThemeViewModel.defaultGradientColors,
          ),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: chatViewModel.isChatModelInitialized.value
                    ? ListView.builder(
                        controller: chatViewModel.scrollController,
                        itemCount: chatViewModel.messages!.length,
                        itemBuilder: (context, index) {
                          if (index >= chatViewModel.messages!.length) {
                            return const SizedBox();
                          }
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                chatViewModel.messages![index].isGptSpeaking
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                            children: [
                              if (chatViewModel.messages![index].isGptSpeaking)
                                AIChatProfile(
                                    message: chatViewModel.messages![index]),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    chatViewModel.messages![index].isGptSpeaking
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                children: [
                                  ChatMessage(index: index),
                                  ChatBottomBox(
                                      message: chatViewModel.messages![index]),
                                ],
                              ),
                              if (!chatViewModel.messages![index].isGptSpeaking)
                                const UserChatProfile(),
                            ],
                          );
                        },
                      )
                    : ListView.builder(
                        controller: chatViewModel.scrollController,
                        itemCount: chatViewModel.messagePlaceholder.length,
                        itemBuilder: (context, index) {
                          return ChatMessagePlaceholder(index: index);
                        },
                      ),
              ),
              if (chatViewModel.isChatModelInitialized.value) const ChatInput(),
            ],
          ),
        ),
      );
    });
  }
}

class ChatBottomBox extends StatelessWidget {
  const ChatBottomBox({
    super.key,
    required this.message,
  });

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!message.isGptSpeaking)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CopyToClipboardButton(message: message),
          ),
        Text(
          DateFormat('MMM d, yyyy, h:mm a').format(message.dateTime),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        if (message.isGptSpeaking)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CopyToClipboardButton(message: message),
          ),
      ],
    );
  }
}

class UserChatProfile extends StatelessWidget {
  const UserChatProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: CircleAvatar(
        radius: 20,
        backgroundImage: ChatImageModel.user.value,
      ),
    );
  }
}

class AIChatProfile extends StatelessWidget {
  const AIChatProfile({
    super.key,
    required this.message,
  });

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10),
      child: Obx(
        () => Stack(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: ChatImageModel.getLlmAssetImage(
                message.modelName.value,
              ),
            ),
            if (message.isLoading.value)
              const Positioned.fill(
                child: CircularProgressIndicator(
                  // backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CopyToClipboardButton extends StatelessWidget {
  final MessageModel message;
  final RxBool isCheckMarkVisible = false.obs;

  CopyToClipboardButton({super.key, required this.message});

  void copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: message.message.value));
    isCheckMarkVisible(true);
    await Future.delayed(const Duration(seconds: 1));
    isCheckMarkVisible(false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCheckMarkVisible.value ? null : copyToClipboard,
      child: Obx(() {
        return Row(
          children: [
            if (!message.isGptSpeaking)
              Text(
                isCheckMarkVisible.value ? "Copied!" : "Copy to clipboard",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isCheckMarkVisible.value
                  ? Icon(
                      Icons.check_circle,
                      key: UniqueKey(),
                      color: Colors.green,
                      size: 18,
                    )
                  : Icon(
                      Icons.content_copy,
                      key: UniqueKey(),
                      color: Colors.grey,
                      size: 18,
                    ),
            ),
            if (message.isGptSpeaking)
              Text(
                isCheckMarkVisible.value ? "Copied!" : "Copy to clipboard",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        );
      }),
    );
  }
}
