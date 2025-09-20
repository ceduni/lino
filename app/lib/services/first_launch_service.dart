import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchService {
  static const String _firstLaunchKey = 'is_first_launch';

  /// Check if this is the first time the app is being launched
  static Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // If the key doesn't exist, it means this is the first launch
      return prefs.getBool(_firstLaunchKey) ?? true;
    } catch (e) {
      // In case of error, assume it's first launch for safety
      print('Error checking first launch status: $e');
      return true;
    }
  }

  /// Mark that the app has been launched (set first launch to false)
  static Future<void> markAppAsLaunched() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, false);
    } catch (e) {
      print('Error marking app as launched: $e');
    }
  }

  /// Reset first launch status (useful for testing or debug purposes)
  static Future<void> resetFirstLaunchStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_firstLaunchKey);
    } catch (e) {
      print('Error resetting first launch status: $e');
    }
  }
}