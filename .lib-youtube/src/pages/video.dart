import 'package:flutter/material.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final ytController = YoutubePlayerController.fromVideoId(
    //     videoId: Get.parameters['videoId'] ?? '');
    // print('videoId: videoId');
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: const [
          Text(
            "Player",
            style: TextStyle(color: Colors.blue),
          ),
          // YoutubePlayer(
          //   controller: ytController,
          //   aspectRatio: 16 / 9,
          // ),
        ],
      ),
    );
  }
}
