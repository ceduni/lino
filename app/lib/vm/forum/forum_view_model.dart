// app/lib/vm/forum/forum_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForumViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isConnected = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get error => _error;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initialize() async {
    await checkConnection();
  }

  Future<void> checkConnection() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isConnected = prefs.containsKey('token');
      _error = null;
    } catch (e) {
      _error = 'Error checking connection: ${e.toString()}';
      _isConnected = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await checkConnection();
  }
}
