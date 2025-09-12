import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get navLogIn;

  /// No description provided for @homeNotificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get homeNotificationsEmpty;

  /// No description provided for @homeRecentNotifications.
  ///
  /// In en, this message translates to:
  /// **'Recent Notifications'**
  String get homeRecentNotifications;

  /// No description provided for @welcomeLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Welcome !'**
  String get welcomeLoggedOut;

  /// No description provided for @msgLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'You\'re browsing as a guest. Log in to unlock personalized features and start tracking your reading journey!'**
  String get msgLoggedOut;

  /// No description provided for @emailorusername.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get emailorusername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @donthaveaccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get donthaveaccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register here'**
  String get register;

  /// No description provided for @continueasguest.
  ///
  /// In en, this message translates to:
  /// **'Continue as a guest'**
  String get continueasguest;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneNumber;

  /// No description provided for @registerbtn.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerbtn;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @trees.
  ///
  /// In en, this message translates to:
  /// **'Trees'**
  String get trees;

  /// No description provided for @viewall.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewall;

  /// No description provided for @bookboxes.
  ///
  /// In en, this message translates to:
  /// **'Bookboxes'**
  String get bookboxes;

  /// No description provided for @noBookboxesFound.
  ///
  /// In en, this message translates to:
  /// **'No bookboxes found'**
  String get noBookboxesFound;

  /// No description provided for @noBooksFound.
  ///
  /// In en, this message translates to:
  /// **'No books found'**
  String get noBooksFound;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort '**
  String get sortBy;

  /// No description provided for @relevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get relevance;

  /// No description provided for @popularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get popularity;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @titleAsc.
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get titleAsc;

  /// No description provided for @titleDesc.
  ///
  /// In en, this message translates to:
  /// **'Title (Z-A)'**
  String get titleDesc;

  /// No description provided for @authorAsc.
  ///
  /// In en, this message translates to:
  /// **'Author (A-Z)'**
  String get authorAsc;

  /// No description provided for @authorDesc.
  ///
  /// In en, this message translates to:
  /// **'Author (Z-A)'**
  String get authorDesc;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @bookbox.
  ///
  /// In en, this message translates to:
  /// **'Bookbox'**
  String get bookbox;

  /// No description provided for @bookboxesnearyou.
  ///
  /// In en, this message translates to:
  /// **'Bookboxes near you'**
  String get bookboxesnearyou;

  /// No description provided for @searchBooks.
  ///
  /// In en, this message translates to:
  /// **'Search books...'**
  String get searchBooks;

  /// No description provided for @searchBookboxes.
  ///
  /// In en, this message translates to:
  /// **'Search bookboxes...'**
  String get searchBookboxes;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @refreshNearbyBookboxes.
  ///
  /// In en, this message translates to:
  /// **'Refresh nearby bookboxes'**
  String get refreshNearbyBookboxes;

  /// No description provided for @enterSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Enter a search term to find bookboxes or books'**
  String get enterSearchTerm;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'km away'**
  String get kmAway;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'results'**
  String get results;

  /// No description provided for @noBooksFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No books found for'**
  String get noBooksFoundFor;

  /// No description provided for @createNewRequest.
  ///
  /// In en, this message translates to:
  /// **'Create a new request for this book !'**
  String get createNewRequest;

  /// No description provided for @noBookboxesFoundWithin.
  ///
  /// In en, this message translates to:
  /// **'No bookboxes found within'**
  String get noBookboxesFoundWithin;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @tryExpandingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try expanding your search area or search manually'**
  String get tryExpandingSearch;

  /// No description provided for @adjustSearchDistance.
  ///
  /// In en, this message translates to:
  /// **'Adjust Search Distance'**
  String get adjustSearchDistance;

  /// No description provided for @currentDistance.
  ///
  /// In en, this message translates to:
  /// **'Current distance'**
  String get currentDistance;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @mapTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Map temporarily unavailable'**
  String get mapTemporarilyUnavailable;

  /// No description provided for @refreshNotifications.
  ///
  /// In en, this message translates to:
  /// **'Refresh notifications'**
  String get refreshNotifications;

  /// No description provided for @unableToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications'**
  String get unableToLoadNotifications;

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again'**
  String get checkInternetConnection;

  /// No description provided for @bookRequest.
  ///
  /// In en, this message translates to:
  /// **'Book Request'**
  String get bookRequest;

  /// No description provided for @newBookAvailable.
  ///
  /// In en, this message translates to:
  /// **'New Book Available'**
  String get newBookAvailable;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get daysAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'m ago'**
  String get minutesAgo;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @newNotification.
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get newNotification;

  /// No description provided for @someoneRequestedThisBook.
  ///
  /// In en, this message translates to:
  /// **'Someone requested this book'**
  String get someoneRequestedThisBook;

  /// No description provided for @matchesYourBookRequest.
  ///
  /// In en, this message translates to:
  /// **'Matches your book request'**
  String get matchesYourBookRequest;

  /// No description provided for @addedToFollowedBookboxPreview.
  ///
  /// In en, this message translates to:
  /// **'Added to followed bookbox'**
  String get addedToFollowedBookboxPreview;

  /// No description provided for @addedNearYou.
  ///
  /// In en, this message translates to:
  /// **'Added near you'**
  String get addedNearYou;

  /// No description provided for @matchesYourFavoriteGenre.
  ///
  /// In en, this message translates to:
  /// **'Matches your favorite genre'**
  String get matchesYourFavoriteGenre;

  /// No description provided for @andMore.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get andMore;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profileManagement.
  ///
  /// In en, this message translates to:
  /// **'Profile Management'**
  String get profileManagement;

  /// No description provided for @favoriteGenres.
  ///
  /// In en, this message translates to:
  /// **'Favorite Genres'**
  String get favoriteGenres;

  /// No description provided for @setupReadingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Set up your reading preferences'**
  String get setupReadingPreferences;

  /// No description provided for @favoriteLocations.
  ///
  /// In en, this message translates to:
  /// **'Favorite Locations'**
  String get favoriteLocations;

  /// No description provided for @managePreferredLocations.
  ///
  /// In en, this message translates to:
  /// **'Manage your preferred locations'**
  String get managePreferredLocations;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage your notifications'**
  String get manageNotifications;

  /// No description provided for @yourBookboxTrail.
  ///
  /// In en, this message translates to:
  /// **'Your Bookbox Trail'**
  String get yourBookboxTrail;

  /// No description provided for @failedToLoadTransactions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions'**
  String get failedToLoadTransactions;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @startAddingBooks.
  ///
  /// In en, this message translates to:
  /// **'Start adding or taking books to see your transaction history!'**
  String get startAddingBooks;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @followedBookBoxes.
  ///
  /// In en, this message translates to:
  /// **'Followed BookBoxes'**
  String get followedBookBoxes;

  /// No description provided for @errorLoadingFollowedBookboxes.
  ///
  /// In en, this message translates to:
  /// **'Error loading followed bookboxes'**
  String get errorLoadingFollowedBookboxes;

  /// No description provided for @noAuthenticationToken.
  ///
  /// In en, this message translates to:
  /// **'No authentication token found'**
  String get noAuthenticationToken;

  /// No description provided for @noFollowedBookboxes.
  ///
  /// In en, this message translates to:
  /// **'No followed bookboxes'**
  String get noFollowedBookboxes;

  /// No description provided for @startFollowingBookboxes.
  ///
  /// In en, this message translates to:
  /// **'Start following bookboxes to see them here!'**
  String get startFollowingBookboxes;

  /// No description provided for @took.
  ///
  /// In en, this message translates to:
  /// **'Took'**
  String get took;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @noAuthenticationTokenAvailable.
  ///
  /// In en, this message translates to:
  /// **'No authentication token available'**
  String get noAuthenticationTokenAvailable;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @errorMarkingNotificationAsRead.
  ///
  /// In en, this message translates to:
  /// **'Error marking notification as read'**
  String get errorMarkingNotificationAsRead;

  /// No description provided for @errorMarkingAllNotificationsAsRead.
  ///
  /// In en, this message translates to:
  /// **'Error marking all notifications as read'**
  String get errorMarkingAllNotificationsAsRead;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @noSpecificReasonProvided.
  ///
  /// In en, this message translates to:
  /// **'No specific reason provided for this notification.'**
  String get noSpecificReasonProvided;

  /// No description provided for @someoneIsLookingForBook.
  ///
  /// In en, this message translates to:
  /// **'Someone is looking for \"{bookTitle}\"'**
  String someoneIsLookingForBook(Object bookTitle);

  /// No description provided for @bookIsNowAvailable.
  ///
  /// In en, this message translates to:
  /// **'\"{bookTitle}\" is now available'**
  String bookIsNowAvailable(Object bookTitle);

  /// No description provided for @aBookBox.
  ///
  /// In en, this message translates to:
  /// **'a book box'**
  String get aBookBox;

  /// No description provided for @bookRequestContent.
  ///
  /// In en, this message translates to:
  /// **'Someone is looking for \"{bookTitle}\". If you have this book, please consider adding it to the nearest book box to help out!'**
  String bookRequestContent(Object bookTitle);

  /// No description provided for @addedToFollowedBookbox.
  ///
  /// In en, this message translates to:
  /// **'it was added to \"{bookboxName}\", a book box you follow'**
  String addedToFollowedBookbox(Object bookboxName);

  /// No description provided for @addedToNearbyBookbox.
  ///
  /// In en, this message translates to:
  /// **'it was added to \"{bookboxName}\", a book box near you'**
  String addedToNearbyBookbox(Object bookboxName);

  /// No description provided for @matchesFavoriteGenre.
  ///
  /// In en, this message translates to:
  /// **'it matches one of your favorite genres'**
  String get matchesFavoriteGenre;

  /// No description provided for @matchesBookRequest.
  ///
  /// In en, this message translates to:
  /// **'it matches a book request you made'**
  String get matchesBookRequest;

  /// No description provided for @andConjunction.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andConjunction;

  /// No description provided for @goodNewsBookAvailable.
  ///
  /// In en, this message translates to:
  /// **'Good news! \"{bookTitle}\" is now available because {reason}.'**
  String goodNewsBookAvailable(Object bookTitle, Object reason);

  /// No description provided for @addedToFollowedBookboxSync.
  ///
  /// In en, this message translates to:
  /// **'it was added to a book box you follow'**
  String get addedToFollowedBookboxSync;

  /// No description provided for @addedToNearbyBookboxSync.
  ///
  /// In en, this message translates to:
  /// **'it was added to a book box near you'**
  String get addedToNearbyBookboxSync;

  /// No description provided for @modifyProfile.
  ///
  /// In en, this message translates to:
  /// **'Modify Profile'**
  String get modifyProfile;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Read All'**
  String get markAllAsRead;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
