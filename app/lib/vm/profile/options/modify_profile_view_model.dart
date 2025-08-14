// app/lib/vm/modify_profile_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Lino_app/services/user_services.dart';

class ModifyProfileViewModel extends ChangeNotifier {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  late String _token;
  bool _isLoading = true;
  bool _obscureText = true;

  bool get isLoading => _isLoading;
  bool get obscureText => _obscureText;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token')!;
    final userService = UserService();
    final user = await userService.getUser(_token);

    usernameController = TextEditingController(text: user.username);
    passwordController = TextEditingController(text: '');
    emailController = TextEditingController(text: user.email);
    phoneController = TextEditingController(text: user.phone ?? '');

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUser() async {
    final userService = UserService();
    try {
      await userService.updateUser(
        _token,
        username: usernameController.text,
        password: passwordController.text.isEmpty ? null : passwordController.text,
        email: emailController.text,
        phone: phoneController.text,
      );
      showToast('Profile updated successfully');
      return true;
    } catch (e) {
      showToast('Failed to update profile');
      print('Failed to update profile: $e');
      return false;
    }
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

  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}