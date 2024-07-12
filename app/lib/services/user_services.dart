import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String url = 'https://lino-1.onrender.com';


  Future<String> registerUser(String username, String email, String phone, String password, bool getAlerted) async {
    // Make a POST request to the server
    // Send the username, email, phone, password, and getAlerted to the server
    // If the server returns a 201 status code, the user is registered
    // If the server returns another status code, the user is not registered
    final userData = await http.post(
      Uri.parse('$url/users/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'getAlerted': getAlerted,
      }),
    );
    final data = jsonDecode(userData.body);
    if (userData.statusCode != 201) {
      throw Exception(data['error']);
    }
    final token = await loginUser(username, password);
    return token;
  }

  Future<String> loginUser(String identifier, String password) async {
    // Make a POST request to the server
    // Send the email and password to the server
    // If the server returns a 200 status code, the user is logged in
    // If the server returns another status code, the user is not logged in
    final r = await http.post(
      Uri.parse('$url/users/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'identifier': identifier,
        'password': password,
      }),
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    final token = response['token'];
    return token;
  }

  Future<List<String>> addToFavorites(String token, String id) async {
    // Make a POST request to the server
    // Send the token and id to the server
    // If the server returns a 200 status code, the id is added to the user's favorites
    // If the server returns another status code, the id is not added to the user's favorites
    final r = await http.post(
      Uri.parse('$url/users/favorites'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'bookId': id,
      }),
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    final data = response['favorites'];
    return List<String>.from(data);
  }

  Future<List<String>> removeFromFavorites(String token, String id) async {
    // Make a DELETE request to the server
    // Send the token and id to the server
    // If the server returns a 200 status code, the id is removed from the user's favorites
    // If the server returns another status code, the id is not removed from the user's favorites
    final r = await http.delete(
      Uri.parse('$url/users/favorites/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    final data = response['favorites'];
    return List<String>.from(data);
  }

  Future<Map<String, dynamic>> getUser(String token) async {
    // Make a GET request to the server
    // Send the token to the server
    // If the server returns a 200 status code, the user is returned
    // If the server returns another status code, the user is not returned
    final response = await http.get(
      Uri.parse('$url/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }
    return data;
  }

  Future<Map<String, dynamic>> updateUser(String token, {String? username, String? password, String? email, String? phone, bool? getAlerted, String? keyWords}) async {
    // Make a PUT request to the server
    // Send the token and the updated user information to the server
    // If the server returns a 200 status code, the user is updated
    // If the server returns another status code, the user is not updated
    final response = await http.post(
      Uri.parse('$url/users/update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'password': password,
        'email': email,
        'phone': phone,
        'getAlerted': getAlerted,
        'keyWords': keyWords,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }
    return data;
  }

  Future<Map<String, dynamic>> getUserNotifications(String token) async {
    final response = await http.get(
      Uri.parse('$url/users/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }
    return data;
  }
}