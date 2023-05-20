import 'package:flutter/material.dart';
import 'package:flutter_web/view/login/login_view.dart';
import 'package:flutter_web/viewmodel/login/login_viewmodel.dart';
import 'package:get/get.dart';
import 'chat/chat_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: Row(
        children: const [
          Expanded(
            flex: 3,
            child: ChatView(),
          ),
        ],
      ),
    );
  }
}
