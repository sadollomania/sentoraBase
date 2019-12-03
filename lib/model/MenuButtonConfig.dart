import 'package:flutter/material.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

class MenuButtonConfig {
  final String title;
  final IconData iconData;
  final Widget navPage;
  final void Function() onPressed;
  final int iconFlex;
  final int textFlex;
  MenuButtonConfig({
    this.title,
    this.iconData,
    this.navPage,
    this.onPressed,
    this.iconFlex = ConstantsBase.defaultMenuButtonIconFlex,
    this.textFlex = ConstantsBase.defaultMenuButtonTextFlex,
  }) :
      assert(title != null || iconData != null),
      assert(navPage != null || onPressed != null);
}