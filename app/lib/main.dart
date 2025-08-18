import 'package:Lino_app/views/bookboxes/book_box_page.dart';
import 'package:Lino_app/views/login/login_page.dart';
import 'package:Lino_app/views/forum/bookbox_selection_page.dart';
import 'package:Lino_app/services/bookbox_state_service.dart';
import 'package:Lino_app/services/deep_link_service.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:Lino_app/vm/home/home_view_model.dart';
import 'package:Lino_app/vm/layout/appbar_view_model.dart';
import 'package:Lino_app/vm/search/search_view_model.dart';
import 'package:Lino_app/vm/search/search_page_view_model.dart';
import 'package:Lino_app/vm/profile/notifications_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/nav_menu.dart';
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

  final prefs = await SharedPreferences.getInstance();
  String? userId;
  try {
    userId = await fetchUserId(prefs);
  } catch (e) {
    print('Error fetching user ID during startup: $e');
    userId = null;
  }
  runApp(MyApp(prefs: prefs, userId: userId));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  final String? userId;

  const MyApp({required this.prefs, this.userId, super.key});

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
      ],
      child: GetMaterialApp(
        title: 'Lino',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: AppRoutes.home,
        getPages: [
          GetPage(name: AppRoutes.login, page: () => LoginPage(prefs: widget.prefs)),
          GetPage(name: AppRoutes.home, page: () => const BookNavPage()),
          GetPage(name: AppRoutes.bookbox, page: () => const BookBoxPage()),
          GetPage(
            name: AppRoutes.bookboxSelection, 
            page: () => BookboxSelectionPage(arguments: Get.arguments ?? {}),
          ),
          // Add more routes here as needed
        ],
        onReady: () {
          // Initialize deep link handling after GetX is ready
          DeepLinkService.initialize();
        },
      ),
    );
  }
}

Future<String?> fetchUserId(SharedPreferences prefs) async {
  String? token = prefs.getString('token');
  if (token != null) {
    try {
      var user = await UserService().getUser(token);
      return user.id;
    } catch (e) {
      print('Error fetching user ID: $e');
      // Set token to null if fetching user fails
      await prefs.remove('token');
      return null;
    }
  }
  return null;
}
