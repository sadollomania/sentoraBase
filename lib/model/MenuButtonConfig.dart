import 'package:flutter/material.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

class MenuButtonConfig {
  final String title;
  final IconData iconData;
  final Widget navPage;
  final void Function(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) onPressed;
  final int iconFlex;
  final int textFlex;
  final Color iconColor;
  final double fontSize;
  MenuButtonConfig({
    this.title,
    this.iconData,
    this.navPage,
    this.onPressed,
    this.iconFlex = ConstantsBase.defaultMenuButtonIconFlex,
    this.textFlex = ConstantsBase.defaultMenuButtonTextFlex,
    this.iconColor,
    this.fontSize,
  }) :
      assert(title != null || iconData != null),
      assert(navPage != null || onPressed != null);
}