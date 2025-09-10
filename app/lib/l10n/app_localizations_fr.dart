// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navHome => 'Accueil';

  @override
  String get navSearch => 'Rechercher';

  @override
  String get navRequests => 'Requêtes';

  @override
  String get navProfile => 'Profil';

  @override
  String get navLogIn => 'Se connecter';

  @override
  String get homeNotificationsEmpty => 'Aucune notification pour le moment';

  @override
  String get homeRecentNotifications => 'Notifications récentes';
}
