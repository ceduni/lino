// app/lib/vm/profile/notifications_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/l10n/app_localizations.dart';
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


  Future<void> initialize([AppLocalizations? localizations]) async {
    await _loadToken(localizations);
    await fetchNotifications(localizations);
  }

  Future<void> _loadToken([AppLocalizations? localizations]) async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token == null) {
      _error = localizations?.noAuthenticationToken ?? 'No authentication token found';
      notifyListeners();
    }
  }

  Future<void> fetchNotifications([AppLocalizations? localizations]) async {
    if (_token == null) {
      _error = localizations?.noAuthenticationTokenAvailable ?? 'No authentication token available';
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
      _error = localizations?.errorLoadingNotifications ?? 'Error loading notifications: $e';
      print('Error fetching notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id, [AppLocalizations? localizations]) async {
    if (_token == null) return;

    try {
      await _userService.markNotificationAsRead(_token!, id);
      
      // Refresh the entire list to get updated read status
      await fetchNotifications(localizations);
    } catch (e) {
      _error = localizations?.errorMarkingNotificationAsRead ?? 'Error marking notification as read: $e';
      print('Error marking notification as read: $e');
      notifyListeners();
    }
  }

  Future<void> markAllAsRead([AppLocalizations? localizations]) async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
      
      for (var notification in unreadNotifications) {
        await _userService.markNotificationAsRead(_token!, notification.id);
      }
      
      // Refresh the notifications list
      await fetchNotifications(localizations);
    } catch (e) {
      _error = localizations?.errorMarkingAllNotificationsAsRead ?? 'Error marking all notifications as read: $e';
      print('Error marking all notifications as read: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  String getNotificationTitle(Notif notification, [AppLocalizations? localizations]) {
    final List<String> reasons = notification.reason;
    if (reasons.isEmpty) {
      return localizations?.notification ?? 'Notification';
    }
    if (reasons.contains('book_request')) {
      return localizations?.bookRequest ?? 'Book Request';
    } else {
      return localizations?.newBookAvailable ?? 'New Book Available';
    }
  }

  String getNotificationPreview(Notif notification, [AppLocalizations? localizations]) {
    final List<String> reasons = notification.reason;
    final String bookTitle = notification.bookTitle;
    if (reasons.isEmpty) {
      return localizations?.noSpecificReasonProvided ?? 'No specific reason provided for this notification.';
    }
    if (reasons.contains('book_request')) {
      return localizations?.someoneIsLookingForBook(bookTitle) ?? 'Someone is looking for "$bookTitle"';
    } else {
      return localizations?.bookIsNowAvailable(bookTitle) ?? '"$bookTitle" is now available';
    }
  }

  Future<String> getBookboxName(String? bookboxId, [AppLocalizations? localizations]) async {
    if (bookboxId == null || bookboxId.isEmpty) {
      return localizations?.aBookBox ?? 'a book box';
    }
    
    try {
      final bookboxData = await _bookboxService.getBookBox(bookboxId);
      return bookboxData.name;
    } catch (e) {
      return localizations?.aBookBox ?? 'a book box';
    }
  }

  Future<String> buildNotificationContent(Notif notification, [AppLocalizations? localizations]) async {
    final List<String> reasons = notification.reason;
    final String bookTitle = notification.bookTitle;
    final String? bookboxId = notification.bookboxId;
    
    if (reasons.contains('book_request')) {
      return localizations?.bookRequestContent(bookTitle) ?? 
             'Someone is looking for "$bookTitle". If you have this book, please consider adding it to the nearest book box to help out!';
    } else {
      final String bookboxName = await getBookboxName(bookboxId, localizations);
      List<String> reasonMessages = [];
      
      if (reasons.contains('fav_bookbox')) {
        final message = localizations?.addedToFollowedBookbox(bookboxName) ??
                       'it was added to "$bookboxName", a book box you follow';
        reasonMessages.add(message);
      }
      if (reasons.contains('same_borough')) {
        final message = localizations?.addedToNearbyBookbox(bookboxName) ??
                       'it was added to "$bookboxName", a book box near you';
        reasonMessages.add(message);
      }
      if (reasons.contains('fav_genre')) {
        reasonMessages.add(localizations?.matchesFavoriteGenre ?? 'it matches one of your favorite genres');
      }
      if (reasons.contains('solved_book_request')) {
        reasonMessages.add(localizations?.matchesBookRequest ?? 'it matches a book request you made');
      }
      
      String reasonText;
      if (reasonMessages.length == 1) {
        reasonText = reasonMessages[0];
      } else if (reasonMessages.length == 2) {
        reasonText = '${reasonMessages[0]} ${localizations?.andConjunction ?? 'and'} ${reasonMessages[1]}';
      } else {
        final lastReason = reasonMessages.last;
        final otherReasons = reasonMessages.sublist(0, reasonMessages.length - 1).join(', ');
        reasonText = '$otherReasons, ${localizations?.andConjunction ?? 'and'} $lastReason';
      }
      
      return localizations?.goodNewsBookAvailable(bookTitle, reasonText) ??
             'Good news! "$bookTitle" is now available because $reasonText.';
    }
  }

  String buildNotificationContentSync(Notif notification, [AppLocalizations? localizations]) {
    final List<String> reasons = notification.reason;
    final String bookTitle = notification.bookTitle;

    if (reasons.contains('book_request')) {
      return localizations?.bookRequestContent(bookTitle) ?? 
             'Someone is looking for "$bookTitle". If you have this book, please consider adding it to the nearest book box to help out!';
    } else {
      List<String> reasonMessages = [];
      
      if (reasons.contains('fav_bookbox')) {
        reasonMessages.add(localizations?.addedToFollowedBookboxSync ?? 'it was added to a book box you follow');
      }
      if (reasons.contains('same_borough')) {
        reasonMessages.add(localizations?.addedToNearbyBookboxSync ?? 'it was added to a book box near you');
      }
      if (reasons.contains('fav_genre')) {
        reasonMessages.add(localizations?.matchesFavoriteGenre ?? 'it matches one of your favorite genres');
      }
      if (reasons.contains('solved_book_request')) {
        reasonMessages.add(localizations?.matchesBookRequest ?? 'it matches a book request you made');
      }
      
      String reasonText;
      if (reasonMessages.length == 1) {
        reasonText = reasonMessages[0];
      } else if (reasonMessages.length == 2) {
        reasonText = '${reasonMessages[0]} ${localizations?.andConjunction ?? 'and'} ${reasonMessages[1]}';
      } else {
        final lastReason = reasonMessages.last;
        final otherReasons = reasonMessages.sublist(0, reasonMessages.length - 1).join(', ');
        reasonText = '$otherReasons, ${localizations?.andConjunction ?? 'and'} $lastReason';
      }
      
      return localizations?.goodNewsBookAvailable(bookTitle, reasonText) ??
             'Good news! "$bookTitle" is now available because $reasonText.';
    }
  }

  Future<void> onNotificationTap(Notif notification, [AppLocalizations? localizations]) async {
    if (!notification.isRead) {
      await markAsRead(notification.id, localizations);
    }
  }
}
