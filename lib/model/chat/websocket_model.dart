import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketModel {
  HtmlWebSocketChannel? _channel;
  bool _isConnected = false;
  StreamSubscription? _streamSubscription;
  void Function(dynamic) onMessageCallback;
  void Function(dynamic) onErrCallback;
  void Function() onSuccessConnectCallback;
  void Function() onFailConnectCallback;

  HtmlWebSocketChannel? get channel => _channel;
  WebSocketSink? get sink => _channel?.sink;
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
    _channel = HtmlWebSocketChannel.connect(url);
    await _listen(url);
    print("websocket connected!");
  }

  Future<void> _listen(String url) async {
    if (_channel == null) {
      return;
    }
    try {
      _streamSubscription = _channel!.stream.listen(
        (rcvd) => onMessageCallback(rcvd),
        onDone: () async {
          _isConnected = false;
          await reconnect(duration: const Duration(seconds: 1), url: url);
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
      print("trying to reconnect...");
      if (_isConnected) {
        timer.cancel();
        print("reconnected!");
      } else {
        try {
          print("trying to reconnect...");
          await close();
          await connect(url);
        } catch (e) {
          print("reconnect failed: $e");
        }
      }
    });
  }

  Future<void> close() async {
    print("closing websocket...");
    await _channel?.sink.close();
    await _streamSubscription?.cancel();
    _isConnected = false;
  }

  void send(String message) {
    _channel?.sink.add(message);
  }

  void sendJson(Map<String, dynamic> json) {
    _channel?.sink.add(jsonEncode(json));
  }

  void sendJsonList(List<Map<String, dynamic>> jsonList) {
    _channel?.sink.add(jsonEncode(jsonList));
  }
}
