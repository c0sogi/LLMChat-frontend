import 'package:flutter/material.dart';

import '../../app/app_config.dart';

class ScrollModel {
  final ScrollController _scrollController;
  bool _autoScroll = true;
  ScrollModel({required ScrollController scrollController})
      : _scrollController = scrollController;

  ScrollController get scrollController => _scrollController;
  bool get autoScroll => _autoScroll;

  void init() {
    _scrollController.addListener(
      () => {
        if (_scrollController.hasClients)
          {
            _scrollController.offset + Config.scrollOffset >=
                    _scrollController.position.maxScrollExtent
                ? _autoScroll = true
                : _autoScroll = false
          }
      },
    );
    _autoScroll = true;
  }

  void close() {
    _scrollController.dispose();
  }
}
