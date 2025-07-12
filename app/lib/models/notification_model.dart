class Notification {
  final String userId;
  final String? bookId;
  final String? bookTitle;
  final String? bookboxId;
  final List<String> reason;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.userId,
    this.bookId,
    this.bookTitle,
    this.bookboxId,
    required this.reason,
    this.isRead = false,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) { 
    return Notification(
      userId: json['userId'],
      bookId: json['bookId'],
      bookTitle: json['bookTitle'],
      bookboxId: json['bookboxId'],
      reason: List<String>.from(json['reason'] ?? []),
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}