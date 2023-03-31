import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/src/controllers/controllers.dart';
import '/src/models/models.dart';
import '/src/pages/explore.dart';
import '/src/pages/home.dart';
import '/src/pages/library.dart';
import '/src/pages/subscribe.dart';
import '/src/widgets/widgets.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        switch (MenuNames.values[BtmNavController.to.bottomIndex.value]) {
          case MenuNames.home:
            return const HomePage();
          case MenuNames.explore:
            return const ExplorePage();
          case MenuNames.plus:
            return const Placeholder();
          case MenuNames.subscribe:
            return const SubscribePage();
          case MenuNames.library:
            return const LibraryPage();
        }
      }),
      bottomNavigationBar: const BtmNavBar(),
    );
  }
}
