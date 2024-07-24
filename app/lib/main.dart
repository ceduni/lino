import 'package:Lino_app/nav_menu.dart';
import 'package:Lino_app/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
  final token = prefs.getString('token');
  runApp(MyApp(initialToken: token, prefs: prefs));
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  final SharedPreferences prefs;
  const MyApp({required this.initialToken, required this.prefs, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: initialToken == null ? LoginPage(prefs: prefs) : NavigationMenu(),
    );
  }
}

