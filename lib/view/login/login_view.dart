import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web/model/chat/chat_image_model.dart';
import 'package:flutter_web/model/chat/chat_model.dart';
import 'package:flutter_web/utils/string_formatter.dart';
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
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
      width: 300,
      child: Obx(
        () => loginViewModel.jwtToken.isEmpty
            ? const LoginForm()
            : Column(
                children: [
                  const LoginHeader(),
                  if (loginViewModel.selectedApiKey.isNotEmpty)
                    const ModelSelectionDropdown(),
                  const CreateNewApiKey(),
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        const SliverToBoxAdapter(
                          child: ApiKeysList(),
                        ),
                        if (loginViewModel.selectedApiKey.isNotEmpty)
                          const SliverToBoxAdapter(
                            child: ConversationList(),
                          ),
                      ],
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

class ModelSelectionDropdown extends StatelessWidget {
  const ModelSelectionDropdown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            "Chat Model",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Obx(
            () => DropdownButton<String>(
              elevation: 0,
              dropdownColor: ThemeViewModel.activeColor,
              alignment: Alignment.center,
              focusColor: Colors.transparent,
              isExpanded: true,
              value: chatViewModel.selectedModel.value.isEmpty
                  ? null
                  : chatViewModel.selectedModel.value,
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white,
              items: chatViewModel.models!
                  .map<DropdownMenuItem<String>>((String menuItem) {
                return DropdownMenuItem<String>(
                  alignment: Alignment.center,
                  value: menuItem,
                  child: Text(
                    chatModelNameFormatter(menuItem),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null &&
                    (!Get.find<ChatViewModel>().isQuerying.value)) {
                  chatViewModel.performChatAction!(
                    action: ChatAction.changeChatModel,
                    chatModelName: value,
                  );
                }
              },
            ),
          ),
        ),
      ],
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
            child: const Column(
              children: [
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
                    checkColor: ThemeViewModel.idleColor,
                    activeColor: Colors.white,
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
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: loginViewModel.apiKeys.length,
        itemBuilder: (context, index) {
          final apiKey = loginViewModel.apiKeys[index];
          return Card(
            color: loginViewModel.selectedApiKey.isEmpty
                ? ThemeViewModel.idleColor.withOpacity(0.5)
                : ThemeViewModel.activeColor.withOpacity(0.5),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const Icon(Icons.vpn_key),
              title: Text(apiKey['user_memo']),
              subtitle: Text(
                DateFormat('yyyy-MM-dd hh:mm a').format(
                  DateTime.parse(apiKey['created_at'] + "Z").toLocal(),
                ),
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
            ? ThemeViewModel.idleColor.withOpacity(0.5)
            : ThemeViewModel.activeColor.withOpacity(0.5),
        elevation: 5,
        child: Column(
          // Column 위젯으로 변경하여 위젯들을 세로로 배치합니다.
          mainAxisAlignment: MainAxisAlignment.center, // 위젯들의 간격을 균등하게 합니다.
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: ChatImageModel.user.value,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        width: 150,
                        child: Text(
                          loginViewModel.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
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
                "New Key",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.start,
              ),
            ),
            Icon(
              Icons.vpn_key,
              color: Colors.white,
            ),
          ],
        ),
        tileColor: Theme.of(context).secondaryHeaderColor,
        onTap: () async =>
            await loginViewModel.createNewApiKey(userMemo: "API Key"),
      ),
    );
  }
}
