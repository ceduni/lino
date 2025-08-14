// app/lib/vm/register_view_model.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/services/user_services.dart';

class RegisterViewModel extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _obscureText = true;

  bool get isLoading => _isLoading;
  bool get obscureText => _obscureText;

  Future<String?> register(SharedPreferences prefs) async {
    final username = usernameController.text;
    final email = emailController.text;

    if (username.length < 3 || username.length > 16) {
      _showError('Username must be between 3 and 16 characters long.');
      return null;
    }

    if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(username)) {
      _showError('Username can only contain letters and numbers.');
      return null;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address.');
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _userService.registerUser(
        usernameController.text,
        emailController.text,
        passwordController.text,
        phone: phoneController.text,
      );
      await prefs.setString('token', token);
      return token;
    } catch (e) {
      showToast('Error registering user: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _showError(String message) {
    showToast(message);
  }

  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}