import 'package:flutter/material.dart';
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:flutter_web/viewmodel/login/login_viewmodel.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ConversationList extends StatelessWidget {
  const ConversationList({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginViewModel loginViewModel = Get.find<LoginViewModel>();
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();

    return Column(
      children: [
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            itemCount: chatViewModel.chatRoomIds.length,
            itemBuilder: (context, index) {
              final String chatRoomId = chatViewModel.chatRoomIds[index];
              return ListTile(
                title: Row(
                  children: [
                    // add index num of chatroom as icon
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.chat),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Chat",
                              style: TextStyle(
                                color: ThemeViewModel.idleColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(chatRoomId.toUpperCase().substring(
                                  0,
                                  chatRoomId.length > 6 ? 6 : chatRoomId.length,
                                ))
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => chatViewModel.deleteChatRoom(
                          chatRoomId: chatViewModel.chatRoomIds[index],
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Handle conversation selection here
                  if (loginViewModel.selectedApiKey.isEmpty) {
                    Get.snackbar(
                      'Error! API Key not selected.',
                      'API Key를 선택해주세요.',
                      backgroundColor: Colors.red,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 1),
                    );
                    return;
                  }
                  chatViewModel.changeChatRoom(
                    chatRoomId: chatViewModel.chatRoomIds[index],
                  );
                  loginViewModel.scaffoldKey.currentState!.closeDrawer();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CreateNewConversation extends StatelessWidget {
  const CreateNewConversation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      elevation: 5,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "New Chat",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Icon(
              Icons.chat_bubble,
              color: Colors.white,
            ),
          ],
        ),
        tileColor: Theme.of(context).secondaryHeaderColor,
        onTap: () {
          final newChatRoomId = const Uuid().v4().replaceAll('-', '');
          Get.find<ChatViewModel>().changeChatRoom(chatRoomId: newChatRoomId);
        },
      ),
    );
  }
}
