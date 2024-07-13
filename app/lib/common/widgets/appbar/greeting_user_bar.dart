import 'package:Lino_app/pages/profile_screen.dart';
import 'package:Lino_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

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
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
          icon: const Icon(Icons.person, color: Colors.black),
        ),
        const SizedBox(width: 8.0), // Add space between icon and text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LinoTexts.homeAppbarTitle,
              style: Theme.of(context).textTheme.labelSmall!.apply(
                  color: Colors.black), // Replace with LinoColors.textPrimary
            ),
            Text(
              LinoTexts.homeAppbarSubTitle,
              style: Theme.of(context).textTheme.labelLarge!.apply(
                  color: Colors.black), // Replace with LinoColors.textPrimary
            ),
          ],
        ),
      ],
    );
  }
}
