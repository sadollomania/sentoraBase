import 'package:flutter/material.dart';
import 'dart:math';

import 'package:sentora_base/utils/ConstantsBase.dart';

class MenuButton extends StatelessWidget {
  MenuButton({
    @required this.onPressed,
    this.title,
    this.iconData,
    this.disabled = false,
    this.fontSize = 30,
    this.edgeInsetsGeometry = const EdgeInsets.all(10.0),
    this.buttonColor = ConstantsBase.defaultButtonColor,
    this.iconColor = ConstantsBase.defaultIconColor,
    this.circularRadius = 10,
    this.disabledColor = ConstantsBase.defaultDisabledColor,
    this.enabledColor = ConstantsBase.defaultEnabledColor,
    this.iconFlex = ConstantsBase.defaultMenuButtonIconFlex,
    this.textFlex = ConstantsBase.defaultMenuButtonTextFlex,
    this.labelWidth
  }) :
  assert(title != null || iconData != null),
  assert(iconFlex != null),
  assert(textFlex != null);

  final String title;
  final IconData iconData;
  final GestureTapCallback onPressed;
  final bool disabled;
  final double fontSize;
  final EdgeInsetsGeometry edgeInsetsGeometry;
  final double circularRadius;
  final Color buttonColor;
  final Color iconColor;
  final Color disabledColor;
  final Color enabledColor;
  final int iconFlex;
  final int textFlex;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget, textWidget, combinedWidget;
    if(iconData != null) {
      iconWidget = LayoutBuilder(builder: (context, constraint){
        return Icon(
          iconData,
          size: min(constraint.biggest.width, constraint.biggest.height),
          color: iconColor,
        );
      });
    }
    if(title != null) {
      Text tmpTextWidget = Text(title, style: TextStyle(fontSize: fontSize), overflow: TextOverflow.ellipsis,);
      if(labelWidth != null) {
        textWidget = SizedBox(
          width: labelWidth,
          child: tmpTextWidget,
        );
      }
      textWidget = tmpTextWidget;
    }

    if(iconData != null && title != null) {
      combinedWidget = Row(
          children: <Widget>[
            Expanded(
              flex: iconFlex,
              child: iconWidget,
            ),
            SizedBox(width: 2,),
            Expanded(
              flex: textFlex,
              child: textWidget,
            ),
          ]
      );
    } else if(iconData != null) {
      combinedWidget = iconWidget;
    } else {
      combinedWidget = textWidget;
    }

    return RaisedButton(
        padding: edgeInsetsGeometry,
        color: buttonColor,
        child: combinedWidget, // Text(title, style: TextStyle(fontSize: fontSize)),
        textColor: disabled ? disabledColor : enabledColor,
        onPressed: disabled ? null : onPressed,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(circularRadius)));
  }
}
