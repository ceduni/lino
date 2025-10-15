// app/lib/vm/profile_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:Lino_app/l10n/app_localizations.dart';

class ProfileViewModel extends ChangeNotifier {
  String? _token;
  User? _user;
  bool _isLoading = true;
  String? _error;

  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token != null && _token!.isNotEmpty) {
        _user = await UserService().getUser(_token!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error loading user data';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnect(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.confirmlogout),
          content: Text(localizations.areyousureyouwantologout),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.logout),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Get.offAllNamed(AppRoutes.auth.login);
    }
  }
}