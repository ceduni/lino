import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class BookService {
  final String url = 'https://lino-1.onrender.com';

  Future<Map<String, dynamic>> addNewBB(String name, double longitude,
      double latitude, String infoText, String token) async {
    // Make a POST request to the server
    // Send the name, longitude, latitude, and infoText to the server
    // If the server returns a 201 status code, the bookbox is added
    // If the server returns another status code, the bookbox is not added
    final r = await http.post(
      Uri.parse('$url/books/bookbox/new'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'longitude': longitude,
        'latitude': latitude,
        'infoText': infoText,
      }),
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 201) {
      throw Exception(response['error']);
    }
    return response;
  }

  Future<Map<String, dynamic>> addBookToBB(String qrCode, String bookboxId,
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
    if (r.statusCode != 201) {
      throw Exception(response['error']);
    }
    return response;
  }

  Future<Map<String, dynamic>> getBookFromBB(String qrCode, String bookboxId,
      {String? token}) async {
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
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    return response;
  }

  Future<Map<String, dynamic>> getBookInfo(String isbn) async {
    // Make a GET request to the server
    // Send the isbn to the server
    // If the server returns a 200 status code, the book is found
    // If the server returns another status code, the book is not found
    final r = await http.get(
      Uri.parse('$url/books/$isbn'),
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

  Future<Map<String, dynamic>> getBook(String bookId) async {
    // Make a GET request to the server
    // Send the bookId to the server
    // If the server returns a 200 status code, the book is found
    // If the server returns another status code, the book is not found
    final r = await http.get(
      Uri.parse('$url/books/get/$bookId'),
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

  Future<Map<String, dynamic>> searchBooks(
      {List<String>? cat,
      String? kw,
      bool? pmt,
      int? pg,
      bool? bf,
      int? py,
      String? pub,
      String? bbid,
      String? cls,
      bool? asc}) async {
    // Make a GET request to the server
    // Send the parameters to the server
    // If the server returns a 200 status code, the books are found
    // If the server returns another status code, the books are not found
    var queryParams = {
      if (cat != null)
        'cat': cat.join(','), // the list of categories, separated by commas
      if (kw != null) 'kw': kw, // the keywords
      if (pmt != null)
        'pmt': pmt
            .toString(), // the bool to determine if we want the books with more or less than X pages
      if (pg != null) 'pg': pg.toString(), // the page number
      if (bf != null)
        'bf': bf
            .toString(), // the bool to determine if we want the books published before or after the year
      if (py != null) 'py': py.toString(), // the year
      if (pub != null) 'pub': pub, // the publisher
      if (bbid != null) 'bbid': bbid, // the bookbox id
      if (cls != null)
        'cls':
            cls, // the classificator : ['by title', 'by author', 'by year', 'by most recent activity']
      if (asc != null)
        'asc': asc
            .toString(), // the bool to determine if we want the books in ascending or descending order of the cls
    };

    final r = await http.get(
      Uri.https('lino-1.onrender.com', '/books/search', queryParams),
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

  Future<Map<String, dynamic>> searchBookboxes(
      {String? kw,
      bool? asc,
      String? cls,
      num? longitude,
      num? latitude}) async {
    // Make a GET request to the server
    // Send the parameters to the server
    // If the server returns a 200 status code, the bookboxes are found
    // If the server returns another status code, the bookboxes are not found
    var queryParams = {
      if (kw != null) 'kw': kw, // the keywords
      if (asc != null)
        'asc': asc
            .toString(), // the bool to determine if we want the bookboxes in ascending or descending order of the cls
      if (cls != null)
        'cls':
            cls, // the classificator : ['by name', 'by location', 'by number of books']
      'longitude': longitude.toString(),
      'latitude': latitude.toString(),
    };

    final r = await http.get(
      Uri.https('lino-1.onrender.com', '/books/bookbox/search', queryParams),
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

  Future<Map<String, dynamic>> requestBookToUsers(String token, String title,
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
    final response = jsonDecode(r.body);
    if (r.statusCode != 201) {
      throw Exception(response['error']);
    }
    return response;
  }

  Future<Map<String, dynamic>> getBookThreads(String bookId) async {
    final r = await http.get(
      Uri.parse('$url/books/threads/$bookId'),
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
