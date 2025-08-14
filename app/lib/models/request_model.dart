class Request {
  final String id;
  final String username;
  final String bookTitle;
  final DateTime timestamp;
  final String? customMessage;
  final List<String> upvoters;
  final int nbPeopleNotified;
  final List<String> bookboxIds;
  final bool isSolved;

  Request({
    required this.id,
    required this.username,
    required this.bookTitle,
    required this.timestamp,
    this.customMessage,
    required this.upvoters,
    required this.nbPeopleNotified,
    required this.bookboxIds,
    required this.isSolved,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['_id'],
      username: json['username'],
      bookTitle: json['bookTitle'],
      timestamp: DateTime.parse(json['timestamp']),
      customMessage: json['customMessage'],
      upvoters: List<String>.from(json['upvoters'] ?? []),
      nbPeopleNotified: json['nbPeopleNotified'] ?? 0,
      bookboxIds: List<String>.from(json['bookboxIds'] ?? []),
      isSolved: json['isSolved'] ?? false,
    );
  }

  // Helper methods
  int get upvoteCount => upvoters.length;
  
  bool isUpvotedBy(String username) => upvoters.contains(username);
  
  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'bookTitle': bookTitle,
      'timestamp': timestamp.toIso8601String(),
      'customMessage': customMessage,
      'upvoters': upvoters,
      'nbPeopleNotified': nbPeopleNotified,
      'bookboxIds': bookboxIds,
      'isSolved': isSolved,
    };
  }
}
