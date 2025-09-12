// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navRequests => 'Requests';

  @override
  String get navProfile => 'Profile';

  @override
  String get navLogIn => 'Log In';

  @override
  String get homeNotificationsEmpty => 'No notifications yet';

  @override
  String get homeRecentNotifications => 'Recent Notifications';

  @override
  String get welcomeLoggedOut => 'Welcome !';

  @override
  String get msgLoggedOut =>
      'You\'re browsing as a guest. Log in to unlock personalized features and start tracking your reading journey!';

  @override
  String get emailorusername => 'Email or Username';

  @override
  String get password => 'Password';

  @override
  String get donthaveaccount => 'Don\'t have an account? ';

  @override
  String get register => 'Register here';

  @override
  String get continueasguest => 'Continue as a guest';

  @override
  String get username => 'Username';

  @override
  String get phoneNumber => 'Phone (optional)';

  @override
  String get registerbtn => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';
}
