// app/lib/vm/appbar_view_model.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/services/websocket_service.dart';
import 'package:Lino_app/utils/constants/api_constants.dart';
import 'package:Lino_app/views/profile/notifications_page.dart';

class AppBarViewModel extends ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();

  bool _isLoggedIn = false;
  bool _isLoading = true;
  int _unreadCount = 0;
  User? _user;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;
  User? get user => _user;
  String? get error => _error;

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _checkUserLoginStatus();
      if (_isLoggedIn) {
        await _fetchUnreadCount();
        _initializeWebSocket();
      }
    } catch (e) {
      _error = e.toString();
      print('Error initializing AppBar: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _checkUserLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _isLoggedIn = false;
      _user = null;
      return;
    }

    try {
      final userService = UserService();
      _user = await userService.getUser(token);
      _isLoggedIn = true;
    } catch (e) {
      print('Error checking user login status: $e');
      _isLoggedIn = false;
      _user = null;
    }
  }

  void _initializeWebSocket() {
    if (_user != null) {
      _webSocketService.connect(
        webSocketUrl,
        userId: _user!.id,
        onEvent: (event, data) async {
          if (event == 'newNotification') {
            await _fetchAndUpdateUnreadCount();
          }
        },
      );
    }
  }

  Future<void> _fetchAndUpdateUnreadCount() async {
    final newUnreadCount = await _fetchUnreadCount();
    _unreadCount = newUnreadCount;
    notifyListeners();
  }

  Future<int> _fetchUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('No token found');
      return 0;
    }

    try {
      final userService = UserService();
      final notifications = await userService.getUserNotifications(token);
      final count = notifications.where((n) => !n.isRead).length;
      print('Unread count from service: $count');
      return count;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  void navigateToNotifications() {
    Get.to(() => NotificationsPage());
  }

  void navigateToLogin() {
    Get.offAllNamed('/login');
  }
}
