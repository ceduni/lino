import 'package:Lino_app/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_services.dart';
import '../../utils/constants/colors.dart';
import '../search_bar/search_bar.dart';

class LinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int sourcePage;

  const LinoAppBar({required this.sourcePage});

  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;
    try {
      final userService = UserService();
      final user = await userService.getUser(token);
      return user['user'] != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        bool isLoggedIn = snapshot.data ?? false;

        return AppBar(
          backgroundColor: LinoColors.accent,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: Icon(isLoggedIn ? Icons.person : Icons.login),
                    color: isLoggedIn ? LinoColors.primary : null,
                    onPressed: () {
                      if (!isLoggedIn) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: LinoSearchBar(sourcePage: sourcePage),
                  ),
                ),
                if (isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {
                        // Add your notification handler here
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
