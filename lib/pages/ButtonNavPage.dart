import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentora_base/model/MenuButtonConfig.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';
import 'package:sentora_base/model/AnaSayfaUpdateStateEvent.dart';

abstract class ButtonNavPage extends StatefulWidget {
  final String pageTitle;
  final List<MenuButtonConfig> menuConfig;
  final String willPopScopeText;
  final List<String> loadStateHeaders;
  final Function initStateFunction;
  final double screenWidthRatio;

  ButtonNavPage({
    @required this.pageTitle,
    @required this.menuConfig,
    this.willPopScopeText,
    this.loadStateHeaders,
    this.initStateFunction,
    this.screenWidthRatio = 0.8,
  }) :
  assert(pageTitle.isNotEmpty),
  assert(menuConfig != null),
  assert((loadStateHeaders == null && initStateFunction == null) || (loadStateHeaders != null && initStateFunction != null));


  @override
  State<StatefulWidget> createState() => new _ButtonNavPageState();
}

class _ButtonNavPageState extends State<ButtonNavPage> {
  int loadState = 0;
  StreamSubscription loginSubscription;

  void _updateState() {
    ++loadState;
    setState((){});
  }

  @override
  void initState() {
    super.initState();
    if(widget.initStateFunction != null) {
      loginSubscription = ConstantsBase.eventBus.on<AnaSayfaUpdateStateEvent>().listen((event){
        _updateState();
      });
      widget.initStateFunction();
    }
  }

  @override
  void dispose() {
    if(widget.initStateFunction != null) {
      loginSubscription.cancel();
    }
    super.dispose();
  }

  List<Widget> _getMenuItems(BuildContext context) {
    List<Widget> retList = List<Widget>();
    widget.menuConfig.forEach((menuButtonConfig){
      retList.add(MenuButton(
          title : menuButtonConfig.title,
          iconData: menuButtonConfig.iconData,
          iconFlex: menuButtonConfig.iconFlex,
          textFlex: menuButtonConfig.textFlex,
          onPressed: menuButtonConfig.onPressed ?? () {
            NavigatorBase.push(menuButtonConfig.navPage);
          }));
      retList.add(SizedBox(height: 10,));
    });
    return retList;
  }

  Future<bool> _willPopCallback(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Uyarı"),
          content: Text(widget.willPopScopeText),
          actions: <Widget>[
            FlatButton(
              child: Text("İptal"),
              onPressed: () {
                NavigatorBase.pop(false);
              },
            ),
            FlatButton(
              child: Text("Çık"),
              onPressed: () {
                NavigatorBase.pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Widget retWidget;
    Widget mainWidget = Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
      ),
      body:SafeArea(
        child:Container(
          alignment: Alignment(0.0, 0.0),
          child: loadState < widget.loadStateHeaders.length ? Container(alignment: Alignment.center, child:Text(widget.loadStateHeaders[loadState])) : LayoutBuilder(
            builder: (context, constraint){
              return Container(
                width: constraint.biggest.width * widget.screenWidthRatio,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _getMenuItems(context)
                ),
              );
            },
          )
        ),
      ),
    );
    if(widget.willPopScopeText != null) {
      retWidget = WillPopScope(
        child : mainWidget,
        onWillPop: () => _willPopCallback(context),
      );
    } else {
      retWidget = mainWidget;
    }

    return retWidget;
  }
}