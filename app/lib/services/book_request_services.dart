import 'dart:convert';

import 'package:Lino_app/models/request_model.dart';
import 'package:Lino_app/utils/constants/api_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  Future<List<BookSuggestion>> getBookSuggestions(String query, {int limit = 10}) async {
    // Load from env
    final apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    
    final uri = Uri.parse('https://www.googleapis.com/books/v1/volumes').replace(queryParameters: {
      'q': query,
      'maxResults': limit.toString(),
      if (apiKey.isNotEmpty) 'key': apiKey,
    });

    final r = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );


    if (r.statusCode != 200) {
      final errorBody = jsonDecode(r.body);
      throw Exception(errorBody['error']?['message'] ?? 'Failed to fetch suggestions');
    }

    final responseBody = jsonDecode(r.body);
    final suggestionsJson = responseBody['items'] as List? ?? [];

    List<BookSuggestion> suggestions = [];
    for (var suggestionJson in suggestionsJson) {
      try {
        suggestions.add(mapToBookSuggestion(suggestionJson));
      } catch (e) {
        print('Error parsing suggestion: $e');
        // Skip this suggestion and continue
      }
    }
    return suggestions;
  }
}

BookSuggestion mapToBookSuggestion(Map<String, dynamic> json) {
  final volumeInfo = json['volumeInfo'] as Map<String, dynamic>;
  final title = volumeInfo['title'] as String? ?? 'Unknown Title';
  
  String author = 'Unknown Author';
  if (volumeInfo['authors'] != null) {
    if (volumeInfo['authors'] is List) {
      final authors = volumeInfo['authors'] as List;
      author = authors.isNotEmpty ? authors.join(', ') : 'Unknown Author';
    } else {
      author = volumeInfo['authors'].toString();
    }
  }
  
  return BookSuggestion(title: title, author: author);
}

class BookSuggestion {
  final String title;
  final String author;

  BookSuggestion({required this.title, required this.author});

  factory BookSuggestion.fromJson(Map<String, dynamic> json) {
    return BookSuggestion(
      title: json['title'] as String,
      author: json['author'] as String
    );
  }

  // ToString method for debugging
  @override
  String toString() {
    return 'BookSuggestion(title: $title, author: $author)';
  }
}
