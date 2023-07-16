import 'package:flutter/material.dart';
import 'package:flutter_web/utils/string_formatter.dart';
import 'package:flutter_web/view/login/login_view.dart';
import 'package:flutter_web/viewmodel/login/login_viewmodel.dart';
import 'package:get/get.dart';
import '../viewmodel/chat/chat_viewmodel.dart';
import 'chat/chat_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveScaffold(
      drawerContent: Drawer(
        child: LoginDrawer(),
      ),
      bodyContent: ChatView(),
    );
  }
}

class ChatScaffold extends StatelessWidget {
  const ChatScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginViewModel loginViewModel = Get.find<LoginViewModel>();
    return Scaffold(
      key: loginViewModel.scaffoldKey,
      appBar: AppBar(
        leadingWidth: 200,
        leading: FilledButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () =>
              loginViewModel.scaffoldKey.currentState?.openDrawer(),
          child: Tooltip(
            message: "Open menu",
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Obx(() => loginViewModel.jwtToken.isEmpty
                    ? const Icon(Icons.menu)
                    : const Icon(Icons.menu_open)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => loginViewModel.jwtToken.isEmpty
                    ? const Text(
                        'Not Logged In',
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(loginViewModel.username,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis)),
              ),
            ]),
          ),
        ),
        title: Obx(
          () => Text(
            chatModelNameFormatter(
              Get.find<ChatViewModel>().selectedModel.value,
            ),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          Obx(
            () => loginViewModel.jwtToken.isEmpty
                ? const SizedBox()
                : Tooltip(
                    message: "Logout",
                    child: FilledButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: loginViewModel.logout,
                      child: const Icon(Icons.logout_outlined),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: const Drawer(
          child: LoginDrawer(),
        ),
      ),
      body: const Row(
        children: [
          Expanded(
            flex: 3,
            child: ChatView(),
          ),
        ],
      ),
    );
  }
}

class ResponsiveScaffold extends StatelessWidget {
  final Widget drawerContent;
  final Widget bodyContent;

  const ResponsiveScaffold({
    super.key,
    required this.drawerContent,
    required this.bodyContent,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 750) {
          // Use a row layout for larger screen sizes
          return Row(
            children: [
              SizedBox(
                width: 300, // or whatever width you want the sidebar to have
                child: drawerContent,
              ),
              Expanded(child: Material(child: bodyContent)),
            ],
          );
        } else {
          // Use a Scaffold with a Drawer for smaller screen sizes
          return const ChatScaffold();
        }
      },
    );
  }
}
