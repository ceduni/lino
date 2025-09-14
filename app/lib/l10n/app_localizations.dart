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

  /// No description provided for @createRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get createRequest;

  /// No description provided for @searchBookTitles.
  ///
  /// In en, this message translates to:
  /// **'Search book titles...'**
  String get searchBookTitles;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter '**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort '**
  String get sort;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @mine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mine;

  /// No description provided for @upvoted.
  ///
  /// In en, this message translates to:
  /// **'Upvoted'**
  String get upvoted;

  /// No description provided for @notified.
  ///
  /// In en, this message translates to:
  /// **'Notified'**
  String get notified;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @upvotes.
  ///
  /// In en, this message translates to:
  /// **'Upvotes'**
  String get upvotes;

  /// No description provided for @yourRequest.
  ///
  /// In en, this message translates to:
  /// **'Your request'**
  String get yourRequest;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by'**
  String get requestedBy;

  /// No description provided for @loginToCreateRequests.
  ///
  /// In en, this message translates to:
  /// **'Login to Create Requests'**
  String get loginToCreateRequests;

  /// No description provided for @noRequestsFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No requests found for '**
  String get noRequestsFoundFor;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try searching for a different book title or clear your search to see all requests.'**
  String get tryDifferentSearch;

  /// No description provided for @noBookRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No book requests found'**
  String get noBookRequestsFound;

  /// No description provided for @beFirstToRequest.
  ///
  /// In en, this message translates to:
  /// **'Be the first to request a book!'**
  String get beFirstToRequest;

  /// No description provided for @youHaveNoRequests.
  ///
  /// In en, this message translates to:
  /// **'You have no requests'**
  String get youHaveNoRequests;

  /// No description provided for @startRequestingBooks.
  ///
  /// In en, this message translates to:
  /// **'Start requesting books you\'d like to read'**
  String get startRequestingBooks;

  /// No description provided for @noUpvotedRequests.
  ///
  /// In en, this message translates to:
  /// **'No upvoted requests'**
  String get noUpvotedRequests;

  /// No description provided for @haventUpvotedYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t upvoted any requests yet'**
  String get haventUpvotedYet;

  /// No description provided for @noNotifiedRequests.
  ///
  /// In en, this message translates to:
  /// **'No notified requests'**
  String get noNotifiedRequests;

  /// No description provided for @haventBeenNotified.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t been notified about any requests yet'**
  String get haventBeenNotified;

  /// No description provided for @deleteRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your request for '**
  String get deleteRequestTitle;

  /// No description provided for @deleteRequestContent.
  ///
  /// In en, this message translates to:
  /// **'You won\'t be notified when the book you want will be added to a bookbox.'**
  String get deleteRequestContent;

  /// No description provided for @deleteRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request deleted successfully!'**
  String get deleteRequestSuccess;

  /// No description provided for @requestDeleted.
  ///
  /// In en, this message translates to:
  /// **'Request Deleted'**
  String get requestDeleted;

  /// No description provided for @requestDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your book request has been deleted successfully.'**
  String get requestDeletedMessage;

  /// No description provided for @failedToDeleteRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete request'**
  String get failedToDeleteRequest;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @peopleNotified.
  ///
  /// In en, this message translates to:
  /// **'People Notified: '**
  String get peopleNotified;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @errorLoadingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Error loading transactions'**
  String get errorLoadingTransactions;

  /// No description provided for @startAddingBooksToSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'Start adding or taking books to see your transaction history!'**
  String get startAddingBooksToSeeHistory;

  /// No description provided for @transactiontotal.
  ///
  /// In en, this message translates to:
  /// **'transactions total'**
  String get transactiontotal;

  /// No description provided for @notransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get notransactions;

  /// No description provided for @de.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get de;

  /// No description provided for @followedBookBoxesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No followed bookboxes'**
  String get followedBookBoxesEmpty;

  /// No description provided for @startFollowingBookBoxes.
  ///
  /// In en, this message translates to:
  /// **'Start following bookboxes to see them here!'**
  String get startFollowingBookBoxes;

  /// No description provided for @newbooknotifications.
  ///
  /// In en, this message translates to:
  /// **'New Book Notifications'**
  String get newbooknotifications;

  /// No description provided for @getnotifiedwhenbooksmatchingyourpreferencesareaddedtobookboxesyoufolloworinyourfavoritelocations.
  ///
  /// In en, this message translates to:
  /// **'Get notified when books matching your preferences are added to bookboxes you follow or in your favorite locations'**
  String
      get getnotifiedwhenbooksmatchingyourpreferencesareaddedtobookboxesyoufolloworinyourfavoritelocations;

  /// No description provided for @bookRequestnotifications.
  ///
  /// In en, this message translates to:
  /// **'Book Request Notifications'**
  String get bookRequestnotifications;

  /// No description provided for @getnotifiedwhensomeonerequestsabookfromyou.
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone requests a book from one of the bookboxes you follow'**
  String get getnotifiedwhensomeonerequestsabookfromyou;

  /// No description provided for @setupFavoriteGenres.
  ///
  /// In en, this message translates to:
  /// **'Setup Favourite Genres'**
  String get setupFavoriteGenres;

  /// No description provided for @tellUsFavoriteGenres.
  ///
  /// In en, this message translates to:
  /// **'Tell us your favourite genres:'**
  String get tellUsFavoriteGenres;

  /// No description provided for @selectFavoriteGenresDescription.
  ///
  /// In en, this message translates to:
  /// **'Select your favourite book genres to get personalized recommendations and notifications'**
  String get selectFavoriteGenresDescription;

  /// No description provided for @searchOrEnterCustomGenre.
  ///
  /// In en, this message translates to:
  /// **'Search or enter custom genre'**
  String get searchOrEnterCustomGenre;

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get pass;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished!'**
  String get finished;

  /// No description provided for @favouriteLocations.
  ///
  /// In en, this message translates to:
  /// **'Favourite Locations'**
  String get favouriteLocations;

  /// No description provided for @searchForPlaces.
  ///
  /// In en, this message translates to:
  /// **'Search for places...'**
  String get searchForPlaces;

  /// No description provided for @removeLocation.
  ///
  /// In en, this message translates to:
  /// **'Remove Location'**
  String get removeLocation;

  /// No description provided for @removeLocationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{locationName}\" from your favourite locations?'**
  String removeLocationConfirm(Object locationName);

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get howToUse;

  /// No description provided for @searchPlacesInstruction.
  ///
  /// In en, this message translates to:
  /// **'• Search for places using the search bar'**
  String get searchPlacesInstruction;

  /// No description provided for @tapMapInstruction.
  ///
  /// In en, this message translates to:
  /// **'• Tap anywhere on the map to add a location'**
  String get tapMapInstruction;

  /// No description provided for @tapMarkersInstruction.
  ///
  /// In en, this message translates to:
  /// **'• Tap on markers to remove locations'**
  String get tapMarkersInstruction;

  /// No description provided for @dragDividerInstruction.
  ///
  /// In en, this message translates to:
  /// **'• Drag the divider between map and list to resize'**
  String get dragDividerInstruction;

  /// No description provided for @maxLocationsInstruction.
  ///
  /// In en, this message translates to:
  /// **'• Maximum 10 favourite locations allowed'**
  String get maxLocationsInstruction;

  /// No description provided for @tapListItemsInstruction.
  ///
  /// In en, this message translates to:
  /// **'• Tap on list items to center map on location'**
  String get tapListItemsInstruction;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @favouriteLocationsCount.
  ///
  /// In en, this message translates to:
  /// **'Favourite Locations ({count}/10)'**
  String favouriteLocationsCount(Object count);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noFavouriteLocationsYet.
  ///
  /// In en, this message translates to:
  /// **'No favourite locations yet'**
  String get noFavouriteLocationsYet;

  /// No description provided for @tapMapOrSearchToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map or search to add locations'**
  String get tapMapOrSearchToAdd;

  /// No description provided for @clearAllLocations.
  ///
  /// In en, this message translates to:
  /// **'Clear All Locations'**
  String get clearAllLocations;

  /// No description provided for @clearAllLocationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all favourite locations?'**
  String get clearAllLocationsConfirm;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @createBookRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Book Request'**
  String get createBookRequest;

  /// No description provided for @whatBookAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What book are you looking for?'**
  String get whatBookAreYouLookingFor;

  /// No description provided for @searchForBookOrEnterCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Search for a book or enter a custom title to request it from other users.'**
  String get searchForBookOrEnterCustomTitle;

  /// No description provided for @searchingForBooks.
  ///
  /// In en, this message translates to:
  /// **'Searching for books...'**
  String get searchingForBooks;

  /// No description provided for @noSuggestionsFound.
  ///
  /// In en, this message translates to:
  /// **'No suggestions found'**
  String get noSuggestionsFound;

  /// No description provided for @useCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Use custom title'**
  String get useCustomTitle;

  /// No description provided for @suggestionsFromGoogleBooks.
  ///
  /// In en, this message translates to:
  /// **'Suggestions from Google Books'**
  String get suggestionsFromGoogleBooks;

  /// No description provided for @useThisTitle.
  ///
  /// In en, this message translates to:
  /// **'Use this title'**
  String get useThisTitle;

  /// No description provided for @usingCustomTitleWarning.
  ///
  /// In en, this message translates to:
  /// **'Using a custom title may reduce your chances of being notified when this book becomes available.'**
  String get usingCustomTitleWarning;

  /// No description provided for @customMessage.
  ///
  /// In en, this message translates to:
  /// **'Custom Message'**
  String get customMessage;

  /// No description provided for @addPersonalNote.
  ///
  /// In en, this message translates to:
  /// **'Add a personal note about why you want this book (optional)'**
  String get addPersonalNote;

  /// No description provided for @checkingSimilarRequests.
  ///
  /// In en, this message translates to:
  /// **'Checking for similar requests...'**
  String get checkingSimilarRequests;

  /// No description provided for @similarRequestExists.
  ///
  /// In en, this message translates to:
  /// **'There are {count} similar request(s) for this book.'**
  String similarRequestExists(Object count);

  /// No description provided for @bookSelectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Book selected successfully!'**
  String get bookSelectedSuccessfully;

  /// No description provided for @selectedBook.
  ///
  /// In en, this message translates to:
  /// **'Selected book'**
  String get selectedBook;

  /// No description provided for @scanBookBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Book Barcode'**
  String get scanBookBarcode;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @invalidQRCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get invalidQRCode;

  /// No description provided for @confirmTakeBook.
  ///
  /// In en, this message translates to:
  /// **'Confirm Take Book'**
  String get confirmTakeBook;

  /// No description provided for @takeBookQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to take this book?'**
  String get takeBookQuestion;

  /// No description provided for @confirmTake.
  ///
  /// In en, this message translates to:
  /// **'Confirm Take'**
  String get confirmTake;

  /// No description provided for @takingBook.
  ///
  /// In en, this message translates to:
  /// **'Taking book...'**
  String get takingBook;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @successfullyTook.
  ///
  /// In en, this message translates to:
  /// **'Successfully took \"{title}\"'**
  String successfullyTook(Object title);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @failedToTakeBook.
  ///
  /// In en, this message translates to:
  /// **'Failed to take book: {error}'**
  String failedToTakeBook(Object error);

  /// No description provided for @bookAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Book added to BookBox successfully!'**
  String get bookAddedSuccessfully;

  /// No description provided for @failedToAddBook.
  ///
  /// In en, this message translates to:
  /// **'Failed to add book: {error}'**
  String failedToAddBook(Object error);

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @reportProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblemTitle;

  /// No description provided for @reportProblemDescription.
  ///
  /// In en, this message translates to:
  /// **'Help us improve by reporting issues with this bookbox. We\'ll investigate and respond as soon as possible.'**
  String get reportProblemDescription;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @briefDescriptionOfIssue.
  ///
  /// In en, this message translates to:
  /// **'Brief description of the issue'**
  String get briefDescriptionOfIssue;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @detailedDescriptionOfIssue.
  ///
  /// In en, this message translates to:
  /// **'Detailed description of the issue'**
  String get detailedDescriptionOfIssue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @yourAccountEmailLocked.
  ///
  /// In en, this message translates to:
  /// **'Your account email (locked)'**
  String get yourAccountEmailLocked;

  /// No description provided for @yourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Your email address'**
  String get yourEmailAddress;

  /// No description provided for @subjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Subject is required'**
  String get subjectRequired;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @failedToReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Failed to report issue: {error}'**
  String failedToReportIssue(Object error);

  /// No description provided for @emailPrefilledInfo.
  ///
  /// In en, this message translates to:
  /// **'Your email is pre-filled from your account and cannot be changed.'**
  String get emailPrefilledInfo;

  /// No description provided for @provideEmailInfo.
  ///
  /// In en, this message translates to:
  /// **'Please provide your email so we can contact you about this issue.'**
  String get provideEmailInfo;

  /// No description provided for @bookTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Title'**
  String get bookTitle;

  /// No description provided for @bookSelectedDot.
  ///
  /// In en, this message translates to:
  /// **'Book selected.'**
  String get bookSelectedDot;

  /// No description provided for @customTitleLocked.
  ///
  /// In en, this message translates to:
  /// **'Custom title locked.'**
  String get customTitleLocked;

  /// No description provided for @startTypingToSearch.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search for books...'**
  String get startTypingToSearch;

  /// No description provided for @changeSelection.
  ///
  /// In en, this message translates to:
  /// **'Change selection'**
  String get changeSelection;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @pleaseTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the title of the book'**
  String get pleaseTitleRequired;

  /// No description provided for @selectBookOrUseCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a book or use custom title:'**
  String get selectBookOrUseCustomTitle;

  /// No description provided for @useCustomTitleOption.
  ///
  /// In en, this message translates to:
  /// **'Use custom title'**
  String get useCustomTitleOption;

  /// No description provided for @continueWithTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue with \"{title}\"'**
  String continueWithTitle(Object title);

  /// No description provided for @byAuthor.
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String byAuthor(Object author);

  /// No description provided for @customTitleWarning.
  ///
  /// In en, this message translates to:
  /// **'Using a custom title may reduce your chances of being notified when this book becomes available.'**
  String get customTitleWarning;

  /// No description provided for @checkingForSimilarRequests.
  ///
  /// In en, this message translates to:
  /// **'Checking for similar requests...'**
  String get checkingForSimilarRequests;

  /// No description provided for @noSimilarBookRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No similar book requests found'**
  String get noSimilarBookRequestsFound;

  /// No description provided for @similarBookRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} book request{plural} with a similar book title {verb} found'**
  String similarBookRequestsFound(int count, String plural, String verb);

  /// No description provided for @unableToCheckSimilarRequests.
  ///
  /// In en, this message translates to:
  /// **'Unable to check for similar requests'**
  String get unableToCheckSimilarRequests;

  /// No description provided for @selectedBookPrefix.
  ///
  /// In en, this message translates to:
  /// **'Selected: {title}'**
  String selectedBookPrefix(String title);

  /// No description provided for @customMessageOptional.
  ///
  /// In en, this message translates to:
  /// **'Custom Message (optional)'**
  String get customMessageOptional;

  /// No description provided for @dismissError.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissError;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @confirmBookSelection.
  ///
  /// In en, this message translates to:
  /// **'Confirm Book Selection'**
  String get confirmBookSelection;

  /// No description provided for @unknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Author'**
  String get unknownAuthor;

  /// No description provided for @areYouSureWantToTakeBook.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to take this book?'**
  String get areYouSureWantToTakeBook;

  /// No description provided for @takeBook.
  ///
  /// In en, this message translates to:
  /// **'Take Book'**
  String get takeBook;

  /// No description provided for @cantFindOrScanISBN.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find or scan the ISBN?'**
  String get cantFindOrScanISBN;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// No description provided for @bookList.
  ///
  /// In en, this message translates to:
  /// **'Book List'**
  String get bookList;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @changeBook.
  ///
  /// In en, this message translates to:
  /// **'Change book'**
  String get changeBook;

  /// No description provided for @bookNotFound.
  ///
  /// In en, this message translates to:
  /// **'Book Not Found'**
  String get bookNotFound;

  /// No description provided for @tryAnotherBook.
  ///
  /// In en, this message translates to:
  /// **'Try Another Book'**
  String get tryAnotherBook;

  /// No description provided for @viewAvailableBooks.
  ///
  /// In en, this message translates to:
  /// **'View Available Books'**
  String get viewAvailableBooks;

  /// No description provided for @editBookDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Book Details'**
  String get editBookDetails;

  /// No description provided for @titleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleField;

  /// No description provided for @authorsSeparateCommas.
  ///
  /// In en, this message translates to:
  /// **'Authors (separate with commas)'**
  String get authorsSeparateCommas;

  /// No description provided for @publicationYear.
  ///
  /// In en, this message translates to:
  /// **'Publication Year'**
  String get publicationYear;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @categoriesSeparateCommas.
  ///
  /// In en, this message translates to:
  /// **'Categories (separate with commas)'**
  String get categoriesSeparateCommas;

  /// No description provided for @bookDescription.
  ///
  /// In en, this message translates to:
  /// **'Book Description'**
  String get bookDescription;

  /// No description provided for @bookInformation.
  ///
  /// In en, this message translates to:
  /// **'Book Information'**
  String get bookInformation;

  /// No description provided for @publisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisher;

  /// No description provided for @numberOfPages.
  ///
  /// In en, this message translates to:
  /// **'Number of Pages'**
  String get numberOfPages;

  /// No description provided for @confirmAddToBookBox.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Add to BookBox'**
  String get confirmAddToBookBox;

  /// No description provided for @noThumbnailAvailable.
  ///
  /// In en, this message translates to:
  /// **'No thumbnail available'**
  String get noThumbnailAvailable;

  /// No description provided for @noCoverAvailable.
  ///
  /// In en, this message translates to:
  /// **'No cover available'**
  String get noCoverAvailable;

  /// No description provided for @addBookCover.
  ///
  /// In en, this message translates to:
  /// **'Add Book Cover'**
  String get addBookCover;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @pointCameraAtQRCode.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a QR code'**
  String get pointCameraAtQRCode;

  /// No description provided for @qrCodeScannedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'The QR code will be scanned automatically'**
  String get qrCodeScannedAutomatically;

  /// No description provided for @toggleFlash.
  ///
  /// In en, this message translates to:
  /// **'Toggle Flash'**
  String get toggleFlash;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch Camera'**
  String get switchCamera;

  /// No description provided for @invalidQRCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get invalidQRCodeTitle;

  /// No description provided for @notValidLinoBookboxCode.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a valid Lino bookbox code.'**
  String get notValidLinoBookboxCode;

  /// No description provided for @scannedContent.
  ///
  /// In en, this message translates to:
  /// **'Scanned content:'**
  String get scannedContent;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @noBookboxIdProvided.
  ///
  /// In en, this message translates to:
  /// **'No bookbox ID provided'**
  String get noBookboxIdProvided;

  /// No description provided for @errorLoadingBookboxData.
  ///
  /// In en, this message translates to:
  /// **'Error loading bookbox data'**
  String get errorLoadingBookboxData;

  /// No description provided for @noBookboxDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No bookbox data available'**
  String get noBookboxDataAvailable;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @didntFindBookCreateRequest.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t find your book? Create a new request !'**
  String get didntFindBookCreateRequest;

  /// No description provided for @reportIssueWithBookBox.
  ///
  /// In en, this message translates to:
  /// **'Report issue with this BookBox'**
  String get reportIssueWithBookBox;

  /// No description provided for @issueReportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Issue reported successfully'**
  String get issueReportedSuccessfully;

  /// No description provided for @underMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Under Maintenance'**
  String get underMaintenance;

  /// No description provided for @maintenanceMessage.
  ///
  /// In en, this message translates to:
  /// **'This BookBox is temporarily deactivated for maintenance. You can view the books inside but cannot exchange books from it until it\'s reactivated.'**
  String get maintenanceMessage;

  /// No description provided for @booksAvailable.
  ///
  /// In en, this message translates to:
  /// **'Books Available'**
  String get booksAvailable;

  /// No description provided for @noBooksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No books available'**
  String get noBooksAvailable;

  /// No description provided for @addBook.
  ///
  /// In en, this message translates to:
  /// **'Add Book'**
  String get addBook;

  /// No description provided for @bookBoxUnderMaintenance.
  ///
  /// In en, this message translates to:
  /// **'BookBox Under Maintenance'**
  String get bookBoxUnderMaintenance;

  /// No description provided for @cannotAddBooksUnderMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Cannot add books while BookBox is deactivated for maintenance'**
  String get cannotAddBooksUnderMaintenance;

  /// No description provided for @cannotRemoveBooksUnderMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove books while BookBox is deactivated for maintenance'**
  String get cannotRemoveBooksUnderMaintenance;

  /// No description provided for @addedAgo.
  ///
  /// In en, this message translates to:
  /// **'Added {timeAgo}'**
  String addedAgo(String timeAgo);

  /// No description provided for @chooseNavigationApp.
  ///
  /// In en, this message translates to:
  /// **'Choose Navigation App'**
  String get chooseNavigationApp;

  /// No description provided for @appleMapss.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps'**
  String get appleMapss;

  /// No description provided for @googleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get googleMaps;

  /// No description provided for @couldNotOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Could not open the map.'**
  String get couldNotOpenMap;

  /// No description provided for @couldNotOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open {appName}. Please make sure it\'s installed.'**
  String couldNotOpenApp(String appName);

  /// No description provided for @bookDetails.
  ///
  /// In en, this message translates to:
  /// **'Book Details'**
  String get bookDetails;

  /// No description provided for @swipeForDetails.
  ///
  /// In en, this message translates to:
  /// **'Swipe for details'**
  String get swipeForDetails;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @availableAtBookBox.
  ///
  /// In en, this message translates to:
  /// **'Available at BookBox'**
  String get availableAtBookBox;

  /// No description provided for @tapToViewBookBoxDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap to view BookBox details'**
  String get tapToViewBookBoxDetails;

  /// No description provided for @bookStatistics.
  ///
  /// In en, this message translates to:
  /// **'Book Statistics'**
  String get bookStatistics;

  /// No description provided for @unableToLoadStatistics.
  ///
  /// In en, this message translates to:
  /// **'Unable to load statistics'**
  String get unableToLoadStatistics;

  /// No description provided for @noStatisticsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No statistics available'**
  String get noStatisticsAvailable;

  /// No description provided for @timesAdded.
  ///
  /// In en, this message translates to:
  /// **'Times Added'**
  String get timesAdded;

  /// No description provided for @timesTaken.
  ///
  /// In en, this message translates to:
  /// **'Times Taken'**
  String get timesTaken;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @tapToAddCover.
  ///
  /// In en, this message translates to:
  /// **'Tap to add cover'**
  String get tapToAddCover;
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
