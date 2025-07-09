class User {
  final String username;
  final String password;
  final String email;
  final String? phone;
  final double requestNotificationRadius;
  final List<String> favouriteGenres;
  final int numSavedBooks;
  final List<String> followedBookboxes;
  final DateTime createdAt;

  User({
    required this.username,
    required this.password, 
    required this.email,
    this.phone,
    this.requestNotificationRadius = 5.0,
    required this.favouriteGenres,
    this.numSavedBooks = 0,
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
    var favouriteGenresList = json['favouriteGenres'] as List? ?? [];
    List<String> favouriteGenres = favouriteGenresList.cast<String>();

    var followedBookboxesList = json['followedBookboxes'] as List? ?? [];
    List<String> followedBookboxes = followedBookboxesList.cast<String>();

    return User(
      username: json['username'],
      password: json['password'],
      email: json['email'],
      phone: json['phone'],
      requestNotificationRadius: (json['requestNotificationRadius'] ?? 5.0).toDouble(),
      favouriteGenres: favouriteGenres,
      numSavedBooks: json['numSavedBooks'] ?? 0,
      followedBookboxes: followedBookboxes,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 

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
