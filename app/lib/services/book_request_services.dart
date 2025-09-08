import 'dart:convert';

import 'package:Lino_app/models/book_suggestion.dart';
import 'package:Lino_app/models/request_model.dart';
import 'package:Lino_app/utils/constants/api_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BookRequestService {
  final String url = baseApiUrl;
  
  Future<void> requestBookToUsers(String token, String title,
      {String? cm, List<String>? bookboxIds}) async {
    final r = await http.post(
      Uri.parse('$url/books/request'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'customMessage': cm,
        'bookboxIds': bookboxIds,
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

  
  Future<UpvoteResponse> toggleUpvote(String token, String requestId) async {
    final r = await http.patch(
      Uri.parse('$url/books/request/$requestId/upvote'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    
    if (r.statusCode == 401) {
      throw Exception('Authentication required');
    }
    
    if (r.statusCode == 404) {
      throw Exception('Request not found');
    }
    
    if (r.statusCode != 200) {
      final response = jsonDecode(r.body);
      throw Exception(response['error']);
    }
    
    final responseBody = jsonDecode(r.body);
    return UpvoteResponse.fromJson(responseBody);
  }

  Future<SolveResponse> toggleSolvedStatus(String token, String requestId) async {
    final r = await http.patch(
      Uri.parse('$url/books/request/$requestId/solve'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (r.statusCode == 401) {
      throw Exception('Authentication required');
    }
    
    if (r.statusCode == 404) {
      throw Exception('Request not found');
    }
    
    if (r.statusCode != 200) {
      final response = jsonDecode(r.body);
      throw Exception(response['error']);
    }
    
    final responseBody = jsonDecode(r.body);
    return SolveResponse.fromJson(responseBody);
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



// Enums for filtering and sorting
