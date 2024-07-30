import 'package:flutter/material.dart';
import 'package:Lino_app/pages/appbar/greeting_user_bar.dart';
import 'package:Lino_app/pages/search_bar/search_bar.dart';

class LinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final int sourcePage; // Add sourcePage parameter

  const LinoAppBar({this.showBackButton = false, required this.sourcePage}); // Make sourcePage required

  @override
  Size get preferredSize => Size.fromHeight(120); // Adjust the height as needed

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(125, 200, 237, 1), // Customize the app bar color
      leading: showBackButton
          ? IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      )
          : null,
      flexibleSpace: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  GreetingUserBar(),
                  // Maybe a hamburger menu or notification icon?
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: LinoSearchBar(sourcePage: sourcePage), // Pass sourcePage to LinoSearchBar
            ),
          ],
        ),
      ),
    );
  }
}
