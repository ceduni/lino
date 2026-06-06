import 'package:lino/vm/profile/transactions_view_model.dart';
import 'package:provider/provider.dart';
import 'package:nested/nested.dart';
import 'package:lino/vm/bookboxes/transactions/barcode_scanner_view_model.dart';
import 'package:lino/vm/home/home_view_model.dart';
import 'package:lino/vm/layout/appbar_view_model.dart';
import 'package:lino/vm/search/search_view_model.dart';
import 'package:lino/vm/search/search_page_view_model.dart';
import 'package:lino/vm/profile/notifications_view_model.dart';
import 'package:lino/vm/profile/profile_view_model.dart';
import 'package:lino/vm/profile/options_view_model.dart';
import 'package:lino/vm/profile/options/modify_profile_view_model.dart';
import 'package:lino/vm/profile/options/favourite_genres_view_model.dart';
import 'package:lino/vm/profile/options/favourite_locations_view_model.dart';
import 'package:lino/vm/bookboxes/book_box_issue_report_view_model.dart';
import 'package:lino/vm/bookboxes/book_box_view_model.dart';
import 'package:lino/vm/login/login_view_model.dart';
import 'package:lino/vm/login/onboarding/favourite_genres_input_view_model.dart';
import 'package:lino/vm/login/onboarding/favourite_locations_input_view_model.dart';
import 'package:lino/vm/login/register_view_model.dart';
import 'package:lino/vm/map/map_view_model.dart';
import 'package:lino/vm/bookboxes/bookbox_list_view_model.dart';
import 'package:lino/vm/forum/forum_view_model.dart';
import 'package:lino/vm/forum/requests_view_model.dart';
import 'package:lino/vm/forum/request_form_view_model.dart';
import 'package:get/get.dart';

import '../controllers/locale_controller.dart';

// In providers.dart
class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider<ProfileViewModel>(create: (_) => ProfileViewModel()),
    ChangeNotifierProvider<TransactionsViewModel>(create: (_) => TransactionsViewModel()),
    ChangeNotifierProvider<OptionsViewModel>(create: (_) => OptionsViewModel()),
    ChangeNotifierProvider<ModifyProfileViewModel>(create: (_) => ModifyProfileViewModel()),
    ChangeNotifierProvider<FavouriteGenresViewModel>(create: (_) => FavouriteGenresViewModel()),
    ChangeNotifierProvider<FavouriteLocationsViewModel>(create: (_) => FavouriteLocationsViewModel()),
    ChangeNotifierProvider<FavouriteGenresInputViewModel>(create: (_) => FavouriteGenresInputViewModel()),
    ChangeNotifierProvider<FavouriteLocationsInputViewModel>(create: (_) => FavouriteLocationsInputViewModel()),
    ChangeNotifierProvider<LoginViewModel>(create: (_) => LoginViewModel()),
    ChangeNotifierProvider<RegisterViewModel>(create: (_) => RegisterViewModel()),
    ChangeNotifierProvider<BookBoxViewModel>(create: (_) => BookBoxViewModel()),
    ChangeNotifierProvider<BookBoxIssueReportViewModel>(create: (_) => BookBoxIssueReportViewModel()),
    ChangeNotifierProvider<HomeViewModel>(create: (_) => HomeViewModel()),
    ChangeNotifierProvider<AppBarViewModel>(create: (_) => AppBarViewModel()),
    ChangeNotifierProvider<SearchViewModel>(create: (_) => SearchViewModel()),
    ChangeNotifierProvider<SearchPageViewModel>(create: (_) => SearchPageViewModel()),
    ChangeNotifierProvider<NotificationsViewModel>(create: (_) => NotificationsViewModel()),
    ChangeNotifierProvider<MapViewModel>(create: (_) => MapViewModel()),
    ChangeNotifierProvider<BookboxListViewModel>(create: (_) => BookboxListViewModel()),
    ChangeNotifierProvider<ForumViewModel>(create: (_) => ForumViewModel()),
    ChangeNotifierProvider<RequestsViewModel>(create: (_) => RequestsViewModel()),
    ChangeNotifierProvider<RequestFormViewModel>(create: (_) => RequestFormViewModel()),
    ChangeNotifierProvider<BarcodeScannerViewModel>(create: (_) => BarcodeScannerViewModel()),
    Provider<LocaleController>(
      create: (_) => Get.put(LocaleController()),
    ),
  ];
}