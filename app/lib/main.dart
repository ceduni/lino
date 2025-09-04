import 'package:Lino_app/config/pages.dart';
import 'package:Lino_app/config/providers.dart';
import 'package:Lino_app/services/deep_link_service.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables with error handling
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
      providers: AppProviders.providers,
      child: GetMaterialApp(
        title: 'Lino',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: AppRoutes.home,
        getPages: AppPages.getPages,
        onReady: () {
          // Initialize deep link handling after GetX is ready
          DeepLinkService.initialize();
        },
      ),
    );
  }
}
