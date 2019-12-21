import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentora_base/model/MenuButtonConfig.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';
import 'package:sentora_base/model/AnaSayfaUpdateStateEvent.dart';

abstract class ButtonNavPage extends StatefulWidget {
  final String Function(BuildContext context) pageTitle;
  final List<MenuButtonConfig> Function(BuildContext context) menuConfig;
  final String Function(BuildContext context) willPopScopeText;
  final List<String> Function(BuildContext context) loadStateHeaders;
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
  assert(pageTitle != null),
  assert(menuConfig != null),
  assert((loadStateHeaders == null && initStateFunction == null) || (loadStateHeaders != null && initStateFunction != null));


  @override
  State<StatefulWidget> createState() => new _ButtonNavPageState();
}

class _ButtonNavPageState extends State<ButtonNavPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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
    widget.menuConfig(context).forEach((menuButtonConfig){
      retList.add(MenuButton(
          title : menuButtonConfig.title,
          iconData: menuButtonConfig.iconData,
          image: menuButtonConfig.image,
          iconColor: menuButtonConfig.iconColor,
          iconFlex: menuButtonConfig.iconFlex,
          textFlex: menuButtonConfig.textFlex,
          fontSize: menuButtonConfig.fontSize,
          onPressed: (){
            if(menuButtonConfig.onPressed != null) {
              menuButtonConfig.onPressed(context, _scaffoldKey);
            } else {
              NavigatorBase.push(menuButtonConfig.navPage);
            }
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
          content: Text(widget.willPopScopeText(context)),
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
    Widget mainWidget = Container(
        color: ConstantsBase.defaultButtonColor,
        child: SafeArea(
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(widget.pageTitle(context)),
              centerTitle: true,
            ),
            body:Container(
                alignment: Alignment(0.0, 0.0),
                child: widget.loadStateHeaders != null && loadState < widget.loadStateHeaders(context).length ? Container(alignment: Alignment.center, child:Text(widget.loadStateHeaders(context)[loadState])) : LayoutBuilder(
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
        )
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