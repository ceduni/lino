import 'package:Lino_app/pages/profile/profile_page.dart';
import 'package:Lino_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/login_page.dart';

class GreetingUserBar extends StatelessWidget {
  const GreetingUserBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
          icon: const Icon(Icons.person, color: Colors.black),
        ),
        IconButton(
            onPressed: () async {
              // disconnect user
              var prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(prefs: prefs)));
            },
            icon: const Icon(Icons.remove, color: Colors.red)),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LinoTexts.homeAppbarTitle,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .apply(color: Colors.black),
            ),
            Text(
              LinoTexts.homeAppbarSubTitle,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .apply(color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }
}