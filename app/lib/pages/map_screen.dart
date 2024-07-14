import 'package:Lino_app/pages/test_map_screen.dart';
import 'package:Lino_app/utils/mock_data/mock_data.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TestMapScreen(bboxes: MockData.getBookBoxes()),
    );
  }
}
