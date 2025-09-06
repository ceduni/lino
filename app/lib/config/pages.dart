// lib/config/pages.dart
import 'package:Lino_app/views/forum/request_form.dart';
import 'package:Lino_app/views/profile/followed_bookboxes_page.dart';
import 'package:Lino_app/views/profile/notifications_page.dart';
import 'package:Lino_app/views/profile/options/favourite_genres_page.dart';
import 'package:Lino_app/views/profile/options/notifications_setting_page.dart';
import 'package:Lino_app/views/profile/transactions_page.dart';
import 'package:get/get.dart';
import 'package:Lino_app/views/bookboxes/book_box_page.dart';
import 'package:Lino_app/views/login/login_page.dart';
import 'package:Lino_app/views/forum/bookbox_selection_page.dart';
import 'package:Lino_app/views/login/onboarding/favourite_genres_input_page.dart';
import 'package:Lino_app/views/login/onboarding/favourite_locations_input_page.dart';
import 'package:Lino_app/views/login/register_page.dart';
import 'package:Lino_app/views/profile/options/modify_profile_page.dart';
import 'package:Lino_app/views/qr_scanner/qr_scanner_page.dart';
import 'package:Lino_app/nav_menu.dart';
import 'package:Lino_app/utils/constants/routes.dart';

import '../views/profile/options/favourite_locations_page.dart';

class AppPages {
  static List<GetPage> getPages = [
    GetPage(
      name: AppRoutes.auth.login,
      page: () => LoginPage(),
    ),
    GetPage(
      name: AppRoutes.auth.register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.profile.modify,
      page: () => const ModifyProfilePage(),
    ),
    GetPage(
      name: AppRoutes.home.main,
      page: () => const BookNavPage(),
    ),
    GetPage(
      name: AppRoutes.bookbox.main,
      page: () => const BookBoxPage(),
    ),
    GetPage(
      name: AppRoutes.forum.request.bookboxSelection,
      page: () => BookboxSelectionPage(
        arguments: Get.arguments ?? {},
      ),
    ),
    GetPage(
      name: AppRoutes.scan.qrScanner,
      page: () => const QRScannerPage(),
    ),
    GetPage(
      name: AppRoutes.auth.onboarding.favouriteGenres,
      page: () => const FavouriteGenresInputPage(),
    ),
    GetPage(
      name: AppRoutes.auth.onboarding.favouriteLocations,
      page: () => const FavouriteLocationsInputPage(),
    ),
    GetPage(
      name: AppRoutes.forum.request.form,
      page: () => const RequestFormPage(),
    ),
    GetPage(
      name: AppRoutes.home.notifications,
      page: () => const NotificationsPage(),
    ),
    GetPage(
      name: AppRoutes.profile.followedBookboxes,
      page: () => const FollowedBookboxesPage(),
    ),
    GetPage(
      name: AppRoutes.profile.transactions,
      page: () => const TransactionsPage(),
    ),
    GetPage(
      name: AppRoutes.profile.favouriteGenres,
      page: () => const FavouriteGenresPage(),
    ),
    GetPage(
      name: AppRoutes.profile.favouriteLocations,
      page: () => const FavouriteLocationsPage(),
    ),
    GetPage(
      name: AppRoutes.profile.setupNotifications,
      page: () => const NotificationSettingPage(),
    )
  ];
}