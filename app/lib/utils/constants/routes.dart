class AppRoutes {
  // Root level routes
  static const String home = '/home';
  static const String search = '/search';
  static const String splash = '/';

  // Feature modules
  static const AuthRoutes auth = AuthRoutes('/auth');
  static const ForumRoutes forum = ForumRoutes('/forum');
  static const BookboxRoutes bookbox = BookboxRoutes('/bookbox');
  static const ProfileRoutes profile = ProfileRoutes('/profile');
  static const ScanRoutes scan = ScanRoutes('/scan');
}

class AuthRoutes {
  final String root;
  const AuthRoutes(this.root);

  String get login => '$root/login';
  String get register => '$root/register';
  OnboardingRoutes get onboarding => OnboardingRoutes('$root/onboarding');
}

class OnboardingRoutes {
  final String root;
  const OnboardingRoutes(this.root);

  String get favouriteGenres => '$root/favourite-genres';
  String get favouriteLocations => '$root/favourite-locations';
}

class ForumRoutes {
  final String root;
  const ForumRoutes(this.root);

  RequestRoutes get request => RequestRoutes('$root/request');
}

class RequestRoutes {
  final String root;
  const RequestRoutes(this.root);

  String get form => '$root/form';
  String get bookboxSelection => '$root/bookbox-selection';
}

class BookboxRoutes {
  final String root;
  const BookboxRoutes(this.root);

  String get main => root;
  String get reportIssue => '$root/report-issue';
  BookRoutes get book => BookRoutes('$root/book');
}

class BookRoutes {
  final String root;
  const BookRoutes(this.root);

  String get details => '$root/details';
  String get editAndAdd => '$root/edit-and-add';
  String get chooseFromList => '$root/choose-from-list';
  String get scanIsbn => '$root/scan-isbn';
  String get takeCoverPhoto => '$root/take-cover-photo';
}

class ProfileRoutes {
  final String root;
  const ProfileRoutes(this.root);

  String get main => root;
  String get modify => '$root/modify';
  String get favouriteGenres => '$root/favourite-genres';
  String get favouriteLocations => '$root/favourite-locations';
  String get setupNotifications => '$root/setup-notifications';
}

class ScanRoutes {
  final String root;
  const ScanRoutes(this.root);

  String get qrScanner => '$root/qr-scanner';
}


// Usage examples:
// Get.toNamed(AppRoutes.request.form);
// Get.toNamed(AppRoutes.bookbox.selection);
// Get.toNamed(AppRoutes.favouriteLocations.input);
// Get.toNamed(AppRoutes.splash); // Root routes work as before