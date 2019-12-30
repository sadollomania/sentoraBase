import 'package:flutter/material.dart';
import 'package:sentora_base/model/StateData.dart';

class AppBarActionHolder {
  String caption;
  Color color;
  IconData icon;
  Future<void> Function(StateData stateData) onTap;

  AppBarActionHolder({
    @required this.caption,
    @required this.color,
    @required this.icon,
    @required this.onTap,
  });
}