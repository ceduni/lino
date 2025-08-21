import 'dart:convert';
import 'package:Lino_app/models/book_model.dart';
import 'package:http/http.dart' as http;
import '../utils/constants/api_constants.dart';

class BookService {
  final String url = baseApiUrl;
  
  Future<Map<String, dynamic>> getBookInfo(String isbn) async {
    // Make a GET request to the server
    // Query the info of the book with the given ISBN
    // If the server returns a 200 status code, the book is found
    // If the server returns another status code, the book is not found
    final r = await http.get(
      Uri.parse('$url/books/info-from-isbn/$isbn'),
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

  Future<ExtendedBook> getBook(String bookId) async {
    // Make a GET request to the server
    // Send the bookId to the server
    // If the server returns a 200 status code, the book is found
    // If the server returns another status code, the book is not found
    final r = await http.get(
      Uri.parse('$url/books/$bookId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    return ExtendedBook.fromJson(response);
  }

  Future<BookStats> getBookStats(String isbn) async {
    final r = await http.get(
      Uri.parse('$url/books/stats/$isbn'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    return BookStats.fromJson(response);
  }
}
