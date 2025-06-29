import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants/api_constants.dart';

class UserService {
  final String url = baseApiUrl;


  Future<String> registerUser(String username, String email, String password, {String phone = '', bool getAlerted = true}) async {
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

  Future<void> markNotificationAsRead(String token, String id) async {
    final response = await http.post(
        Uri.parse('$url/users/notifications/read'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'notificationId': id,
        }));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      print(data);
      throw Exception(data['error']);
    }
  }
}
