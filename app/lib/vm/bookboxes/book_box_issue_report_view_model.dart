// app/lib/vm/book_box_issue_report_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/services/issue_services.dart';
import 'package:Lino_app/services/user_services.dart';

class BookBoxIssueReportViewModel extends ChangeNotifier {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isEmailLocked = false;

  TextEditingController get subjectController => _subjectController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get emailController => _emailController;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isEmailLocked => _isEmailLocked;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> checkUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final user = await UserService().getUser(token);
        _isLoggedIn = true;
        _emailController.text = user.email;
        _isEmailLocked = true;
      } else {
        _isLoggedIn = false;
        _isEmailLocked = false;
      }
    } catch (e) {
      _isLoggedIn = false;
      _isEmailLocked = false;
    }
    notifyListeners();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<Map<String, dynamic>> submitIssue(String bookboxId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      await IssueServices().reportIssue(
        bookboxId,
        _subjectController.text.trim(),
        _descriptionController.text.trim(),
        token: token,
        email: _isLoggedIn ? null : _emailController.text.trim(),
      );

      return {'success': true, 'message': 'Issue reported successfully'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}