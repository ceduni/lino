import 'dart:convert';

import 'package:web_socket_channel/io.dart';

class WebSocketService {
  static final WebSocketService _singleton = WebSocketService._internal();
  late IOWebSocketChannel channel;

  factory WebSocketService() {
    return _singleton;
  }

  WebSocketService._internal();

  void connect(String url, {String? userId, required Function(String, dynamic) onEvent}) {
    final uri = Uri.parse(url);
    final queryParameters = userId != null ? {'userId': userId} : {'userId': ''};
    final wsUri = uri.replace(queryParameters: queryParameters);
    try {
      channel = IOWebSocketChannel.connect(wsUri.toString());
    } catch (e) {
      print(e);
    }
    channel.stream.listen((message) {
      final decodedMessage = _decodeMessage(message);
      onEvent(decodedMessage['event'], decodedMessage['data']);
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });
  }

  Map<String, dynamic> _decodeMessage(String message) {
    try {
      return Map<String, dynamic>.from(jsonDecode(message));
    } catch (e) {
      print('Error decoding message: $e');
      return {'event': 'error', 'data': message};
    }
  }

  void sendMessage(String message) {
    channel.sink.add(message);
    }

  void disconnect() {
    channel.sink.close();
    }
}
