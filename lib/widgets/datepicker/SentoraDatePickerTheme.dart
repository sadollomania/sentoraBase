import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SentoraDatePickerTheme with DiagnosticableTreeMixin {
  final TextStyle cancelStyle;
  final TextStyle doneStyle;
  final TextStyle itemStyle;
  final TextStyle titleStyle;
  final Color backgroundColor;
  final String title;

  final double containerHeight;
  final double titleHeight;
  final double itemHeight;

  const SentoraDatePickerTheme(
      {this.cancelStyle = const TextStyle(color: Colors.black54, fontSize: 16),
      this.doneStyle = const TextStyle(color: Colors.blue, fontSize: 16),
      this.itemStyle = const TextStyle(color: Color(0xFF000046), fontSize: 18),
      this.titleStyle = const TextStyle(color: Colors.blue, fontSize: 16),
      this.backgroundColor = Colors.white,
      this.containerHeight = 210.0,
      this.titleHeight = 44.0,
      this.itemHeight = 36.0,
      this.title = ""})
      : super();
}
