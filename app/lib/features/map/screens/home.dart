import 'package:Lino_app/common/widgets/appbar/appbar.dart';
import 'package:Lino_app/common/widgets/appbar/greeting_user_bar.dart';
import 'package:Lino_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:Lino_app/utils/device/device_utility.dart';

import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MapScreenContainer());
  }
}

class MapScreenContainer extends StatelessWidget {
  const MapScreenContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderContainer(),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            child: Container(
                color: Colors.blue,
                child: Center(child: Text("section1 placeholder"))),
          ),
        )
      ],
    );
  }
}

class HeaderContainer extends StatelessWidget {
  const HeaderContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        /// TODO: change height if necessary for the searchbar
        child: LinoAppBar(title: GreetingUserBar(), actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, color: Colors.black)),
        ]),
      ),
      LinoSearchContainer(
        text: 'Search a book',
      )
    ]);
  }
}
