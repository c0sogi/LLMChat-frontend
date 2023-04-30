import 'package:flutter/material.dart';
import 'package:flutter_web/view/login/login_view.dart';
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
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
        const Flexible(
          flex: 1,
          child: LoginDrawer(),
        ),
        Flexible(
          flex: 1,
          child: Obx(() {
            return ListView.builder(
              itemCount: chatViewModel.chatRoomIds.length,
              itemBuilder: (context, index) {
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
                                "Chatroom",
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(chatViewModel.chatRoomIds[index])
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
            );
          }),
        ),
        Card(
          color: Theme.of(context).primaryColor,
          elevation: 5,
          child: ListTile(
            leading: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            tileColor: Theme.of(context).secondaryHeaderColor,
            title: const Text(
              "Create new chatroom",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.start,
            ),
            onTap: () {
              final newChatRoomId = const Uuid().v4().replaceAll('-', '');
              chatViewModel.changeChatRoom(chatRoomId: newChatRoomId);
            },
          ),
        ),
      ],
    );
  }
}
