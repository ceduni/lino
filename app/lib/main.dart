import 'package:Lino_app/config/pages.dart';
import 'package:Lino_app/services/bookbox_state_service.dart';
import 'package:Lino_app/services/deep_link_service.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:Lino_app/vm/bookboxes/transactions/barcode_scanner_view_model.dart';
import 'package:Lino_app/vm/home/home_view_model.dart';
import 'package:Lino_app/vm/layout/appbar_view_model.dart';
import 'package:Lino_app/vm/search/search_view_model.dart';
import 'package:Lino_app/vm/search/search_page_view_model.dart';
import 'package:Lino_app/vm/profile/notifications_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// View models
import 'package:Lino_app/vm/profile/profile_view_model.dart';
import 'package:Lino_app/vm/profile/options_view_model.dart';
import 'package:Lino_app/vm/profile/options/modify_profile_view_model.dart';
import 'package:Lino_app/vm/profile/options/favourite_genres_view_model.dart';
import 'package:Lino_app/vm/profile/options/favourite_locations_view_model.dart';
import 'package:Lino_app/vm/bookboxes/book_box_issue_report_view_model.dart';
import 'package:Lino_app/vm/bookboxes/book_box_view_model.dart';
import 'package:Lino_app/vm/login/login_view_model.dart';
import 'package:Lino_app/vm/login/onboarding/favourite_genres_input_view_model.dart';
import 'package:Lino_app/vm/login/onboarding/favourite_locations_input_view_model.dart';
import 'package:Lino_app/vm/login/register_view_model.dart';
import 'package:Lino_app/vm/map/map_view_model.dart';
import 'package:Lino_app/vm/bookboxes/bookbox_list_view_model.dart';
import 'package:Lino_app/vm/forum/forum_view_model.dart';
import 'package:Lino_app/vm/forum/requests_view_model.dart';
import 'package:Lino_app/vm/forum/request_form_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables with error handling
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }

  // Initialize GetX services
  Get.put(BookBoxStateService());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    DeepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
      ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ChangeNotifierProvider(create: (_) => OptionsViewModel()),
      ChangeNotifierProvider(create: (_) => ModifyProfileViewModel()),
      ChangeNotifierProvider(create: (_) => FavouriteGenresViewModel()),
      ChangeNotifierProvider(create: (_) => FavouriteLocationsViewModel()),
      ChangeNotifierProvider(create: (_) => FavouriteGenresInputViewModel()),
      ChangeNotifierProvider(create: (_) => FavouriteLocationsInputViewModel()),
      ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ChangeNotifierProvider(create: (_) => RegisterViewModel()),
      ChangeNotifierProvider(create: (_) => BookBoxViewModel()),
      ChangeNotifierProvider(create: (_) => BookBoxIssueReportViewModel()),
      ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ChangeNotifierProvider(create: (_) => AppBarViewModel()),
      ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ChangeNotifierProvider(create: (_) => SearchPageViewModel()),
      ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
      ChangeNotifierProvider(create: (_) => MapViewModel()),
      ChangeNotifierProvider(create: (_) => BookboxListViewModel()),
      ChangeNotifierProvider(create: (_) => ForumViewModel()),
      ChangeNotifierProvider(create: (_) => RequestsViewModel()),
      ChangeNotifierProvider(create: (_) => RequestFormViewModel()),
      ChangeNotifierProvider(create: (_) => BarcodeScannerViewModel())
      ],
      child: GetMaterialApp(
        title: 'Lino',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: AppRoutes.home,
        getPages: AppPages.getPages,
        onReady: () {
          // Initialize deep link handling after GetX is ready
          DeepLinkService.initialize();
        },
      ),
    );
  }
}
