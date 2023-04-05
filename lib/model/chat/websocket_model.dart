import 'dart:convert';

import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketModel {
  HtmlWebSocketChannel _channel;
  String url;
  bool _isConnected = false;
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

  void listen() {
    try {
      _channel.stream.listen(
        (rcvd) => onMessageCallback(rcvd),
        onDone: () {
          _isConnected = false;
        },
        onError: (err) {
          _isConnected = false;
          onErrCallback(err);
          reconnect(url: url);
        },
      );
      _isConnected = true;
    } catch (e) {
      onFailConnectCallback();
      _isConnected = false;
    }
    onSuccessConnectCallback();
  }

  void reconnect({required String url}) {
    if(isConnected){
      close();
    }
    _channel = HtmlWebSocketChannel.connect(url);
    _isConnected = true;
    this.url = url;
    listen();
  }

  void close() {
    _channel.sink.close();
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
