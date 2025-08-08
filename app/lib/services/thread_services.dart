import 'dart:convert';
import 'package:Lino_app/models/thread_model.dart';
import 'package:http/http.dart' as http;
import '../utils/constants/api_constants.dart';

class ThreadService {
  final String url = baseApiUrl;

  Future<void> createThread(String token, String bookid, String title) async {
    final r = await http.post(
      Uri.parse('$url/threads/new'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'bookId': bookid,
        'title': title, 
      }),
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 201) {
      throw Exception(response['error']);
    }
  }

  Future<void> deleteThread(String token, String threadId) async {
    final r = await http.delete(
      Uri.parse('$url/threads/$threadId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });
    if (r.statusCode != 204) {
      throw Exception(jsonDecode(r.body)['error']);
    }
  }

  Future<void> addMessage(String token, String threadId, String content, {String? respondsTo}) async {
    // Initialize the request body with mandatory fields
    Map<String, String> requestBody = {
      'threadId': threadId,
      'content': content,
    };

    // Conditionally add the respondsTo field if it is not null
    if (respondsTo != null) {
      requestBody['respondsTo'] = respondsTo;
    }

    final r = await http.post(
      Uri.parse('$url/threads/messages'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody), // Use the modified requestBody
    );

    final response = jsonDecode(r.body);
    if (r.statusCode != 201) {
      throw Exception(response['error']);
    }
  }

  Future<void> toggleMessageReaction(String token, String threadId, String messageId, bool isGood) async {
    final r = await http.post(
      Uri.parse('$url/threads/messages/reactions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'threadId': threadId,
        'messageId': messageId,
        'reactIcon': isGood? 'good' : 'bad',
      }),
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
  }

  Future<Thread> getThread(String threadId) async {
    final r = await http.get(Uri.parse('$url/threads/$threadId'));
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    return Thread.fromJson(response);
  }
}
