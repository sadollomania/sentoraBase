import 'package:flutter/material.dart';

abstract class WillPopState<T extends StatefulWidget> extends State<T> {

  String getAppTitle();
  Widget getBodyContent();
  String getWillPopTitle();
  String getWillPopContentStr();
  List<String> getWillPopButtonsStrs();
  List<VoidCallback> getWillPopButtonsFuncs();
  void beforeDispose();
  void afterDispose();
  void beforeInitState();
  void afterInitState();

  Future<bool> _willPopCallback(BuildContext context) {
    List<String> buttonStrs = getWillPopButtonsStrs();
    List<VoidCallback> buttonFuncs = getWillPopButtonsFuncs();
    List<Widget> buttons = List<Widget>();
    for(int i = 0, len = buttonStrs.length; i < len; ++i) {
      buttons.add(FlatButton(
        child: Text(buttonStrs[i]),
        onPressed: buttonFuncs[i],
      ));
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getWillPopTitle()),
          content: Text(getWillPopContentStr()),
          actions: buttons,
        );
      },
    ) ?? false;
  }

  @override
  void dispose() {
    beforeDispose();
    super.dispose();
    afterDispose();
  }

  @override
  void initState() {
    beforeInitState();
    super.initState();
    afterInitState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title : Text(getAppTitle()),
          centerTitle: true,
        ),
        body: SafeArea(
          child: getBodyContent(),
        )
      ),
      onWillPop: () => _willPopCallback(context),
    );
  }

}