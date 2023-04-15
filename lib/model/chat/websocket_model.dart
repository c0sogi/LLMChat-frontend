import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketModel {
  HtmlWebSocketChannel _channel;
  String url;
  bool _isConnected = false;
  StreamSubscription? _streamSubscription;
  void Function(dynamic) onMessageCallback;
  void Function(dynamic) onErrCallback;
  void Function() onSuccessConnectCallback;
  void Function() onFailConnectCallback;

  HtmlWebSocketChannel get channel => _channel;
  WebSocketSink get sink => _channel.sink;
  bool get isConnected => _isConnected;

  WebSocketModel({
    required this.url,
    required this.onMessageCallback,
    required this.onErrCallback,
    required this.onSuccessConnectCallback,
    required this.onFailConnectCallback,
  }) : _channel = HtmlWebSocketChannel.connect(url);

  Future<void> listen() async {
    try {
      _streamSubscription = _channel.stream.listen(
        (rcvd) => onMessageCallback(rcvd),
        onDone: () async {
          _isConnected = false;
          await reconnect(url: url);
        },
        onError: (err) async {
          _isConnected = false;
          onErrCallback(err);
          await reconnect(url: url);
        },
      );
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
    }
    // wait for 1 second and check if websocket is connected
    _isConnected ? onSuccessConnectCallback() : onFailConnectCallback();
  }

  Future<void> reconnect({required String url}) async {
    if (_isConnected) {
      return;
    }
    await Future.delayed(const Duration(seconds: 5));

    try {
      _channel = HtmlWebSocketChannel.connect(url);
      await listen();
    } catch (e) {
      _isConnected = false;
      await reconnect(url: url);
    }
    _isConnected = true;
    this.url = url;
  }

  Future<void> close() async {
    await _channel.sink.close();
    await _streamSubscription?.cancel();
    _isConnected = false;
  }

  void send(String message) {
    _channel.sink.add(message);
  }

  void sendJson(Map<String, dynamic> json) {
    _channel.sink.add(jsonEncode(json));
  }

  void sendJsonList(List<Map<String, dynamic>> jsonList) {
    _channel.sink.add(jsonEncode(jsonList));
  }
}
