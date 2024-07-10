import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:Lino_app/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LinoAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.zero,
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: showBackArrow
              ? IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back))
              : leadingIcon != null
                  ? IconButton(
                      onPressed: leadingOnPressed, icon: Icon(leadingIcon))
                  : null,
          title: title,
          actions: actions,
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(LinoDeviceUtils.getAppBarHeight());
}
