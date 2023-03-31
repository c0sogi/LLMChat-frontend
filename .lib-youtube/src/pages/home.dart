import 'package:flutter/material.dart';
import '/src/controllers/controllers.dart';
import '/src/models/models.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final String accessKey =
      "2c47a26c-7f65-400e-a860-22de5bdd-bf1b-4294-9370-3cc1761d8b5e";
  final secretKey = "hrvC6nI90NyxfaiwitEqOaunRn1oqRtKQo9p9zz7";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Obx(
        () => ElevatedButton(
          onPressed: () =>
              HomeController.to.onClickButton(accessKey, secretKey, Crud.post),
          child: Text(HomeController.to.text.value),
        ),
      ),
    );
  }
}
