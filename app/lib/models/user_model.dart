class User {
  final String username;
  final String password;
  final String email;
  final String? phone;
  final List<String> favoriteBooks;
  final List<String> trackedBooks;
  final List<String> notificationKeyWords;
  final EcologicalImpact ecologicalImpact;
  final List<Notification> notifications;
  final bool getAlerted;

  User({
    required this.username,
    required this.password,
    required this.email,
    this.phone,
    required this.favoriteBooks,
    required this.trackedBooks,
    required this.notificationKeyWords,
    required this.ecologicalImpact,
    required this.notifications,
    required this.getAlerted,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var favoriteBooksList = json['favoriteBooks'] as List;
    List<String> favoriteBooks = favoriteBooksList.cast<String>();

    var trackedBooksList = json['trackedBooks'] as List;
    List<String> trackedBooks = trackedBooksList.cast<String>();

    var notificationKeyWordsList = json['notificationKeyWords'] as List;
    List<String> notificationKeyWords = notificationKeyWordsList.cast<String>();

    var notificationsList = json['notifications'] as List;
    List<Notification> notifications = notificationsList.map((i) => Notification.fromJson(i)).toList();

    return User(
      username: json['username'],
      password: json['password'],
      email: json['email'],
      phone: json['phone'],
      favoriteBooks: favoriteBooks,
      trackedBooks: trackedBooks,
      notificationKeyWords: notificationKeyWords,
      ecologicalImpact: EcologicalImpact.fromJson(json['ecologicalImpact']),
      notifications: notifications,
      getAlerted: json['getAlerted'],
    );
  }
}

class Notification {
  final DateTime timestamp;
  final String content;
  final bool read;

  Notification({required this.timestamp, required this.content, required this.read});

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      timestamp: DateTime.parse(json['timestamp']),
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

