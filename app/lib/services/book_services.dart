import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  final String url = 'http://localhost:3000';

  Future<Map<String, dynamic>> addBookToBB(String qrCode, String bookboxId, {String? token, String? isbn, String? title, List<String>? authors, String? description, String? coverImage, String? publisher, int? parutionYear, int? pages, List<String>? categories}) async {
    // Make a POST request to the server
    // Send the qrCode, then the infos of the book if it's a new book, else just the qrCode
    // If the server returns a 201 status code, the book is added
    // If the server returns a 400 status code, the book is not added
    final r = await http.post(
      Uri.parse('$url/books/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'qrCodeId': qrCode,
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
    if (response['statusCode'] != 201) {
      throw Exception(response['payload']['error']);
    }
    return response;
  }

  Future<Map<String, dynamic>> getBookFromBB(String qrCode, String bookboxId, {String? token}) async {
    // Make a GET request to the server
    // Send the qrCode and bookboxId to the server
    // If the server returns a 200 status code, the book is taken
    // If the server returns another status code, the book is not taken
    final r = await http.get(
      Uri.parse('$url/books/$qrCode/$bookboxId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    final response = jsonDecode(r.body);
    if (response['statusCode'] != 200) {
      throw Exception(response['payload']['error']);
    }
    return response;
  }
}