import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/chat/chat_viewmodel.dart';
import '../../viewmodel/login/login_viewmodel.dart';

class LoginDrawer extends StatelessWidget {
  const LoginDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Obx(
          () => Get.find<LoginController>().jwtToken.value.isEmpty
              ? const LoginForm()
              : const ApiKeysList(),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: Get.find<LoginController>().formKey,
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
        ),
      ],
    );
  }
}

class AuthButtons extends StatelessWidget {
  const AuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // 로그인 유지 체크박스
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: loginController.isRemembered.value,
                  onChanged: (bool? value) {
                    if (value != null) {
                      loginController.isRemembered(value);
                    }
                  },
                ),
                const Text(
                  '로그인 유지',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Row(
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
                            if (loginController.formKey.currentState!
                                .validate()) {
                              loginController.isLoading.value = true;
                              await loginController.register(
                                loginController.formKey.currentState!
                                    .fields['email']!.value,
                                loginController.formKey.currentState!
                                    .fields['password']!.value,
                              );
                              loginController.isLoading.value = false;
                            }
                          },
                          child: const Text('회원가입'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                // 로그인 버튼
                onPressed: loginController.isLoading.value
                    ? null
                    : () async {
                        if (loginController.formKey.currentState!.validate()) {
                          loginController.isLoading.value = true;
                          await loginController.login(
                            loginController
                                .formKey.currentState!.fields['email']!.value,
                            loginController.formKey.currentState!
                                .fields['password']!.value,
                          );
                          loginController.isLoading.value = false;
                        }
                      },
                child: loginController.isLoading.value
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('로그인'),
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
        labelText: '이메일',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: "이메일은 필수입니다."),
        FormBuilderValidators.email(errorText: "이메일 형식이 아닙니다."),
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
        labelText: '비밀번호',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
      obscureText: true,
      validator: FormBuilderValidators.compose(
        [
          FormBuilderValidators.required(errorText: "비밀번호는 필수입니다."),
          FormBuilderValidators.minLength(6, errorText: "비밀번호는 6자 이상입니다."),
        ],
      ),
    );
  }
}

class ApiKeysList extends StatelessWidget {
  const ApiKeysList({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginController>();
    final chatController = Get.find<ChatViewModel>();
    return Obx(
      () => Column(
        children: [
          Card(
            color: Theme.of(context).primaryColor,
            elevation: 5,
            child: ListTile(
              title: Text(
                "${loginController.username}님 안녕하세요!",
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                "여기를 눌러 로그아웃 하세요.",
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () async {
                await loginController.deleteToken();
                chatController.endChat();
              },
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: loginController.apiKeys.length,
            itemBuilder: (context, index) {
              final apiKey = loginController.apiKeys[index];
              return Card(
                child: ListTile(
                  title: Text(apiKey['user_memo']),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd hh:mm a')
                        .format(DateTime.parse(apiKey['created_at'])),
                  ),
                  onTap: () => loginController.onClickApiKey(
                    accessKey: apiKey['access_key'],
                    userMemo: apiKey['user_memo'],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
