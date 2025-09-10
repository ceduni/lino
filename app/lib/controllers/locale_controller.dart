import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  static const String _localeKey = 'selected_locale';

  Rx<Locale> locale = Locale('en').obs;

  final List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    // ...
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);

    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      final newLocale = Locale(parts[0], parts.length > 1 ? parts[1] : null);

      if (supportedLocales.any((l) => l.languageCode == newLocale.languageCode)) {
        locale.value = newLocale;
        Get.updateLocale(newLocale);
      }
    }
  }

  Future<void> changeLocale(Locale newLocale) async {
    if (supportedLocales.any((l) => l.languageCode == newLocale.languageCode)) {
      locale.value = newLocale;
      Get.updateLocale(newLocale);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, '${newLocale.languageCode}_${newLocale.countryCode ?? ''}');
    }
  }
}