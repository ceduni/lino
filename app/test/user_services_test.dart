import 'package:Lino_app/services/user_services.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final userService = UserService();

  await clearCollections();

  group('UserService', () {
    test('registerUser returns a token if the user is registered', () async {
      final token = await userService.registerUser('testuser', 'test@test.com', '1234567890', 'password', true);
      expect(token, 'test_token');
    });

    test('loginUser returns a token if the user is logged in', () async {
      final token = await userService.loginUser('test@test.com', 'password');
      expect(token, 'test_token');
    });
  });
}

Future<void> clearCollections() async {
  await http.post(Uri.parse('http://localhost:3000/users/clear'));
  await http.post(Uri.parse('http://localhost:3000/books/clear'));
  await http.post(Uri.parse('http://localhost:3000/threads/clear'));
}