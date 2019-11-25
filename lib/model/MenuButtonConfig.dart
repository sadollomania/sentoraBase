import 'package:flutter/material.dart';

class MenuButtonConfig {
  final String title;
  final Widget navPage;
  final void Function() onPressed;
  MenuButtonConfig({
    @required this.title,
    this.navPage,
    this.onPressed
  }) : assert(navPage != null || onPressed != null);
}