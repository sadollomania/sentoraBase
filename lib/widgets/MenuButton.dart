import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  MenuButton({@required this.title, @required this.onPressed, this.disabled = false});
  final String title;
  final GestureTapCallback onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      padding: const EdgeInsets.all(10.0),
      color: Color(0xFF42A5F5),
      child: Text(
          title,
          style: TextStyle(fontSize: 30)
      ),
      textColor: disabled ? Colors.black26 : Colors.white,
      onPressed: disabled ? null : onPressed,
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))
    );
  }
}