import 'package:flutter/material.dart';
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:get/get.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

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
                        itemCount: chatViewModel.messages!.length,
                        itemBuilder: (context, index) {
                          return ChatMessage(
                            message: chatViewModel.messages![index],
                          );
                        },
                      )
                    : ListView.builder(
                        controller: chatViewModel.scrollController,
                        itemCount: chatViewModel.messagePlaceholder.length,
                        itemBuilder: (context, index) {
                          return ChatMessage(
                            message: chatViewModel.messagePlaceholder[index],
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
