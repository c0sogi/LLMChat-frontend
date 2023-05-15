import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:web_socket_channel/html.dart'
    if (dart.library.html) 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/io.dart'
    if (dart.library.io) 'package:web_socket_channel/io.dart';

class WebSocketModel {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _shouldReconnect = false;
  StreamSubscription? _streamSubscription;
  void Function(dynamic) onMessageCallback;
  void Function(dynamic) onErrCallback;
  void Function() onSuccessConnectCallback;
  void Function() onFailConnectCallback;

  WebSocketSink? get sink => _channel?.sink;
  Stream? get stream => _channel?.stream;
  bool get isConnected => _isConnected;

  WebSocketModel({
    required this.onMessageCallback,
    required this.onErrCallback,
    required this.onSuccessConnectCallback,
    required this.onFailConnectCallback,
  });

  Future<void> connect(String url) async {
    // ensure there's no duplicated channel
    await close();
    _shouldReconnect = true;
    kIsWeb
        ? _channel = HtmlWebSocketChannel.connect(url)
        : _channel = IOWebSocketChannel.connect(url);
    await _listen(url);
    // print("websocket connected!");
  }

  Future<void> _listen(String url) async {
    if (stream == null) {
      return;
    }
    try {
      _streamSubscription = stream!.listen(
        (rcvd) => onMessageCallback(rcvd),
        onDone: () async {
          _isConnected = false;
          if (_shouldReconnect) {
            await reconnect(duration: const Duration(seconds: 1), url: url);
          }
        },
        onError: (err) async {
          onErrCallback(err);
        },
      );
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
    }
    // wait for 1 second and check if websocket is connected
    _isConnected ? onSuccessConnectCallback() : onFailConnectCallback();
  }

  Future<void> reconnect(
      {required Duration duration, required String url}) async {
    Timer.periodic(duration, (timer) async {
      // print("trying to reconnect...");
      if (_isConnected || !_shouldReconnect) {
        timer.cancel();
        // print("reconnected!");
      } else {
        try {
          // print("trying to reconnect...");
          await sink?.close();
          await _streamSubscription?.cancel();
          kIsWeb
              ? _channel = HtmlWebSocketChannel.connect(url)
              : _channel = IOWebSocketChannel.connect(url);
          await _listen(url);
        } catch (e) {
          // print("reconnect failed: $e");
        }
      }
    });
  }

  Future<void> close() async {
    // print("closing websocket...");
    _shouldReconnect = false;
    await sink?.close();
    await _streamSubscription?.cancel();
    _isConnected = false;
  }

  void sendBytes(Uint8List? bytes) {
    sink?.add(bytes);
  }

  void sendJson(Map<String, dynamic> json) {
    sink?.add(jsonEncode(json));
  }

  void sendText(String text) {
    sink?.add(text);
  }

  void sendJsonList(List<Map<String, dynamic>> jsonList) {
    sink?.add(jsonEncode(jsonList));
  }
}
