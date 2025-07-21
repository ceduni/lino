import 'dart:convert';

import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/thread_model.dart';
import 'package:Lino_app/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class SearchService {
  final String url = baseApiUrl;

  Future<List<ShortenedBookBox>> searchBookboxes(
      {String? q,
      bool? asc,
      String? cls,
      num? longitude,
      num? latitude}) async {
    // Make a GET request to the server
    // Send the parameters to the server
    // If the server returns a 200 status code, the bookboxes are found
    // If the server returns another status code, the bookboxes are not found
    var queryParams = {
      if (q!= null) 'q': q, // the keywords
      if (asc != null)
        'asc': asc
            .toString(), // the bool to determine if we want the bookboxes in ascending or descending order of the cls
      if (cls != null)
        'cls':
            cls, // the classificator : ['by name', 'by location', 'by number of books']
      if (longitude != null) 'longitude': longitude.toString(),
      if (latitude != null) 'latitude': latitude.toString(),
    };

    final r = await http.get(
      Uri.parse('$url/search/bookboxes').replace(queryParameters: queryParams),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    List<ShortenedBookBox> bookboxes = [];
    for (var bookBoxJson in response['bookboxes']) {
      bookboxes.add(ShortenedBookBox.fromJson(bookBoxJson));
    }
    return bookboxes;
  }

  Future<List<ShortenedBookBox>> findNearestBookboxes(
    double longitude,
    double latitude,
    { double? maxDistance,
    bool searchByBorough = false }
  ) async {
    var queryParams = {
      'longitude': longitude.toString(),
      'latitude': latitude.toString(),
      if (maxDistance != null) 'maxDistance': maxDistance.toString(),
      'searchByBorough': searchByBorough.toString(),
    };

    final r = await http.get(
      Uri.parse('$url/search/bookboxes/nearest').replace(queryParameters: queryParams),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    List<ShortenedBookBox> bookboxes = [];
    for (var bookBoxJson in response['bookboxes']) {
      bookboxes.add(ShortenedBookBox.fromJson(bookBoxJson));
    }
    return bookboxes;
  }

  Future<List<ExtendedBook>> searchBooks(
      {String? q, String? cls, bool? asc}) async {
    // Make a GET request to the server
    // Send the parameters to the server
    // If the server returns a 200 status code, the books are found
    // If the server returns another status code, the books are not found
    var queryParams = {
      if (q!= null) 'q': q, // the keywords
      if (cls != null)
        'cls':
        cls, // the classificator : ['by title', 'by author', 'by year', 'by most recent activity']
      if (asc != null)
        'asc': asc
            .toString(), // the bool to determine if we want the books in ascending or descending order of the cls
    };

    final r = await http.get(
      Uri.parse('$url/search/books').replace(queryParameters: queryParams),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    List<ExtendedBook> books = [];
    for (var bookJson in response['books']) {
      books.add(ExtendedBook.fromJson(bookJson));
    }
    return books;
  }


  Future<List<Thread>> searchThreads({String? q, String? cls, bool? asc}) async {
    var queryParams = {
      if (q != null && q.isNotEmpty) 'q': q,
      if (cls != null && cls.isNotEmpty) 'cls': cls,
      if (asc != null) 'asc': asc.toString(),
    };

    final r = await http.get(Uri.parse('$url/search/threads').replace(queryParameters: queryParams),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    List<Thread> threads = [];
    for (var thread in response['threads']) {
      threads.add(Thread.fromJson(thread));
    }
    return threads;
  }
}