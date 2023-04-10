import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/chat/scroll_model.dart';

class ScrollViewModel extends GetxController {
  final Rx<ScrollModel> _scrollModel =
      ScrollModel(scrollController: ScrollController()).obs;

  ScrollController get scrollController => _scrollModel.value.scrollController;

  @override
  void onInit() {
    super.onInit();
    _scrollModel.update((val) {
      val!.init();
    });
  }

  @override
  void onClose() {
    super.onClose();
    _scrollModel.update((val) {
      val!.close();
    });
  }

  void scrollToBottom({required bool animated}) {
    _scrollModel.update(
      (val) {
        if (val!.scrollController.hasClients &&
            val.autoScroll &&
            val.scrollController.position.hasContentDimensions) {
          animated
              ? val.scrollController.animateTo(
                  val.scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut)
              : val.scrollController
                  .jumpTo(val.scrollController.position.maxScrollExtent);
        }
      },
    );
  }
}
