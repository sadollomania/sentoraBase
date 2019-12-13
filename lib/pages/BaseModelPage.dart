import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sentora_base/model/AppBarActionHolder.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/pages/BaseModelDuzenleme.dart';
import 'package:sentora_base/pages/FilterDialog.dart';
import 'package:sentora_base/pages/SortDialog.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

import 'package:sentora_base/model/ModelDuzenlemeEvent.dart';
import 'package:sentora_base/model/SortChangedEvent.dart';
import 'package:sentora_base/model/FilterChangedEvent.dart';
import 'package:sqflite/sqflite.dart';

class BaseModelPage extends StatefulWidget {
  final String widgetModelName;
  final String pageTitle;
  final String getListQuery;
  final Row Function(BaseModel selectedKayit) constructButtonsRow;
  final int pageSize;
  final List<AppBarActionHolder> appBarActions;
  final bool addButtonExists;
  final bool editButtonExists;
  final bool deleteButtonExists;
  final String orderBy;

  BaseModelPage({
    @required this.widgetModelName,
    this.pageTitle,
    this.getListQuery,
    this.constructButtonsRow,
    this.pageSize,
    this.appBarActions,
    this.addButtonExists = false,
    this.editButtonExists = false,
    this.deleteButtonExists = false,
    this.orderBy,
  }) :
      assert(widgetModelName != null);
  /*assert((pageTitle == null && getListQuery == null && constructButtonsRow == null) ||
      (pageTitle != null && getListQuery != null && constructButtonsRow != null));*/

  @override
  State<StatefulWidget> createState() => new _BaseModelPageState(modelName: this.widgetModelName, pageTitle: pageTitle, getListQuery: getListQuery, constructButtonsRow: constructButtonsRow, pageSize : pageSize, appBarActions : appBarActions, orderBy: orderBy);
}

class _BaseModelPageState extends State<BaseModelPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String pageTitle;
  String getListQuery;
  String modelName;
  Row Function(BaseModel selectedKayit) constructButtonsRow;
  BaseModel ornekKayit;
  BaseModel _selectedKayit;
  int pageSize;
  int currentPage = 1;
  int totalCount = 0;
  int lastPage = 1;
  String orderBy;
  String baseModelPageId = ConstantsBase.getRandomUUID();
  Map<String, dynamic> filterMap;
  List<BaseModel> currentListData;
  StreamSubscription modelDuzenlemeSubscription;
  StreamSubscription sortChangedSubscription;
  StreamSubscription filterChangedSubscription;
  SlidableController slidableController = SlidableController();
  List<Expanded> expandedAppBarActions = List<Expanded>();

  _BaseModelPageState({
    @required this.modelName,
    @required this.pageTitle,
    @required this.getListQuery,
    @required this.constructButtonsRow,
    @required pageSize,
    List<AppBarActionHolder> appBarActions,
    String orderBy,
  }) :
        this.ornekKayit = BaseModel.createNewObject(modelName),
        this.pageSize = pageSize ?? ConstantsBase.pageSize {
    this.orderBy = orderBy ?? ornekKayit.defaultOrderBy;
    if(appBarActions != null) {
      appBarActions.forEach((appBarAction){
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
    }
  }

  void initState() {
    super.initState();
    modelDuzenlemeSubscription = ConstantsBase.eventBus.on<ModelDuzenlemeEvent>().listen((event){
      if(event.baseModelPageId == baseModelPageId) {
        refreshData();
      }
    });
    sortChangedSubscription = ConstantsBase.eventBus.on<SortChangedEvent>().listen((event){
      if(event.baseModelPageId == baseModelPageId) {
        refreshData(orderByPrm: event.newOrderBy);
      }
    });
    filterChangedSubscription = ConstantsBase.eventBus.on<FilterChangedEvent>().listen((event){
      if(event.baseModelPageId == baseModelPageId) {
        refreshData(filterMapPrm: event.filterMap);
      }
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => refreshData());
  }

  void dispose() {
    modelDuzenlemeSubscription.cancel();
    sortChangedSubscription.cancel();
    filterChangedSubscription.cancel();
    super.dispose();
  }

  void _showDialog(BaseModel kayit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Emin Misiniz?"),
          content: Text(ornekKayit.singleTitle + " " + kayit.getCombinedTitleValue() + " Silinecektir!"),
          actions: <Widget>[
            FlatButton(
              child: Text("İptal"),
              onPressed: () {
                NavigatorBase.pop();
              },
            ),
            FlatButton(
              child: Text("Sil"),
              onPressed: () {
                BaseModel.delete(kayit).then((_){
                  NavigatorBase.pop();
                  setState(() {
                    _selectedKayit = null;
                  });
                  ConstantsBase.eventBus.fire(ModelDuzenlemeEvent(baseModelPageId));
                }).catchError((e){
                  debugPrint(e.toString());
                  NavigatorBase.pop();
                  if(e is DatabaseException) {
                    ConstantsBase.showSnackBarLong(_scaffoldKey, BaseModel.convertDbErrorToStr(kayit, e));
                  } else {
                    ConstantsBase.showSnackBarLong(_scaffoldKey, e.toString());
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void dataLoaded(map, compCurrentPage, compOrderBy, compFilterMap) {
    int dataCnt = ConstantsBase.getTotalCountFormGetList(map);
    List<BaseModel> listData = ConstantsBase.getDataFormGetList(map);
    bool selectedKayitExists = false;
    if(_selectedKayit != null){
      for(int i = 0, len = listData.length; i < len; ++i) {
        if(listData[i].get("ID") == _selectedKayit.get("ID")) {
          selectedKayitExists = true;
          break;
        }
      }
    }
    int compLastPage = ((dataCnt * 1.0) / pageSize).ceil();
    if(compLastPage == 0) {
      compLastPage = 1;
    }
    if(compCurrentPage > compLastPage) {
      refreshData(currentPagePrm: compLastPage, orderByPrm: compOrderBy, filterMapPrm: compFilterMap);
      return;
    }

    setState(() {
      currentListData = listData;
      totalCount = dataCnt;
      lastPage = compLastPage;
      currentPage = compCurrentPage;
      orderBy = compOrderBy;
      filterMap = compFilterMap;
      _selectedKayit = selectedKayitExists ? _selectedKayit : null;
    });
  }

  void refreshData({int currentPagePrm, String orderByPrm, Map<String, dynamic> filterMapPrm}) {
    int compCurrentPage = currentPagePrm ?? currentPage;
    String compOrderBy = orderByPrm ?? orderBy;
    Map<String, dynamic> compFilterMap = filterMapPrm ?? filterMap;

    BaseModel.getList(ornekKayit, rawQuery: getListQuery, pageSize: pageSize, currentPage: compCurrentPage, orderBy: compOrderBy, filterMap: compFilterMap).then((map){
      dataLoaded(map, compCurrentPage, compOrderBy, compFilterMap);
    });
  }

  void showSortPopup() {
    showDialog(
      context: context,
      builder: (_) {
        return SortDialog(ornekKayit: ornekKayit,orderBy: orderBy,baseModelPageId: baseModelPageId,);
      }
    );
  }

  void showFilterPopup() {
    showDialog(
        context: context,
        builder: (_) {
          return FilterDialog(ornekKayit: ornekKayit,filterMap: filterMap,baseModelPageId: baseModelPageId,scaffoldKey: _scaffoldKey,);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(pageTitle ?? ornekKayit.pageTitle,),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.blue.shade300),
              ),
            ),
            child: Row(
              children: []
                ..addAll(widget.addButtonExists ? [
                  Expanded(
                    child: IconSlideAction(
                      caption: 'Ekle',
                      color: Colors.blue,
                      icon: Icons.add,
                      onTap: () {
                        NavigatorBase.push(BaseModelDuzenleme(widgetKayit : _selectedKayit, widgetModelName: modelName,baseModelPageId: baseModelPageId,baseModelPageScaffoldKey: _scaffoldKey,));
                      },
                    ),
                  )
                ] : [])
                ..addAll(expandedAppBarActions)
                ..addAll([
                  Expanded(
                    child: IconSlideAction(
                      caption: 'Filtrele',
                      color: filterMap != null && filterMap.length > 0 ? ConstantsBase.defaultSecondaryColor : ConstantsBase.defaultButtonColor,
                      icon: Icons.filter_list,
                      onTap: () {
                        showFilterPopup();
                      },
                    ),
                  ),
                  Expanded(
                    child: IconSlideAction(
                      caption: 'Sırala',
                      color: orderBy != null && orderBy.isNotEmpty ? ConstantsBase.defaultSecondaryColor : ConstantsBase.defaultButtonColor,
                      icon: Icons.sort_by_alpha,
                      onTap: () {
                        showSortPopup();
                      },
                    ),
                  ),
                ])
                ),
          )
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child:
              currentListData == null ?
              Center(child: CircularProgressIndicator()) :
              ListView(
                children: currentListData.asMap().entries.map((entry) => Container(
                  decoration: BoxDecoration(
                    //border: Border.all(width: 1),
                    color: _selectedKayit != null && _selectedKayit.get("ID") == entry.value.get("ID") ? Colors.yellow : ( entry.value.listBgColor != null ? entry.value.listBgColor(entry.value) : Colors.white ),
                  ),
                  child: Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    controller: slidableController,
                    actionExtentRatio: 0.25,
                    child: Card(
                      color: entry.key % 2 == 0 ? Colors.white : ConstantsBase.defaultSecondaryColor,
                      elevation: 5.0,
                      child: ListTile(
                        selected: _selectedKayit != null && _selectedKayit.get("ID") == entry.value.get("ID"),
                        onLongPress: () {
                          debugPrint("Long Pressed");
                        },
                        onTap: () {
                          if(_selectedKayit != null && _selectedKayit.get("ID") == entry.value.get("ID")) {
                            setState(() {
                              _selectedKayit = null;
                            });
                          } else {
                            setState(() {
                              _selectedKayit = entry.value;
                            });
                          }
                        },
                        title: entry.value.getListTileTitleWidget(),
                        subtitle: entry.value.getListTileSubTitleWidget(),
                        leading: entry.value.getTileLeadingWidget(),
                        trailing: entry.value.getTileTrailingWidget(),
                      )
                    ),
                    secondaryActions: []
                      ..addAll(widget.editButtonExists ? [
                        Card(
                          child: IconSlideAction(
                            caption: 'Düzenle',
                            color: Colors.black45,
                            icon: Icons.edit,
                            onTap: () {
                              NavigatorBase.push(BaseModelDuzenleme(widgetKayit : entry.value, widgetModelName: modelName,baseModelPageId: baseModelPageId,baseModelPageScaffoldKey: _scaffoldKey));
                            },
                          )
                        )
                        ] : [])
                      ..addAll(widget.deleteButtonExists ? [
                        Card(
                          child: IconSlideAction(
                            caption: 'Sil',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () => _showDialog(entry.value),
                          ),
                        )
                      ] : []),
                  ),
                )).toList(),
              )
          ),
        ],
      ),
    ),
    bottomNavigationBar: Container(
      height: 60,
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: IconSlideAction(
                color: currentPage == 1 ? ConstantsBase.defaultDisabledColor : ConstantsBase.defaultButtonColor,
                icon: Icons.first_page,
                onTap: () {
                  if(currentPage > 1) {
                    refreshData(currentPagePrm: 1);
                  }
                }
              ),
            ),
            Expanded(
              flex: 1,
              child: IconSlideAction(
                color: currentPage == 1 ? ConstantsBase.defaultDisabledColor : ConstantsBase.defaultButtonColor,
                icon: Icons.arrow_back_ios,
                onTap: () {
                  if(currentPage > 1) {
                    refreshData(currentPagePrm: currentPage - 1);
                  }
                }
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(totalCount.toString() + " kayıt - " + currentPage.toString() + " / " + lastPage.toString(), style: TextStyle(fontSize: 18),),
              )
            ),
            Expanded(
              flex: 1,
              child: IconSlideAction(
                color: currentPage >= lastPage ? ConstantsBase.defaultDisabledColor : ConstantsBase.defaultButtonColor,
                icon: Icons.arrow_forward_ios,
                onTap: () {
                  if(currentPage != lastPage) {
                    refreshData(currentPagePrm: currentPage + 1);
                  }
                }
              ),
            ),
            Expanded(
              flex: 1,
              child: IconSlideAction(
                color: currentPage >= lastPage ? ConstantsBase.defaultDisabledColor : ConstantsBase.defaultButtonColor,
                icon: Icons.last_page,
                onTap: () {
                  if(currentPage != lastPage) {
                    refreshData(currentPagePrm: lastPage);
                  }
                }
              ),
            )
          ],
        ),
      ),
    ));
  }
}