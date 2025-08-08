class Request {
  final String id;
  final String username;
  final String bookTitle;
  final DateTime timestamp;
  final String? customMessage;

  Request({
    required this.id,
    required this.username,
    required this.bookTitle,
    required this.timestamp,
    this.customMessage,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['_id'],
      username: json['username'],
      bookTitle: json['bookTitle'],
      timestamp: DateTime.parse(json['timestamp']),
      customMessage: json['customMessage'],
    );
  }
}