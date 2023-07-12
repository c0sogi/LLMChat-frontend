import 'package:flutter/material.dart';
import 'package:flutter_web/model/chat/chat_model.dart';
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:flutter_web/viewmodel/login/login_viewmodel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ConversationList extends StatelessWidget {
  const ConversationList({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginViewModel loginViewModel = Get.find<LoginViewModel>();
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();

    return Obx(
      () => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: chatViewModel.chatRooms!.length,
        itemBuilder: (context, index) {
          final chatRoom = chatViewModel.chatRooms![index];
          try {
            chatRoom.chatRoomName(DateFormat('yyyy-MM-dd hh:mm a')
                .format(DateTime.parse(chatRoom.chatRoomName.value).toLocal()));
          } catch (_) {
            // do nothing
          }
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Obx(
                      () => chatRoom.isChatRoomNameEditing.value
                          ? TextFormField(
                              initialValue: chatRoom.chatRoomName.value,
                              autofocus: true,
                              maxLength: 20,
                              onFieldSubmitted: (chatRoomName) {
                                if (chatViewModel.isQuerying.value) {
                                  return;
                                }
                                chatRoom.isChatRoomNameEditing(false);
                                chatRoom.chatRoomName(chatRoomName);
                                chatViewModel.performChatAction!(
                                  action: ChatAction.changeChatRoomName,
                                  chatRoomId: chatRoom.chatRoomId,
                                  chatRoomName: chatRoomName,
                                );
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter chat room name here...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )
                          : Text(
                              chatRoom.chatRoomName.value,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => chatRoom.isChatRoomNameEditing(
                    !chatRoom.isChatRoomNameEditing.value,
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete, color: ThemeViewModel.idleColor),
                  onPressed: () => chatViewModel.performChatAction!(
                    action: ChatAction.deleteChatRoom,
                    chatRoomId: chatRoom.chatRoomId,
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
              chatViewModel.performChatAction!(
                action: ChatAction.changeChatRoom,
                chatRoomId: chatViewModel.chatRooms![index].chatRoomId,
              );
              loginViewModel.scaffoldKey.currentState?.closeDrawer();
            },
          );
        },
      ),
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
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          Get.find<ChatViewModel>().performChatAction!(
            action: ChatAction.changeChatRoom,
            chatRoomId: newChatRoomId,
          );
        },
      ),
    );
  }
}
