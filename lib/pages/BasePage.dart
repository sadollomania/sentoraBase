import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sentora_base/model/AppBarActionHolder.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

abstract class BasePage extends StatefulWidget {
  final String Function(BuildContext context) pageTitle;
  final Widget Function(BuildContext context) body;

  final List<AppBarActionHolder> topBarActions;
  final Color safeAreaColor;
  final String Function(BuildContext context) popText;
  final String Function(BuildContext context) popTitle;
  final String Function(BuildContext context) popCancelTitle;
  final String Function(BuildContext context) popOkTitle;
  final List<String> Function(BuildContext context) loadStateHeaders;

  BasePage({
    @required this.pageTitle,
    @required this.body,
    this.topBarActions,
    this.popText,
    this.loadStateHeaders,
    Color safeAreaColor,
    String Function(BuildContext context) popTitle,
    String Function(BuildContext context) popCancelTitle,
    String Function(BuildContext context) popOkTitle,
  })
      :
        this.safeAreaColor = safeAreaColor ?? ConstantsBase.defaultButtonColor
  , this.popTitle = popTitle ?? "Uyarı"
  , this.popCancelTitle = popCancelTitle ?? "İptal"
  , this.popOkTitle = popOkTitle ?? "Çık"
  , assert(pageTitle != null)
  , assert(body != null) {
    /*if(topBarActions != null) {
      topBarActions.forEach((appBarAction){
        expandedAppBarActions.add(Expanded(
            child: IconSlideAction(
                caption: appBarAction.caption,
                color: appBarAction.color,
                icon: appBarAction.icon,
                onTap: (){
                  appBarAction.onTap(context, _selectedKayit, baseModelPageId, _scaffoldKey);
                }
            )
        ));
      });
    }*/
  }

  @override
  State<StatefulWidget> createState() => new _BasePageState();
}

class _BasePageState extends State<BasePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final String _pageId = ConstantsBase.getRandomUUID();
  int loadState = 0;

  Future<bool> _willPopCallback(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.popTitle(context)),
          content: Text(widget.popText(context)),
          actions: <Widget>[
            FlatButton(
              child: Text(widget.popCancelTitle(context)),
              onPressed: () {
                NavigatorBase.pop(false);
              },
            ),
            FlatButton(
              child: Text(widget.popOkTitle(context)),
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
  void initState() {
    super.initState();
    /*if(widget.initStateFunction != null) {
      loginSubscription = ConstantsBase.eventBus.on<AnaSayfaUpdateStateEvent>().listen((event){
        _updateState();
      });
      widget.initStateFunction();
    }*/
  }

  @override
  void dispose() {
    /*if(widget.initStateFunction != null) {
      loginSubscription.cancel();
    }*/
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget retWidget;
    Widget scaffoldWidget = Container(
        color: widget.safeAreaColor,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(widget.pageTitle(context)),
            centerTitle: true,
            /*bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(width: 1.0, color: Colors.blue.shade300),),
                ),
                child: Row(
                    children: []..addAll(widget.topBarActions)
                )
              )
            )*/
          ),
          body: widget.loadStateHeaders != null && loadState < widget.loadStateHeaders(context).length ? Container(alignment: Alignment.center, child:Text(widget.loadStateHeaders(context)[loadState])) : widget.body(context)
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