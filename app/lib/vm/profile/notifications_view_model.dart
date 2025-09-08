// app/lib/vm/profile/notifications_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/models/notification_model.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/services/bookbox_services.dart';

class NotificationsViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final BookboxService _bookboxService = BookboxService();

  List<Notif> _notifications = [];
  bool _isLoading = false;
  String? _error;
  String? _token;

  List<Notif> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;


  Future<void> initialize() async {
    await _loadToken();
    await fetchNotifications();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token == null) {
      _error = 'No authentication token found';
      notifyListeners();
    }
  }

  Future<void> fetchNotifications() async {
    if (_token == null) {
      _error = 'No authentication token available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _userService.getUserNotifications(_token!);
      
      //_notifications = _notifications.reversed.toList();
    } catch (e) {
      _error = 'Error loading notifications: $e';
      print('Error fetching notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    if (_token == null) return;

    try {
      await _userService.markNotificationAsRead(_token!, id);
      
      // Refresh the entire list to get updated read status
      await fetchNotifications();
    } catch (e) {
      _error = 'Error marking notification as read: $e';
      print('Error marking notification as read: $e');
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
      
      for (var notification in unreadNotifications) {
        await _userService.markNotificationAsRead(_token!, notification.id);
      }
      
      // Refresh the notifications list
      await fetchNotifications();
    } catch (e) {
      _error = 'Error marking all notifications as read: $e';
      print('Error marking all notifications as read: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  String getNotificationTitle(Notif notification) {
    final List<String> reasons = notification.reason;
    if (reasons.isEmpty) {
      return 'Notification';
    }
    if (reasons.contains('book_request')) {
      return 'Book Request';
    } else {
      return 'New Book Available';
    }
  }

  String getNotificationPreview(Notif notification) {
    final List<String> reasons = notification.reason;
    final String bookTitle = notification.bookTitle;
    if (reasons.isEmpty) {
      return 'No specific reason provided for this notification.';
    }
    if (reasons.contains('book_request')) {
      return 'Someone is looking for "$bookTitle"';
    } else {
      return '"$bookTitle" is now available';
    }
  }

  Future<String> getBookboxName(String? bookboxId) async {
    if (bookboxId == null || bookboxId.isEmpty) {
      return 'a book box';
    }
    
    try {
      final bookboxData = await _bookboxService.getBookBox(bookboxId);
      return bookboxData.name;
    } catch (e) {
      return 'a book box';
    }
  }

  Future<String> buildNotificationContent(Notif notification) async {
    final List<String> reasons = notification.reason;
    final String bookTitle = notification.bookTitle;
    final String? bookboxId = notification.bookboxId;
    
    if (reasons.contains('book_request')) {
      return 'Someone is looking for "$bookTitle". If you have this book, please consider adding it to the nearest book box to help out!';
    } else {
      final String bookboxName = await getBookboxName(bookboxId);
      List<String> reasonMessages = [];
      
      if (reasons.contains('fav_bookbox')) {
        reasonMessages.add('it was added to "$bookboxName", a book box you follow');
      }
      if (reasons.contains('same_borough')) {
        reasonMessages.add('it was added to "$bookboxName", a book box near you');
      }
      if (reasons.contains('fav_genre')) {
        reasonMessages.add('it matches one of your favorite genres');
      }
      if (reasons.contains('solved_book_request')) {
        reasonMessages.add('it matches a book request you made');
      }
      
      String reasonText;
      if (reasonMessages.length == 1) {
        reasonText = reasonMessages[0];
      } else if (reasonMessages.length == 2) {
        reasonText = '${reasonMessages[0]} and ${reasonMessages[1]}';
      } else {
        reasonText = '${reasonMessages.sublist(0, reasonMessages.length - 1).join(', ')}, and ${reasonMessages.last}';
      }
      
      return 'Good news! "$bookTitle" is now available because $reasonText.';
    }
  }

  String buildNotificationContentSync(Notif notification) {
    final List<String> reasons = notification.reason;
    final String bookTitle = notification.bookTitle;

    if (reasons.contains('book_request')) {
      return 'Someone is looking for "$bookTitle". If you have this book, please consider adding it to the nearest book box to help out!';
    } else {
      List<String> reasonMessages = [];
      
      if (reasons.contains('fav_bookbox')) {
        reasonMessages.add('it was added to a book box you follow');
      }
      if (reasons.contains('same_borough')) {
        reasonMessages.add('it was added to a book box near you');
      }
      if (reasons.contains('fav_genre')) {
        reasonMessages.add('it matches one of your favorite genres');
      }
      if (reasons.contains('solved_book_request')) {
        reasonMessages.add('it matches a book request you made');
      }
      
      String reasonText;
      if (reasonMessages.length == 1) {
        reasonText = reasonMessages[0];
      } else if (reasonMessages.length == 2) {
        reasonText = '${reasonMessages[0]} and ${reasonMessages[1]}';
      } else {
        reasonText = '${reasonMessages.sublist(0, reasonMessages.length - 1).join(', ')}, and ${reasonMessages.last}';
      }
      
      return 'Good news! "$bookTitle" is now available because $reasonText.';
    }
  }

  Future<void> onNotificationTap(Notif notification) async {
    if (!notification.isRead) {
      await markAsRead(notification.id);
    }
  }
}
