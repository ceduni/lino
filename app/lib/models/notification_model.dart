class Notif {
  final String id;
  final String userId;
  final String? bookId;
  final String bookTitle;
  final String? bookboxId;
  final List<String> reason;
  final bool isRead;
  final DateTime createdAt;

  Notif({
    required this.id,
    required this.userId,
    this.bookId,
    required this.bookTitle,
    this.bookboxId,
    required this.reason,
    this.isRead = false,
    required this.createdAt,
  });

  factory Notif.fromJson(Map<String, dynamic> json) { 
    return Notif(
      id: json['_id'],
      userId: json['userId'],
      bookId: json['bookId'],
      bookTitle: json['bookTitle'],
      bookboxId: json['bookboxId'],
      reason: List<String>.from(json['reason'] ?? []),
      isRead: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}