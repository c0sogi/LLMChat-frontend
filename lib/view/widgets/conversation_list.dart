import 'package:flutter/material.dart';
import 'package:flutter_web/view/login/login_view.dart';
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
import 'package:flutter_web/viewmodel/login/login_viewmodel.dart';
import 'package:get/get.dart';

class ConversationList extends StatelessWidget {
  const ConversationList({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace this with the actual list of conversations received via WebSocket
    // List<String> conversations =
    //     List.generate(10, (index) => '채팅방${index + 1}');
    final LoginViewModel loginViewModel = Get.find<LoginViewModel>();

    return Column(
      children: [
        const Flexible(flex: 1, child: LoginDrawer()),
        Flexible(
          flex: 1,
          child: Obx(() {
            return ListView.builder(
              itemCount: loginViewModel.chatRooms.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("채팅방 ${loginViewModel.chatRooms[index].id}"),
                  onTap: () async {
                    // Handle conversation selection here
                    if (loginViewModel.selectedApiKey.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'API Key를 선택해주세요.',
                        backgroundColor: Colors.red,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                      return;
                    }
                    loginViewModel.scaffoldKey.currentState!.closeDrawer();
                    await Get.find<ChatViewModel>().beginChat(
                      apiKey: loginViewModel.selectedApiKey,
                      chatRoomId: loginViewModel.chatRooms[index].id,
                    );
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
