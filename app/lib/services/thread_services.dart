import 'dart:convert';
import 'package:http/http.dart' as http;


class ThreadService {
  final String url = 'http://localhost:3000';

  Future<Map<String, dynamic>> createThread(String token, String bookid, String title) async {
      final r = await http.post(
      Uri.parse('$url/threads/new'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'bookId': bookid,
        'title': title,
      }),
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 201) {
      throw Exception(response['error']);
    }
    return response;
  }

  Future<Map<String, dynamic>> addMessage(String token, String threadId, String content, {String? respondsTo}) async {
      final r = await http.post(
      Uri.parse('$url/threads/messages'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'threadId': threadId,
        'content': content,
        'respondsTo': respondsTo,
      }),
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 201) {
      throw Exception(response['error']);
    }
    return response;
  }

  Future<Map<String, dynamic>> toggleMessageReaction(String token, String threadId, String messageId, String reactIcon) async {
      final r = await http.post(
      Uri.parse('$url/threads/messages/reactions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'threadId': threadId,
        'messageId': messageId,
        'reactIcon': reactIcon,
      }),
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    return response;
  }

  Future<Map<String, dynamic>> getThread(String threadId) async {
    final r = await http.get(Uri.parse('$url/threads/$threadId'));
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    return response;
  }

  Future<Map<String, dynamic>> searchThreads({String? q, String? cls, bool? asc}) async {
    var queryParams = {
      if (q != null) 'q': q,
      if (cls != null) 'cls': cls,
      if (asc != null) 'asc': asc.toString(),
    };

    final r = await http.get(Uri.http('localhost:3000', '/threads/search', queryParams),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    return response;
  }
}