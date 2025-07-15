import 'package:Lino_app/pages/login/login_page.dart';
import 'package:Lino_app/pages/map/favourite_locations_page.dart';
import 'package:Lino_app/services/bookbox_state_service.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nav_menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize GetX services
  Get.put(BookBoxStateService());
  
  final prefs = await SharedPreferences.getInstance();
  String? userId = await fetchUserId(prefs);
  runApp(MyApp(prefs: prefs, userId: userId));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final String? userId;

  const MyApp({required this.prefs, this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lino',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.home,
      getPages: [
        GetPage(name: AppRoutes.login, page: () => LoginPage(prefs: prefs)),
        GetPage(name: AppRoutes.home, page: () => BookNavPage()),
        GetPage(name: AppRoutes.favouriteLocations, page: () => FavouriteLocationsPage()),
        // Note: FavouriteLocationsInputPage now uses direct navigation instead of named routes
        // Add more routes here as needed
      ],
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
      return null;
    }
  }
  return null;
}
