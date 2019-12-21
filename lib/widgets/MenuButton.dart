import 'package:flutter/material.dart';
import 'dart:math';

import 'package:sentora_base/utils/ConstantsBase.dart';

class MenuButton extends StatelessWidget {
  MenuButton({
    @required this.onPressed,
    this.title,
    this.iconData,
    this.image,
    this.disabled = false,
    double fontSize,
    this.edgeInsetsGeometry = const EdgeInsets.all(10.0),
    this.buttonColor = ConstantsBase.defaultButtonColor,
    Color iconColor,
    this.circularRadius = 10,
    this.disabledColor = ConstantsBase.defaultDisabledColor,
    this.enabledColor = ConstantsBase.defaultEnabledColor,
    this.iconFlex = ConstantsBase.defaultMenuButtonIconFlex,
    this.textFlex = ConstantsBase.defaultMenuButtonTextFlex,
    this.labelWidth
  }) : this.iconColor = iconColor ?? ConstantsBase.defaultIconColor,
  this.fontSize = fontSize ?? 30,
  assert(title != null || iconData != null || image != null),
  assert(iconData == null || image == null),
  assert(iconFlex != null),
  assert(textFlex != null);

  final String title;
  final IconData iconData;
  final Image image;
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
    Widget iconImageWidget, textWidget, combinedWidget;
    if(iconData != null) {
      iconImageWidget = LayoutBuilder(builder: (context, constraint){
        return Icon(
          iconData,
          size: min(constraint.biggest.width, constraint.biggest.height),
          color: iconColor,
        );
      });
    }

    if(image != null) {
      iconImageWidget = LayoutBuilder(builder: (context, constraint) {

        return Container(
          width: image.width ?? 50,
          height: image.height ?? 50,
          child: image,
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

    if(iconImageWidget != null && textWidget != null) {
      combinedWidget = Row(
          children: <Widget>[
            Expanded(
              flex: iconFlex,
              child: iconImageWidget,
            ),
            SizedBox(width: 2,),
            Expanded(
              flex: textFlex,
              child: Center(
                child: textWidget,
              ),
            ),
          ]
      );
    } else if(iconImageWidget != null) {
      combinedWidget = iconImageWidget;
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
