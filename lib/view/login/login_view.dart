import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web/model/chat/chat_image_model.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/login/login_viewmodel.dart';
import '../widgets/conversation_list.dart';

class LoginDrawer extends StatelessWidget {
  const LoginDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginViewModel loginViewModel = Get.find<LoginViewModel>();
    return Drawer(
      child: Obx(
        () => loginViewModel.jwtToken.isEmpty
            ? const LoginForm()
            : Column(
                children: [
                  const LoginHeader(),
                  const CreateNewApiKey(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const ApiKeysList(),
                          if (loginViewModel.selectedApiKey.isNotEmpty)
                            const ConversationList(),
                        ],
                      ),
                    ),
                  ),
                  if (loginViewModel.selectedApiKey.isNotEmpty)
                    const CreateNewConversation(),
                ],
              ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const SizedBox(height: 30),
          FormBuilder(
            key: Get.find<LoginViewModel>().formKey,
            child: Column(
              children: const [
                EmailForm(),
                SizedBox(height: 20),
                PasswordForm(),
                SizedBox(height: 20),
                AuthButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthButtons extends StatelessWidget {
  const AuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginViewModel loginViewModel = Get.find<LoginViewModel>();
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remember me',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Checkbox(
                    value: loginViewModel.isRemembered,
                    onChanged: (bool? value) {
                      if (value != null) {
                        loginViewModel.isRemembered = value;
                      }
                    },
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                // 회원가입 버튼
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        if (loginViewModel.formKey.currentState!.validate()) {
                          loginViewModel.isLoading(true);
                          await loginViewModel
                              .register(
                                loginViewModel.formKey.currentState!
                                    .fields['email']!.value,
                                loginViewModel.formKey.currentState!
                                    .fields['password']!.value,
                              )
                              .then((value) => loginViewModel.isLoading(false));
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        'Register',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                // 로그인 버튼
                onPressed: loginViewModel.isLoading.value
                    ? null
                    : () async {
                        if (loginViewModel.formKey.currentState!.validate()) {
                          loginViewModel.isLoading(true);
                          await loginViewModel
                              .login(
                                loginViewModel.formKey.currentState!
                                    .fields['email']!.value,
                                loginViewModel.formKey.currentState!
                                    .fields['password']!.value,
                              )
                              .then((_) => loginViewModel.isLoading(false));
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: loginViewModel.isLoading.value
                      ? const RefreshProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Login', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmailForm extends StatelessWidget {
  const EmailForm({super.key});

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: 'email',
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: "E-mail is required."),
        FormBuilderValidators.email(errorText: "Invalid E-mail."),
      ]),
      keyboardType: TextInputType.emailAddress,
    );
  }
}

class PasswordForm extends StatelessWidget {
  const PasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: 'password',
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
      obscureText: true,
      validator: FormBuilderValidators.compose(
        [
          FormBuilderValidators.required(errorText: "Password is required."),
          FormBuilderValidators.minLength(6,
              errorText: "Password must be at least 6 characters."),
        ],
      ),
    );
  }
}

class ApiKeysList extends StatelessWidget {
  const ApiKeysList({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Get.find<LoginViewModel>();
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: loginViewModel.apiKeys.length,
        itemBuilder: (context, index) {
          final apiKey = loginViewModel.apiKeys[index];
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const Icon(Icons.vpn_key),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Text(apiKey['user_memo']),
              subtitle: Text(
                DateFormat('yyyy-MM-dd hh:mm a')
                    .format(DateTime.parse(apiKey['created_at'])),
              ),
              onTap: () async => await loginViewModel.onClickApiKey(
                accessKey: apiKey['access_key'],
                userMemo: apiKey['user_memo'],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Get.find<LoginViewModel>();
    return Obx(
      () => Card(
        color: loginViewModel.selectedApiKey.isEmpty
            ? ThemeViewModel.idleColor
            : ThemeViewModel.activeColor,
        elevation: 5,
        child: Column(
          // Column 위젯으로 변경하여 위젯들을 세로로 배치합니다.
          mainAxisAlignment: MainAxisAlignment.center, // 위젯들의 간격을 균등하게 합니다.
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 10),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: ChatImageModel.user,
                  ),
                ),
                Column(
                  children: [
                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(loginViewModel.username),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                // Logout과 Unregister 버튼을 Row 위젯으로 표시합니다.
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround, // 버튼들의 간격을 균등하게 합니다.
                children: [
                  Column(
                    children: [
                      IconButton(
                        // Unregister 버튼을 ElevatedButton 위젯으로 표시합니다.
                        onPressed: loginViewModel
                            .unregister, // 버튼을 누르면 loginViewModel.unregister 함수를 호출합니다.
                        icon: const Icon(Icons.delete_sweep_rounded),
                      ),
                      const Text(
                        "Unregister",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        // Unregister 버튼을 ElevatedButton 위젯으로 표시합니다.
                        onPressed: loginViewModel
                            .logout, // 버튼을 누르면 loginViewModel.unregister 함수를 호출합니다.
                        icon: const Icon(Icons.logout_rounded),
                      ),
                      const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateNewApiKey extends StatelessWidget {
  const CreateNewApiKey({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Get.find<LoginViewModel>();
    return Card(
      color: Theme.of(context).primaryColor,
      elevation: 5,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            Icon(
              Icons.vpn_key,
              color: Colors.white,
            ),
          ],
        ),
        tileColor: Theme.of(context).secondaryHeaderColor,
        title: const Text(
          "Create New API Key",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          textAlign: TextAlign.start,
        ),
        onTap: () async =>
            await loginViewModel.createNewApiKey(userMemo: "ChatGPT API Key"),
      ),
    );
  }
}
