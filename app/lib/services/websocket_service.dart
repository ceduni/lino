import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _singleton = WebSocketService._internal();
  late WebSocketChannel channel;
  Function(String event, dynamic data)? onEvent;

  factory WebSocketService() {
    return _singleton;
  }

  WebSocketService._internal(); 

  void connect(String url, {String? userId, required Function(String event, dynamic data) onEvent}) {
    this.onEvent = onEvent;
    final uri = Uri.parse(url);
    final queryParameters = userId != null ? {'userId': userId} : {'userId': 'anon'};
    final wsUri = uri.replace(queryParameters: queryParameters);

    channel = IOWebSocketChannel.connect(wsUri.toString());

    channel.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      onEvent(decodedMessage['event'], decodedMessage['data']);
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });
  }

  void sendMessage(String message) {
    channel.sink.add(message);
    }

  void disconnect() {
    channel.sink.close();
    }
}
