import 'package:Lino_app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/controllers/locale_controller.dart';

class LanguageSelector extends StatefulWidget {
  final LanguageSelectorStyle style;
  final double? iconSize;
  final Color? iconColor;

  const LanguageSelector({
    super.key,
    this.style = LanguageSelectorStyle.iconButton,
    this.iconSize,
    this.iconColor,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  // Debouncing variables
  bool _isChangingLanguage = false;
  DateTime? _lastChangeTime;
  static const Duration _debounceDuration = Duration(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocaleController>(
      builder: (controller) {
        final currentLang = _supportedLanguages.firstWhere(
              (lang) => lang.locale.languageCode == controller.locale.value.languageCode,
          orElse: () => _supportedLanguages.first,
        );

        return PopupMenuButton<Locale>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(currentLang.flag, style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(currentLang.code.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
          onSelected: (Locale locale) {
            _changeLanguageWithDebouncing(locale);
          },
          itemBuilder: (BuildContext context) => _supportedLanguages.map((lang) {
            final isSelected = controller.locale.value.languageCode == lang.locale.languageCode;
            return PopupMenuItem<Locale>(
              value: lang.locale,
              child: Row(
                children: [
                  Text(lang.flag, style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(child: Text(lang.name)),
                  if (isSelected)
                    Icon(Icons.check, color: Colors.green, size: 16),
                ],
              ),
            );
          }).toList(),
        );
      },
    );

  }

  // Debounced language change method
  void _changeLanguageWithDebouncing(Locale locale) {
    final now = DateTime.now();

    // Check if we're already changing language or if it's too soon
    if (_isChangingLanguage ||
        (_lastChangeTime != null && now.difference(_lastChangeTime!) < _debounceDuration)) {
      return;
    }

    _isChangingLanguage = true;
    _lastChangeTime = now;

    try {
      final localeController = Get.find<LocaleController>();

      // Check if the locale is actually different
      if (localeController.locale.value.languageCode == locale.languageCode) {
        _isChangingLanguage = false;
        return;
      }

      localeController.changeLocale(locale);

      // Find the language name for the snackbar
      final selectedLanguage = _supportedLanguages.firstWhere(
            (lang) => lang.locale.languageCode == locale.languageCode,
        orElse: () => _supportedLanguages.first,
      );

      CustomSnackbars.success(
          'Language Changed',
          'Language changed to ${selectedLanguage.name}'
      );
    } catch (e) {
      print('Error changing language: $e');
    } finally {
      // Reset the flag after a delay
      Future.delayed(_debounceDuration, () {
        if (mounted) {
          setState(() {
            _isChangingLanguage = false;
          });
        }
      });
    }
  }
}

enum LanguageSelectorStyle {
  iconButton,
  dropdown,
  fab,
  currentFlag,
}

class LanguageItem {
  final String name;
  final String code;
  final String flag;
  final Locale locale;

  LanguageItem({
    required this.name,
    required this.code,
    required this.flag,
    required this.locale,
  });
}

// Add your supported languages here
final List<LanguageItem> _supportedLanguages = [
  LanguageItem(
    name: 'English',
    code: 'en',
    flag: '🇺🇸',
    locale: Locale('en'),
  ),
  LanguageItem(
    name: 'Français',
    code: 'fr',
    flag: '🇫🇷',
    locale: Locale('fr'),
  ),
];
