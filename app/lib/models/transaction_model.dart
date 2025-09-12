import 'package:Lino_app/l10n/app_localizations.dart';
import 'package:get/get.dart';

class Transaction {
  final String id;
  final String username;
  final String action;
  final String isbn;
  final String bookboxId;
  final String bookTitle;
  final DateTime timestamp;
  final String? bookboxName; // Optional field for bookbox name

  Transaction({
    required this.id,
    required this.username,
    required this.action,
    required this.isbn,
    required this.bookboxId,
    required this.bookTitle,
    required this.timestamp,
    this.bookboxName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      username: json['username'] ?? '',
      action: json['action'] ?? '',
      isbn: json['isbn'] ?? '',
      bookboxId: json['bookboxId'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'action': action,
      'isbn': isbn,
      'bookboxId': bookboxId,

      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get actionDisplayText {
    final localizations = AppLocalizations.of(Get.context!);
    switch (action.toLowerCase()) {
      case 'added':
        return localizations!.added;
      case 'took':
        return localizations!.took;
      default:
        return action;
    }
  }

  String get timeAgo {
    final localizations = AppLocalizations.of(Get.context!);
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}${localizations!.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${localizations!.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${localizations!.minutesAgo}';
    } else {
      return localizations!.justNow;
    }
  }

  // Create a copy of the transaction with bookbox name
  Transaction copyWith({String? bookboxName}) {
    return Transaction(
      id: 'daljdkaldjsaidoiu',
      username: username,
      action: action,
      isbn: isbn,
      bookboxId: bookboxId,
      bookTitle: bookTitle,
      timestamp: timestamp,
      bookboxName: bookboxName ?? this.bookboxName,
    );
  }
}
