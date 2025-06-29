class User {
  final String username;
  final String password;
  final String email;
  final String? phone;
  final double requestNotificationRadius;
  final List<String> notificationKeyWords;
  final int numSavedBooks;
  final List<Notification> notifications;
  final List<String> followedBookboxes;
  final DateTime createdAt;

  User({
    required this.username,
    required this.password, 
    required this.email,
    this.phone,
    this.requestNotificationRadius = 5.0,
    required this.notificationKeyWords,
    this.numSavedBooks = 0,
    required this.notifications,
    required this.followedBookboxes,
    required this.createdAt,
  });

  // Calculate ecological impact based on numSavedBooks
  EcologicalImpact get ecologicalImpact {
    return EcologicalImpact(
      carbonSavings: numSavedBooks * 27.71,
      savedWater: numSavedBooks * 2000.0,
      savedTrees: numSavedBooks * 0.05,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    var notificationKeyWordsList = json['notificationKeyWords'] as List? ?? [];
    List<String> notificationKeyWords = notificationKeyWordsList.cast<String>();

    var notificationsList = json['notifications'] as List? ?? [];
    List<Notification> notifications = notificationsList.map((i) => Notification.fromJson(i)).toList();

    var followedBookboxesList = json['followedBookboxes'] as List? ?? [];
    List<String> followedBookboxes = followedBookboxesList.cast<String>();

    return User(
      username: json['username'],
      password: json['password'],
      email: json['email'],
      phone: json['phone'],
      requestNotificationRadius: (json['requestNotificationRadius'] ?? 5.0).toDouble(),
      notificationKeyWords: notificationKeyWords,
      numSavedBooks: json['numSavedBooks'] ?? 0,
      notifications: notifications,
      followedBookboxes: followedBookboxes,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 

class Notification {
  final DateTime timestamp;
  final String title;
  final String content;
  final bool read;

  Notification({required this.timestamp, required this.title, required this.content, required this.read});

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      timestamp: DateTime.parse(json['timestamp']),
      title: json['title'],
      content: json['content'],
      read: json['read'],
    );
  }
}

class EcologicalImpact {
  final double carbonSavings;
  final double savedWater;
  final double savedTrees;

  EcologicalImpact({required this.carbonSavings, required this.savedWater, required this.savedTrees});

  factory EcologicalImpact.fromJson(Map<String, dynamic> json) {
    return EcologicalImpact(
      carbonSavings: json['carbonSavings'].toDouble(),
      savedWater: json['savedWater'].toDouble(),
      savedTrees: json['savedTrees'].toDouble(),
    );
  }
}
