import 'dart:convert';

import 'package:Lino_app/utils/constants/api_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BookExchangeService {
  final String url = baseApiUrl;

  Future<void> addBookToBB(String bookboxId,
      {String? token,
      String? isbn,
      String? title,
      List<String>? authors,
      String? description,
      String? coverImage,
      String? publisher,
      int? parutionYear,
      int? pages,
      List<String>? categories}) async {
    // Make a POST request to the server
    // Send the infos of the book
    // If the server returns a 201 status code, the book is added
    // If the server returns a 400 status code, the book is not added
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
      'bm_token': dotenv.env['BOOK_MANIPULATION_TOKEN'] ?? 'not_set',
    };

    final r = await http.post(
      Uri.parse('$url/bookboxes/$bookboxId/books/add'),
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'isbn': isbn,
        'title': title,
        'authors': authors,
        'description': description,
        'coverImage': coverImage,
        'publisher': publisher,
        'parutionYear': parutionYear,
        'pages': pages,
        'categories': categories,
        'bookboxId': bookboxId,
      }),
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 201) {
      throw Exception(response['error']);
    }
  }

  Future<void> getBookFromBB(String bookId, String bookboxId,
      {String? token}) async {
    final headers = {
      if (token != null) 'Authorization': 'Bearer $token',
      'bm_token': dotenv.env['BOOK_MANIPULATION_TOKEN'] ?? 'not_set',
    };

    // Make a DELETE request to the server
    final r = await http.delete(
      Uri.parse('$url/bookboxes/$bookboxId/books/$bookId'),
      headers: headers,
    );

    // Parse the response
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
  }
}