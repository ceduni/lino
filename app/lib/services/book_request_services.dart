import 'dart:convert';

import 'package:Lino_app/models/request_model.dart';
import 'package:Lino_app/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class BookRequestService {
  final String url = baseApiUrl;
  
  Future<void> requestBookToUsers(String token, String title,
      {String? cm}) async {
    final r = await http.post(
      Uri.parse('$url/books/request'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'customMessage': cm,
      }),
    );
    if (r.statusCode != 201) {
      throw Exception(jsonDecode(r.body)['error']);
    }
  }

  Future<void> deleteBookRequest(String token, String requestId) async {
    final r = await http.delete( 
      Uri.parse('$url/books/request/$requestId'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        });
    if (r.statusCode != 204 && r.statusCode != 200) {
      throw Exception(jsonDecode(r.body)['error']);
    }
  }

  Future<List<Request>> getBookRequests({String? username}) async {
    var queryParams = {
      if (username != null) 'username': username,
    };
    
    final uri = Uri.parse('$url/books/requests').replace(queryParameters: queryParams);
    
    final r = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    
    if (r.statusCode != 200) {
      final response = jsonDecode(r.body);
      throw Exception(response['error']);
    }
    
    final requestsJson = jsonDecode(r.body) as List;
    List<Request> requests = [];
    for (var reqJson in requestsJson) {
      requests.add(Request.fromJson(reqJson));
    }
    return requests;
  }
}