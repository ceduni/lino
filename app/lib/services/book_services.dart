import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  final String url = 'https://lino-1.onrender.com';

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
        if (token != null) 'Authorization': 'Bearer $token',
        'bm_token': 'LinoCanIAddOrRemoveBooksPlsThanksLmao',
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
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
      'bm_token': 'LinoCanIAddOrRemoveBooksPlsThanksLmao',
    };

    // Make a GET request to the server
    final r = await http.get(
      Uri.parse('$url/books/$qrCode/$bookboxId'),
      headers: headers,
    );

    // Parse the response
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

  Future<Map<String, dynamic>> getBookBox(String bookBoxId) async {
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
      if (longitude != null) 'longitude': longitude.toString(),
      if (latitude != null) 'latitude': latitude.toString(),
    };

    final r = await http.get(
      Uri.https('lino-1.onrender.com', '/bookboxes/search', queryParams),
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
    final r = await http.delete(Uri.parse('$url/books/request/$requestId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });
    if (r.statusCode != 204 && r.statusCode != 200) {
      throw Exception(jsonDecode(r.body)['error']);
    }
  }

  Future<List<dynamic>> getBookRequests({String? username}) async {
    var queryParams = {
      if (username != null) 'username': username,
    };
    final r = await http.get(
      Uri.https('lino-1.onrender.com', '/books/requests', queryParams),
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
