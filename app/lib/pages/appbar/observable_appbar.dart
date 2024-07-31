import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/pages/appbar/appbar.dart';

class ObservableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Rx<int> sourcePage;

  const ObservableAppBar({required this.sourcePage});

  @override
  Size get preferredSize => Size.fromHeight(120); // Adjust the height as needed

  @override
  Widget build(BuildContext context) {
    return Obx(() => LinoAppBar(sourcePage: sourcePage.value));
  }
}