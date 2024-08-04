import 'package:Lino_app/pages/login/login_page.dart';
import 'package:Lino_app/pages/nfc_dialog/book_box_action.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/splash_screen.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links2/uni_links.dart';
import 'dart:async';
import 'nav_menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  String? userId = await fetchUserId(prefs);
  runApp(MyApp(prefs: prefs, userId: userId));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  final String? userId;

  const MyApp({required this.prefs, this.userId, super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _handleIncomingLinks();
  }

  Future<void> initPlatformState() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } on PlatformException {
      print('Failed to get initial uri.');
    } on FormatException catch (err) {
      print('Malformed initial uri: $err');
    }
  }

  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    }, onError: (Object err) {
      print('Failed to handle incoming link: $err');
    });
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'lino' && uri.host == 'bookbox') {
      final bookBoxId = uri.queryParameters['bookBoxId'];
      if (bookBoxId != null) {
        Get.dialog(BookBoxAction(bookBoxId: bookBoxId));
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lino',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
        GetPage(name: AppRoutes.login, page: () => LoginPage(prefs: widget.prefs)),
        GetPage(name: AppRoutes.home, page: () => BookNavPage()),
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
      return user['user']['_id'];
    } catch (e) {
      print('Error fetching user ID: $e');
      return null;
    }
  }
  return null;
}
