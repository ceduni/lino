// app/lib/vm/book_box_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/services/bookbox_services.dart';

class BookBoxViewModel extends ChangeNotifier {
  BookBox? _bookBox;
  bool _isLoading = false;
  String? _error;
  bool _isFollowed = false;
  bool _isCheckingFollowStatus = false;
  String? _token;

  BookBox? get bookBox => _bookBox;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFollowed => _isFollowed;
  bool get isCheckingFollowStatus => _isCheckingFollowStatus;
  String? get token => _token;

  Future<void> loadBookBoxData(String bookBoxId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookBox = await BookboxService().getBookBox(bookBoxId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _bookBox = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkAuthAndFollowStatus(String bookBoxId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token != null) {
        _isCheckingFollowStatus = true;
        notifyListeners();

        _isFollowed = await BookboxService().isBookboxFollowed(_token!, bookBoxId);

        _isCheckingFollowStatus = false;
        notifyListeners();
      }
    } catch (e) {
      _isCheckingFollowStatus = false;
      notifyListeners();
      print('Error checking follow status: $e');
    }
  }

  Future<bool> toggleFollow(String bookBoxId) async {
    if (_token == null) return false;

    try {
      if (_isFollowed) {
        await BookboxService().unfollowBookBox(_token!, bookBoxId);
      } else {
        await BookboxService().followBookBox(_token!, bookBoxId);
      }

      _isFollowed = !_isFollowed;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error toggling follow: $e');
      return false;
    }
  }

  void refreshData(String bookBoxId) {
    loadBookBoxData(bookBoxId);
  }
}