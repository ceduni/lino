// lib/main.dart
import 'package:Lino_app/nav_menu.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  var us = UserService();
  final token = await us.loginUser('Asp3rity', 'J2s3jAsd');
  prefs.setString('token', token);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: NavigationMenu());
  }
}
 