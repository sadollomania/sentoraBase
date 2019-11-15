import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  MenuButton({
    @required this.title,
    @required this.onPressed,
    this.disabled = false,
    this.fontSize = 30,
    this.edgeInsetsGeometry = const EdgeInsets.all(10.0),
    this.iconColor = const Color(0xFF42A5F5),
    this.circularRadius = 10,
    this.disabledColor = Colors.black26,
    this.enabledColor = Colors.white,
  });

  final String title;
  final GestureTapCallback onPressed;
  final bool disabled;
  final double fontSize;
  final EdgeInsetsGeometry edgeInsetsGeometry;
  final Color iconColor;
  final double circularRadius;
  final Color disabledColor;
  final Color enabledColor;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        padding: edgeInsetsGeometry,
        color: iconColor,
        child: Text(title, style: TextStyle(fontSize: fontSize)),
        textColor: disabled ? disabledColor : enabledColor,
        onPressed: disabled ? null : onPressed,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(circularRadius)));
  }
}
