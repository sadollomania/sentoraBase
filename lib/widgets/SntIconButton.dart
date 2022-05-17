import 'package:flutter/material.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

class SntIconButton extends StatefulWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String? caption;
  final Color? foregroundColor;
  final Future<void> Function()? onTap;
  final Color color;
  final Color disabledColor;
  final bool disabled;
  final bool animate;
  final Duration animateDuration;

  SntIconButton({
    Key? key,
    this.icon,
    this.iconWidget,
    this.caption,
    this.foregroundColor,
    this.onTap,
    bool? disabled,
    Color? color,
    Color? disabledColor,
    bool? animate,
    Duration? animateDuration,
  })  : color = color ?? ConstantsBase.defaultButtonColor,
        disabledColor = disabledColor ?? ConstantsBase.defaultDisabledColor,
        disabled = disabled ?? false,
        animate = animate ?? true,
        animateDuration = animateDuration ?? Duration(milliseconds: 300),
        assert(icon != null || iconWidget != null, 'Either set icon or iconWidget.'),
        super(key:key);

  @override
  State<StatefulWidget> createState() => _SntIconButtonState();
}

class _SntIconButtonState extends State<SntIconButton> {
  bool running = false;

  @override
  Widget build(BuildContext context) {
    final Color estimatedColor =
    ThemeData.estimateBrightnessForColor(widget.color) == Brightness.light
        ? Colors.black
        : Colors.white;

    final List<Widget> widgets = [];
    if (widget.icon != null) {
      widgets.add(
        Flexible(
          child: new Icon(
            widget.icon!,
            color: widget.foregroundColor ?? estimatedColor,
          ),
        ),
      );
    }

    if (widget.iconWidget != null) {
      widgets.add(
        Flexible(child: widget.iconWidget!),
      );
    }

    if (widget.caption != null) {
      widgets.add(
        Flexible(
          child: Text(
            widget.caption!,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .primaryTextTheme
                .caption!
                .copyWith(color: widget.foregroundColor ?? estimatedColor),
          ),
        ),
      );
    }

    var inkwell = InkWell(
        onTap: () async{
          if(!widget.disabled && !running) {
            if(mounted) {
              setState(() {
                running = true;
              });
            }
            if(widget.onTap != null) {
              await widget.onTap!();
            }
            if(mounted) {
              setState(() {
                running = false;
              });
            }
          }
        },
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widgets,
                  ),
                ),
              )
            ]
            ..addAll(running ? [Container(child: Center(child: CircularProgressIndicator(),),)] : []),
          ),
        ),
    );

    return GestureDetector(
      child: widget.animate ? AnimatedContainer(
        duration: widget.animateDuration,
        color: widget.disabled || running ? widget.disabledColor : widget.color,
        child: inkwell
      ) : Container(
        color: widget.disabled || running ? widget.disabledColor : widget.color,
        child: inkwell
      )
    );
  }
}