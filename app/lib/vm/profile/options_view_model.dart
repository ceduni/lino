// app/lib/vm/options_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/services/user_services.dart';

class OptionsViewModel extends ChangeNotifier {
  bool _isLoading = true;
  bool _addedBookNotifications = true;
  bool _bookRequestedNotifications = true;
  String? _token;
  final UserService _userService = UserService();

  bool get isLoading => _isLoading;
  bool get addedBookNotifications => _addedBookNotifications;
  bool get bookRequestedNotifications => _bookRequestedNotifications;

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token != null) {
        final user = await _userService.getUser(_token!);
        _addedBookNotifications = user.notificationSettings.addedBook;
        _bookRequestedNotifications = user.notificationSettings.bookRequested;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleNotification(String type) async {
    if (_token == null) return false;

    try {
      await _userService.toggleReceivedNotificationType(_token!, type);

      if (type == 'addedBook') {
        _addedBookNotifications = !_addedBookNotifications;
      } else if (type == 'bookRequested') {
        _bookRequestedNotifications = !_bookRequestedNotifications;
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('Error toggling notification: $e');
      return false;
    }
  }
}