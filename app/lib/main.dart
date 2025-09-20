import 'package:Lino_app/config/pages.dart';
import 'package:Lino_app/config/providers.dart';
import 'package:Lino_app/services/deep_link_service.dart';
import 'package:Lino_app/services/first_launch_service.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'controllers/locale_controller.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables with error handling
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }

  Get.put(LocaleController());

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? initialRoute;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    final isFirstLaunch = await FirstLaunchService.isFirstLaunch();
    
    setState(() {
      if (isFirstLaunch) {
        initialRoute = AppRoutes.auth.login;
        // Mark app as launched after setting the route
        FirstLaunchService.markAppAsLaunched();
      } else {
        initialRoute = AppRoutes.home.main;
      }
    });
  }

  @override
  void dispose() {
    DeepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while determining initial route
    if (initialRoute == null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: AppProviders.providers,
      child: GetX<LocaleController>(
        builder: (localeController) => GetMaterialApp(
          title: 'Lino',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          // Localization configuration
          locale: localeController.locale.value,
          fallbackLocale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: localeController.supportedLocales,

          initialRoute: initialRoute,
          getPages: AppPages.getPages,
          onReady: () {
            // Initialize deep link handling after GetX is ready
            DeepLinkService.initialize();
          },
        ),
      )
    );
  }
}
