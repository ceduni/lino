import 'package:Lino_app/pages/login/login_page.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/services/websocket_service.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nav_menu.dart';
import 'splash_screen.dart'; // Add this import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
  String? userId = await fetchUserId(prefs);

  WebSocketService().connect(
    'wss://lino-1.onrender.com/ws',
    userId: userId,
    onEvent: (event, data) {
      // Handle incoming WebSocket events
      print('Event: $event, Data: $data');
      // Add your custom event handling logic here
    },
  ); // Initialize WebSocket connection with userId

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
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginPage(prefs: prefs)),
        GetPage(name: '/home', page: () => BookNavPage()),
      ],
    );
  }
}

Future<String?> fetchUserId(SharedPreferences prefs) async {
  String? token = prefs.getString('token');
  if (token != null) {
    try {
      var user = await UserService().getUser(token);
      return user['user']['_id'];
    } catch (e) {
      print('Error fetching user ID: $e');
      return null;
    }
  }
  return null;
}
