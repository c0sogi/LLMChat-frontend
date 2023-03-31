import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Add intl to your pubspec.yaml
import '../chat/chat_controller.dart';
import 'login_controller.dart';

class LoginDrawer extends StatelessWidget {
  const LoginDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.put(LoginController());
    return Drawer(
      child: SingleChildScrollView(
        child: Obx(
          () => loginController.jwtToken.value.isEmpty
              ? LoginForm(loginController: loginController)
              : ApiKeysList(loginController: loginController),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.loginController,
  });

  final LoginController loginController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: loginController.formKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: 'password',
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(6),
                  ]),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
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
                      ElevatedButton(
                        onPressed: loginController.isLoading.value
                            ? null
                            : () async {
                                if (loginController.formKey.currentState!
                                    .validate()) {
                                  loginController.isLoading.value = true;
                                  await loginController.login(
                                    loginController.formKey.currentState!
                                        .fields['email']!.value,
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
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ApiKeysList extends StatelessWidget {
  final LoginController loginController;

  const ApiKeysList({super.key, required this.loginController});

  @override
  Widget build(BuildContext context) {
    // return const Text("Hello");
    print("apiKeys: ${loginController.apiKeys.value}");
    return Obx(() {
      return ListView.builder(
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
              onTap: () {
                // Save the selected API key for later use and show a Snackbar for visual confirmation
                Get.find<LoginController>()
                    .selectedApiKey(apiKey['access_key']);
                Get.snackbar(
                    'API Key Selected', '${apiKey['user_memo']}가 선택되었습니다.');
                Get.find<ChatController>().beginChat(apiKey['access_key']);
              },
            ),
          );
        },
      );
    });
  }
}
