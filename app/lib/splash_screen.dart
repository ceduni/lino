import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    await Future.delayed(Duration(seconds: 1)); // Simulate some loading time
    Get.offNamed('/home'); // Navigate to home page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4277B8),
      body: Center(
        child: Image.asset('assets/logos/logo_with_bird.png', height: 150),
      ),
    );
  }
}
