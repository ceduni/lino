import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'nav_menu.dart';
import 'providers/thread_provider.dart';
import 'providers/request_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThreadProvider()),
        ChangeNotifierProvider(create: (context) => RequestProvider()),
      ],
      child: MyApp(initialToken: token, prefs: prefs),
    ),
  );
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
      home: NavigationMenu(),
    );
  }
}
