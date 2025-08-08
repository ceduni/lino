class User {
  final String id;
  final String username;
  final String email;
  final String? phone; 
  final List<String> favouriteGenres;
  final int numSavedBooks;
  final List<String> followedBookboxes;
  final List<FavouriteLocation> favouriteLocations;
  final DateTime createdAt;
  final int numIssuesReported; 
  final UserNotificationSettings notificationSettings;
  final bool isAdmin; 

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    required this.favouriteGenres,
    this.numSavedBooks = 0,
    required this.followedBookboxes,
    required this.favouriteLocations,
    required this.createdAt,
    required this.notificationSettings,
    this.numIssuesReported = 0, 
    required this.isAdmin,
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

    var favouriteLocationsList = json['favouriteLocations'] as List? ?? [];
    List<FavouriteLocation> favouriteLocations = favouriteLocationsList
        .map((location) => FavouriteLocation.fromJson(location))
        .toList();

    UserNotificationSettings notificationSettings = UserNotificationSettings
        .fromJson(json['notificationSettings'] ?? {});

    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      favouriteGenres: favouriteGenres,
      numSavedBooks: json['numSavedBooks'] ?? 0,
      followedBookboxes: followedBookboxes,
      favouriteLocations: favouriteLocations,
      createdAt: DateTime.parse(json['createdAt']),
      notificationSettings: notificationSettings,
      numIssuesReported: json['numIssuesReported'] ?? 0,
      isAdmin: json['isAdmin'] ?? false, 
    );
  }
} 

class FavouriteLocation {
  final double latitude;
  final double longitude;
  final String name; // Name of the location
  final String boroughId;

  FavouriteLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.boroughId,
  });

  factory FavouriteLocation.fromJson(Map<String, dynamic> json) {
    return FavouriteLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String? ?? 'Unknown Location',
      boroughId: json['boroughId'] as String? ?? '',
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

class UserNotificationSettings {
  final bool addedBook;
  final bool bookRequested;

  UserNotificationSettings({
    this.addedBook = true,
    this.bookRequested = true,
  });

  factory UserNotificationSettings.fromJson(Map<String, dynamic> json) {
    return UserNotificationSettings(
      addedBook: json['addedBook'] ?? true,
      bookRequested: json['bookRequested'] ?? true,
    );
  }
}