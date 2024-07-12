import 'package:Lino_app/common/widgets/appbar/appbar.dart';
import 'package:Lino_app/pages/test_map_screen.dart';
import 'package:Lino_app/utils/mock_data/mock_data.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: LinoAppBar(),
        body: TestMapScreen(bboxes: MockData.getBookBoxes()),
        // bottomNavigationBar: NavigationMenu(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed('/add-bookbox');
          },
          child: Icon(Icons.add),
        ));
  }
}
