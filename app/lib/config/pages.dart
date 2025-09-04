// lib/config/pages.dart
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
      name: AppRoutes.home,
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
  ];
}