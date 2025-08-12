import 'package:Lino_app/pages/bookbox/book_box_screen.dart';
import 'package:Lino_app/pages/login/login_page.dart';
import 'package:Lino_app/services/bookbox_state_service.dart';
import 'package:Lino_app/services/deep_link_service.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/nav_menu.dart';
// Import your view models
import 'package:Lino_app/vm/profile/profile_view_model.dart';
import 'package:Lino_app/vm/profile/options_view_model.dart';
import 'package:Lino_app/vm/profile/options/modify_profile_view_model.dart';
import 'package:Lino_app/vm/profile/options/favourite_genres_view_model.dart';
import 'package:Lino_app/vm/profile/options/favourite_locations_view_model.dart';

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
          GetPage(name: AppRoutes.bookbox, page: () => const BookBoxScreen()),
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