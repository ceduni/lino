import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:Lino_app/utils/device/device_utility.dart';
import 'package:flutter/material.dart';

class LinoSearchContainer extends StatelessWidget {
  const LinoSearchContainer({
    super.key,
    required this.text,
    this.icon = Icons.search,
    this.showBackground = true,
    this.showBorder = true,
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(LinoSizes.defaultSpace),
      child: Container(
          width: LinoDeviceUtils.getScreenWidth(context),
          padding: EdgeInsets.symmetric(horizontal: LinoSizes.md),
          decoration: BoxDecoration(
              color: showBackground
                  ? Colors.transparent
                  : LinoColors.primaryBackground,
              borderRadius: BorderRadius.circular(LinoSizes.cardRadiusLg),
              border: showBorder ? Border.all(color: Colors.black) : null),
          child: Row(
            children: [
              Icon(icon, color: LinoColors.textPrimary),
              const SizedBox(width: LinoSizes.spaceBtwItems),
              Text('Search a book',
                  style: Theme.of(context).textTheme.bodySmall)
            ],
          )),
    );
  }
}
