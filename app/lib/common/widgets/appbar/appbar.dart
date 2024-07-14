import 'package:Lino_app/common/widgets/appbar/greeting_user_bar.dart';
import 'package:Lino_app/common/widgets/appbar/search_bar.dart';
import 'package:flutter/material.dart';

// TODO: add option go back button as argument for certain pages
class LinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(120); // Adjust the height as needed

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue, // Customize the app bar color
      flexibleSpace: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GreetingUserBar(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: LinoSearchBar(),
            ),
          ],
        ),
      ),
    );
  }
}
