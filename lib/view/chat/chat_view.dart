import 'package:flutter/material.dart';
import 'package:flutter_web/model/chat/chat_image_model.dart';
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
            children: [
              Expanded(
                child: chatViewModel.isChatModelInitialized.value
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
                              if (chatViewModel.messages![index].isGptSpeaking)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 10),
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            ChatImageModel.getLlmAssetImage(
                                          chatViewModel
                                              .messages![index].modelName.value,
                                        ),
                                      ),
                                      if (chatViewModel
                                          .messages![index].isLoading.value)
                                        const Positioned.fill(
                                          child: CircularProgressIndicator(
                                            // backgroundColor: Colors.transparent,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.blue,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              Column(
                                crossAxisAlignment:
                                    chatViewModel.messages![index].isGptSpeaking
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                children: [
                                  ChatMessage(
                                    index: index,
                                  ),
                                  Text(
                                    DateFormat('MMM d, yyyy, h:mm a').format(
                                        chatViewModel
                                            .messages![index].dateTime),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (!chatViewModel.messages![index].isGptSpeaking)
                                const Padding(
                                  padding: EdgeInsets.only(right: 10, top: 10),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: ChatImageModel.user,
                                  ),
                                ),
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
