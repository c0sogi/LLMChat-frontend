import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';

class SubscribePage extends StatelessWidget {
  const SubscribePage({super.key});

  Widget widgetMaker(BuildContext context, Image data) {
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subscribe")),
      body: const ImageNetwork(
        image:
            "https://s.pstatic.net/static/www/mobile/edit/20230222/cropImg_728x360_118996916761733542.jpeg",
        height: 500,
        width: 500,
      ),
    );
  }
}
