import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000'; // Replace with your server's IP and port

  Future<http.Response> getThreads(String bookId) async {
    if (await isTokenExpired()) {
    await refreshToken();
    }
    return http.get(Uri.parse('$baseUrl/threads/$bookId'));
  }

  Future<http.Response> createThread(String bookId, String title, String token) async {
    if (await isTokenExpired()) {
    await refreshToken();
    }
    return http.post(
      Uri.parse('$baseUrl/threads'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'book_id': bookId,
        'title': title,
      }),
    );
  }

  Future<http.Response> createMessage(String threadId, String content, String token) async {
    if (await isTokenExpired()) {
    await refreshToken();
    }
    return http.post(
      Uri.parse('$baseUrl/threads/$threadId/messages'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'content': content,
      }),
    );
  }

  Future<http.Response> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('refreshToken', data['refreshToken']);
    }

    return response;
  }

  Future<http.Response> registerUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register user');
    }

    // Call loginUser function to get token and refreshToken
    final loginResponse = await loginUser(username, password);

    return loginResponse;
  }

  Future<http.Response> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    final response = await http.post(
      Uri.parse('$baseUrl/user/refresh-token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'refreshToken': refreshToken.toString(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await prefs.setString('token', data['token']);
    }

    return response;
  }

  Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = prefs.getString('expiryDate');

    if (expiryDate == null) {
      return true;
    }

    return DateTime.now().isAfter(DateTime.parse(expiryDate));
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
  }

  Future<http.Response> getBooks() async {
    if (await isTokenExpired()) {
    await refreshToken();
    }
    return http.get(Uri.parse('$baseUrl/books'));
  }

  Future<http.Response> getBook(String bookId) async {
    if (await isTokenExpired()) {
    await refreshToken();
    }
    return http.get(Uri.parse('$baseUrl/books/$bookId'));
  }

  Future<http.Response> addBook(String isbn, String bookboxId, String token) async {
    return http.post(
      Uri.parse('$baseUrl/book/$isbn/$bookboxId/given'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
  }
}

