import 'package:flutter/material.dart';

class SntIconButton extends StatelessWidget {
  SntIconButton({
    @required this.iconData,
    @required this.onPressed,
    this.disabled = false,
    this.fontSize = 30,
    this.edgeInsetsGeometry = const EdgeInsets.all(10.0),
    this.buttonColor = const Color(0xFF42A5F5),
    this.circularRadius = 10,
    this.iconColor = Colors.teal,
    this.disabledColor = Colors.black26,
    this.enabledColor = Colors.white,
  });

  final IconData iconData;
  final GestureTapCallback onPressed;
  final bool disabled;
  final double fontSize;
  final EdgeInsetsGeometry edgeInsetsGeometry;
  final Color buttonColor;
  final double circularRadius;
  final MaterialColor iconColor;
  final MaterialColor disabledColor;
  final MaterialColor enabledColor;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        padding: edgeInsetsGeometry,
        color: buttonColor,
        child: Icon(
          iconData,
          size: fontSize,
          color: iconColor,
        ),
        textColor: disabled ? disabledColor : enabledColor,
        onPressed: disabled ? null : onPressed,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(circularRadius)));
  }
}
