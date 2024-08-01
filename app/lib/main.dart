import 'package:Lino_app/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nav_menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({required this.prefs, super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lino',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage(prefs: prefs)),
        GetPage(name: '/home', page: () => BookNavPage()),
      ],
    );
  }
}
