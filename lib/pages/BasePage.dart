import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentora_base/events/LocaleChangedEvent.dart';
import 'package:sentora_base/events/UpdatePageStateEvent.dart';
import 'package:sentora_base/model/StateData.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

abstract class BasePage extends StatefulWidget {
  final dynamic Function(StateData stateData) pageTitle;
  final Widget Function(StateData stateData) body;

  final dynamic Function(StateData stateData)? initialTag;

  final PreferredSizeWidget Function(StateData stateData)? topBar;
  final Widget Function(StateData stateData)? bottomBar;
  final void Function(StateData stateData)? updateTag;
  final String Function(StateData stateData)? popText;
  final String Function(StateData stateData)? popTitle;
  final String Function(StateData stateData)? popCancelTitle;
  final String Function(StateData stateData)? popOkTitle;
  final void Function(StateData stateData)? initStateFunction;
  final void Function(StateData stateData)? didChangeDependenciesFunction;
  final void Function(StateData stateData)? disposeFunction;
  final void Function(StateData stateData)? afterRender;
  final int? tabLength;
  final void Function(StateData stateData)? localeChanged;

  BasePage({
    required this.pageTitle,
    required this.body,

    Color? safeAreaColor,
    this.topBar,
    this.bottomBar,
    this.initialTag,
    this.updateTag,
    this.popText,
    this.popTitle,
    this.popCancelTitle,
    this.popOkTitle,
    this.initStateFunction,
    this.didChangeDependenciesFunction,
    this.disposeFunction,
    this.afterRender,
    this.tabLength,
    this.localeChanged,
  }) :
    assert((((popText == null) == (popCancelTitle == null)) == (popOkTitle == null)) == (popTitle == null));

  @override
  State<StatefulWidget> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> with SingleTickerProviderStateMixin{
  TabController? _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final String _pageId = ConstantsBase.getRandomUUID();
  late StateData stateData;
  late StreamSubscription updateStateSubscription;
  StreamSubscription? localeChangedSubscription;
  
  Future<bool> _willPopCallback(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.popTitle!(stateData)),
          content: Text(widget.popText!(stateData)),
          actions: <Widget>[
            TextButton(
              child: Text(widget.popCancelTitle!(stateData)),
              onPressed: () async{
                await NavigatorBase.pop(false);
                return;
              },
            ),
            TextButton(
              child: Text(widget.popOkTitle!(stateData)),
              onPressed: () async{
                await NavigatorBase.pop(true);
                return;
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  void initState() {
    if(widget.tabLength != null) {
      _tabController = new TabController(length: widget.tabLength!, vsync: this);
    }
    stateData = StateData(
      context: context,
      scaffoldKey: _scaffoldKey,
      pageId: _pageId,
      tabController : _tabController,
    );
    super.initState();
    updateStateSubscription = ConstantsBase.eventBus.on<UpdatePageStateEvent>().listen((event){
      if(event.pageId == _pageId) {
        if(mounted) {
          setState(() {});
        }
      }
    });
    if(widget.localeChanged != null) {
      localeChangedSubscription = ConstantsBase.eventBus.on<LocaleChangedEvent>().listen((event){
        if(mounted) {
          widget.localeChanged!(stateData);
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.afterRender?.call(stateData));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    stateData.tag = widget.initialTag?.call(stateData) ?? {};
    widget.initStateFunction?.call(stateData);
    widget.didChangeDependenciesFunction?.call(stateData);
  }

  @override
  void dispose() {
    updateStateSubscription.cancel();
    localeChangedSubscription?.cancel();
    widget.disposeFunction?.call(stateData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget retWidget;
    Widget scaffoldWidget = Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: widget.pageTitle(stateData) is Widget ? widget.pageTitle(stateData) : Text(widget.pageTitle(stateData)),
        centerTitle: true,
        bottom: widget.topBar == null ? PreferredSize(preferredSize: Size.fromHeight(0), child: Container(height: 0,),) : widget.topBar!(stateData)
      ),
      body: SafeArea(child:ConstantsBase.wrapWidgetWithBanner(widget.body(stateData)),),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: Container(
          height: widget.bottomBar != null ?  60 : 0,
          child: widget.bottomBar != null ? widget.bottomBar!(stateData) : SizedBox(),
        )
      )
    );
    if(widget.popText != null) {
      retWidget = WillPopScope(
        child : scaffoldWidget,
        onWillPop: () => _willPopCallback(context),
      );
    } else {
      retWidget = scaffoldWidget;
    }
    return retWidget;
  }
}