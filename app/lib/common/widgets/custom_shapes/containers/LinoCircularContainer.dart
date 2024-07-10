import 'package:Lino_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class LinoCircularContainer extends StatelessWidget {
  const LinoCircularContainer(
      {super.key,
      this.child,
      this.width = 400,
      this.height = 400,
      this.radius = 400,
      this.padding = 0,
      this.backgroundColor = LinoColors.primaryBackground});

  final double? width;
  final double? height;
  final double radius;
  final double padding;
  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: backgroundColor),
        child: child);
  }
}
