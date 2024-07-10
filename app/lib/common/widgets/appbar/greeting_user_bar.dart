import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class GreetingUserBar extends StatelessWidget {
  const GreetingUserBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.person, color: Colors.black),
      ),
      Padding(padding: EdgeInsets.zero),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LinoTexts.homeAppbarTitle,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .apply(color: LinoColors.textPrimary)),
          Text(LinoTexts.homeAppbarSubTitle,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .apply(color: LinoColors.textPrimary)),
        ],
      ),
    ]);
  }
}
