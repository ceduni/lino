import 'dart:convert';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/request_model.dart';
import 'package:http/http.dart' as http;
import '../utils/constants/api_constants.dart';

class BookService {
  final String url = baseApiUrl;

  Future<Map<String, dynamic>> addNewBB(String name, double longitude,
      double latitude, String infoText, String token) async {
    // Make a POST request to the server
    // Send the name, longitude, latitude, and infoText to the server
    // If the server returns a 201 status code, the bookbox is added
    // If the server returns another status code, the bookbox is not added
    final r = await http.post(
      Uri.parse('$url/bookboxes/new'),
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
      'bm_token': 'LinoCanIAddOrRemoveBooksPlsThanksLmao',  
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
      'bm_token': 'LinoCanIAddOrRemoveBooksPlsThanksLmao',
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

  Future<BookBox> getBookBox(String bookBoxId) async {
    final r = await http.get(
      Uri.parse('$url/bookboxes/$bookBoxId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    return BookBox.fromJson(response);
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

  Future<List<ExtendedBook>> searchBooks(
      {String? kw, String? cls, bool? asc}) async {
    // Make a GET request to the server
    // Send the parameters to the server
    // If the server returns a 200 status code, the books are found
    // If the server returns another status code, the books are not found
    var queryParams = {
      if (kw != null) 'kw': kw, // the keywords
      if (cls != null)
        'cls':
        cls, // the classificator : ['by title', 'by author', 'by year', 'by most recent activity']
      if (asc != null)
        'asc': asc
            .toString(), // the bool to determine if we want the books in ascending or descending order of the cls
    };

    final r = await http.get(
      Uri.parse('$url/books/search').replace(queryParameters: queryParams),
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

  Future<List<BookBox>> searchBookboxes(
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
      if (longitude != null) 'longitude': longitude.toString(),
      if (latitude != null) 'latitude': latitude.toString(),
    };

    final r = await http.get(
      Uri.parse('$url/bookboxes/search').replace(queryParameters: queryParams),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    List<BookBox> bookboxes = [];
    for (var bookBoxJson in response['bookboxes']) {
      bookboxes.add(BookBox.fromJson(bookBoxJson));
    }
    return bookboxes;
  }

  Future<void> requestBookToUsers(String token, String title,
      {String? cm, num? latitude, num? longitude}) async {
    var queryParams = <String, String>{
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
    };
    final r = await http.post(
      Uri.parse('$url/books/request').replace(queryParameters: queryParams),
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
    final r = await http.get(
      Uri.parse('$url/books/requests').replace(queryParameters: queryParams),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    List<Request> requests = [];
    for (var reqJson in response['requests']) {
      requests.add(Request.fromJson(reqJson));
    }
    return requests;
  }
}
