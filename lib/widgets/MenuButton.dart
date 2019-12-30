import 'package:flutter/material.dart';
import 'dart:math';

import 'package:sentora_base/utils/ConstantsBase.dart';

class MenuButton extends StatefulWidget {
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
    this.labelWidth,
    double height,
  }) : this.iconColor = iconColor ?? ConstantsBase.defaultIconColor,
        this.fontSize = fontSize ?? 30,
        this.height = height ?? 40,
        assert(title != null || iconData != null || image != null),
        assert(iconData == null || image == null),
        assert(iconFlex != null),
        assert(textFlex != null);

  final String title;
  final IconData iconData;
  final Image image;
  final Future<void> Function() onPressed;
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
  final double height;

  @override
  State<StatefulWidget> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool running = false;

  @override
  Widget build(BuildContext context) {
    Widget  textWidget;
    List<Widget> rowWidgetList = List<Widget>();
    if(running) {
      rowWidgetList.add(CircularProgressIndicator());
      rowWidgetList.add(SizedBox(width: 2,));
    }

    if(widget.iconData != null) {
      rowWidgetList.add(
        Expanded(
          flex: widget.iconFlex,
          child: LayoutBuilder(
              builder: (context, constraint){
              return Icon(
                widget.iconData,
                size: min(constraint.biggest.width, constraint.biggest.height),
                color: widget.iconColor,
              );
            }
          )
        )
      );
    }

    if(widget.image != null) {
      rowWidgetList.add(
        Expanded(
          flex: widget.iconFlex,
          child: LayoutBuilder(
            builder: (context, constraint) {
              return Container(
                width: widget.image.width ?? 50,
                height: widget.image.height ?? 50,
                child: widget.image,
              );
            }
          )
        )
      );
    }

    if(widget.title != null) {
      Text tmpTextWidget = Text(widget.title, style: TextStyle(fontSize: widget.fontSize), overflow: TextOverflow.ellipsis,);
      if(widget.labelWidth != null) {
        textWidget = SizedBox(
          width: widget.labelWidth,
          child: tmpTextWidget,
        );
      } else {
        textWidget = tmpTextWidget;
      }

      rowWidgetList.add(
        Expanded(
          flex: widget.textFlex,
          child: Center(
            child: textWidget,
          ),
        )
      );
    }

    return RaisedButton(
        padding: widget.edgeInsetsGeometry,
        color: widget.buttonColor,
        child: Container(height: widget.height,child:Row( crossAxisAlignment: CrossAxisAlignment.stretch, children: rowWidgetList )), // Text(title, style: TextStyle(fontSize: fontSize)),
        textColor: widget.disabled || running ? widget.disabledColor : widget.enabledColor,
        onPressed: widget.disabled || running ? null : () async{
          if(mounted) {
            setState(() {
              running = true;
            });
          }
          await widget.onPressed();
          if(mounted) {
            setState(() {
              running = false;
            });
          }
          return;
        },
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(widget.circularRadius)));
  }

}
