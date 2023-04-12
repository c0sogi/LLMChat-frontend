import 'package:flutter/material.dart';
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:get/get.dart';
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
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => chatViewModel.isChatModelInitialized.value
                    ? ListView.builder(
                        controller: chatViewModel.scrollController,
                        itemCount: chatViewModel.length,
                        itemBuilder: (context, index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                chatViewModel.messages![index].isGptSpeaking
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                            children: [
                              !chatViewModel.messages![index].isGptSpeaking
                                  ? const SizedBox(width: 10)
                                  : const Padding(
                                      padding:
                                          EdgeInsets.only(left: 10, top: 10),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: AssetImage(
                                          'assets/images/gpt_profile.png',
                                        ),
                                      ),
                                    ),
                              ChatMessage(
                                index: index,
                              ),
                            ],
                          );
                        },
                      )
                    : ListView.builder(
                        controller: chatViewModel.scrollController,
                        itemCount: chatViewModel.messagePlaceholder.length,
                        itemBuilder: (context, index) {
                          return ChatMessagePlaceholder(
                            message: chatViewModel
                                .messagePlaceholder[index].message.value,
                            isGptSpeaking: chatViewModel
                                .messagePlaceholder[index].isGptSpeaking,
                          );
                        },
                      ),
              ),
            ),
            const ChatInput(),
          ],
        ),
      );
    });
  }
}
