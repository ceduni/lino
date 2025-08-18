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

enum RequestFilter {
  all('all'),
  notified('notified'),
  upvoted('upvoted'),
  mine('mine');

  const RequestFilter(this.value);
  final String value;
}

enum RequestSortBy {
  date('date'),
  upvoters('upvoters'),
  peopleNotified('peopleNotified');

  const RequestSortBy(this.value);
  final String value;
}

// Response models
class UpvoteResponse {
  final String message;
  final bool isUpvoted;
  final int upvoteCount;
  final Request request;

  UpvoteResponse({
    required this.message,
    required this.isUpvoted,
    required this.upvoteCount,
    required this.request,
  });

  factory UpvoteResponse.fromJson(Map<String, dynamic> json) {
    return UpvoteResponse(
      message: json['message'] as String,
      isUpvoted: json['isUpvoted'] as bool,
      upvoteCount: json['upvoteCount'] as int,
      request: Request.fromJson(json['request'] as Map<String, dynamic>),
    );
  }
}

class SolveResponse {
  final String message;
  final bool isSolved;

  SolveResponse({
    required this.message,
    required this.isSolved,
  });

  factory SolveResponse.fromJson(Map<String, dynamic> json) {
    return SolveResponse(
      message: json['message'] as String,
      isSolved: json['isSolved'] as bool,
    );
  }
}
