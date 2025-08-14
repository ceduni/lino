// app/lib/vm/login_view_model.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/services/user_services.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _obscureText = true;

  bool get isLoading => _isLoading;
  bool get obscureText => _obscureText;

  Future<bool> login(SharedPreferences prefs) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _userService.loginUser(
        identifierController.text,
        passwordController.text,
      );
      await prefs.setString('token', token);
      return true;
    } catch (e) {
      showToast('Invalid username or password.');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openAsGuest(SharedPreferences prefs) async {
    await prefs.remove('token');
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
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}