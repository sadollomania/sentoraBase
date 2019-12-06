import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/pages/BaseModelDuzenleme.dart';
import 'package:sentora_base/pages/FilterDialog.dart';
import 'package:sentora_base/pages/SortDialog.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

import 'package:sentora_base/widgets/MenuButton.dart';
import 'package:sentora_base/model/ModelDuzenlemeEvent.dart';
import 'package:sentora_base/model/SortChangedEvent.dart';
import 'package:sentora_base/model/FilterChangedEvent.dart';
import 'package:sqflite/sqflite.dart';

class BaseModelPage extends StatefulWidget {
  final String widgetModelName;
  final String pageTitle;
  final String getListQuery;
  final Row Function(BaseModel selectedKayit) constructButtonsRow;

  BaseModelPage({
    @required this.widgetModelName,
    this.pageTitle,
    this.getListQuery,
    this.constructButtonsRow,
  }) :
  assert((pageTitle == null && getListQuery == null && constructButtonsRow == null) ||
      (pageTitle != null && getListQuery != null && constructButtonsRow != null));

  @override
  State<StatefulWidget> createState() => new _BaseModelPageState(modelName: this.widgetModelName, pageTitle: pageTitle, getListQuery: getListQuery, constructButtonsRow: constructButtonsRow);
}

class _BaseModelPageState extends State<BaseModelPage> {
  String pageTitle;
  String getListQuery;
  String modelName;
  Row Function(BaseModel selectedKayit) constructButtonsRow;
  BaseModel ornekKayit;
  BaseModel _selectedKayit;
  int pageSize = ConstantsBase.pageSize;
  int currentPage = 1;
  int totalCount = 0;
  int lastPage = 1;
  String orderBy = "INSDATE ASC";
  Map<String, dynamic> filterMap = Map<String, dynamic>();
  List<BaseModel> currentListData;
  StreamSubscription modelDuzenlemeSubscription;
  StreamSubscription sortChangedSubscription;
  StreamSubscription filterChangedSubscription;

  void initState() {
    super.initState();
    modelDuzenlemeSubscription = ConstantsBase.eventBus.on<ModelDuzenlemeEvent>().listen((event){
      refreshData();
    });
    sortChangedSubscription = ConstantsBase.eventBus.on<SortChangedEvent>().listen((event){
      refreshData(orderByPrm: event.newOrderBy);
    });
    filterChangedSubscription = ConstantsBase.eventBus.on<FilterChangedEvent>().listen((event){
      refreshData(filterMapPrm: event.newFilterMap);
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

  _BaseModelPageState({
    @required this.modelName,
    @required this.pageTitle,
    @required this.getListQuery,
    @required this.constructButtonsRow,
  }) {
    this.ornekKayit = BaseModel.createNewObject(this.modelName);
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Emin Misiniz?"),
          content: Text(ornekKayit.singleTitle + " Silinecektir!"),
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
                BaseModel.delete(_selectedKayit).then((_){
                  NavigatorBase.pop();
                  setState(() {
                    _selectedKayit = null;
                  });
                  ConstantsBase.eventBus.fire(ModelDuzenlemeEvent());
                }).catchError((e){
                  debugPrint(e.toString());
                  if(e is DatabaseException) {
                    ConstantsBase.showToast(context, BaseModel.convertDbErrorToStr(_selectedKayit, e));
                  } else {
                    ConstantsBase.showToast(context, e.toString());
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

  Row getDefaultButtonsRow() {
    return Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: MenuButton(
                title: 'Ekle',
                iconData: Icons.add,
                onPressed: () {
                  NavigatorBase.push(BaseModelDuzenleme(widgetKayit : _selectedKayit, widgetModelName: modelName,));
                }),
          ),
          SizedBox(width: 10,),
          Expanded(
            flex: 3,
            child: MenuButton(
                title: 'Düzenle',
                textFlex: 4,
                iconData: Icons.edit,
                disabled: _selectedKayit == null,
                onPressed: () {
                  NavigatorBase.push(BaseModelDuzenleme(widgetKayit : _selectedKayit, widgetModelName: modelName,));
                }),
          ),
          SizedBox(width: 10,),
          Expanded(
            flex: 2,
            child: MenuButton(
                title: 'Sil',
                iconData: Icons.delete,
                disabled: _selectedKayit == null,
                onPressed: () {
                  _showDialog();
                }),
          ),
        ]
    );
  }

  void showSortPopup() {
    showDialog(
      context: context,
      builder: (_) {
        return SortDialog(ornekKayit: ornekKayit,orderBy: orderBy,);
      }
    );
  }

  void showFilterPopup() {
    showDialog(
        context: context,
        builder: (_) {
          return FilterDialog(ornekKayit: ornekKayit,finalFilterMap: filterMap,);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle ?? ornekKayit.pageTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          constructButtonsRow != null ? constructButtonsRow(_selectedKayit) : getDefaultButtonsRow(),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: MenuButton(
                    title: 'Filtrele',
                    buttonColor: filterMap.length > 0 ? Colors.greenAccent : ConstantsBase.defaultButtonColor,
                    iconData: Icons.filter_list,
                    onPressed: () {
                      showFilterPopup();
                    }),
              ),
              SizedBox(width: 10,),
              Expanded(
                flex: 1,
                child: MenuButton(
                    title: 'Sırala',
                    buttonColor: orderBy != null && orderBy.isNotEmpty ? Colors.greenAccent : ConstantsBase.defaultButtonColor,
                    iconData: Icons.sort_by_alpha,
                    onPressed: () {
                      showSortPopup();
                    }),
              )
            ]
          ),
          SizedBox(height: 10,),
          Expanded(
            child:
              currentListData == null ?
              Center(child: CircularProgressIndicator()) :
              ListView(
                children: currentListData.map((kayit) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    color: _selectedKayit != null && _selectedKayit.get("ID") == kayit.get("ID") ? Colors.yellow : ( kayit.listBgColor != null ? kayit.listBgColor(kayit) : Colors.white ),
                  ),
                  child: ListTile(
                    selected: _selectedKayit != null && _selectedKayit.get("ID") == kayit.get("ID"),
                    onTap: () {
                      if(_selectedKayit != null && _selectedKayit.get("ID") == kayit.get("ID")) {
                        setState(() {
                          _selectedKayit = null;
                        });
                      } else {
                        setState(() {
                          _selectedKayit = kayit;
                        });
                      }
                    },
                    title: Text(kayit.listTileTitle + " : " + kayit.getListTileTitleValue()),
                    subtitle: Text(kayit.listTileSubTitle + " : " + kayit.getListTileSubTitleValue()),
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Text(kayit.getTileAvatarFieldValue(), style: TextStyle(fontSize: 18.0, color: Colors.white,)),
                    ),
                  ),
                )).toList(),
              )
          ),
          SizedBox(height: 10,),
          Container(
            height: 60,
            child : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                    width: 40,
                    child: MenuButton(
                      edgeInsetsGeometry:EdgeInsets.all(0.0),
                      iconData: Icons.first_page,
                      disabled: currentPage == 1,
                      buttonColor: Colors.white,
                      onPressed: () {
                        if(currentPage > 1) {
                          refreshData(currentPagePrm: 1);
                        }
                      }
                    )
                ),
                SizedBox(width: 5,),
                SizedBox(
                    width: 40,
                    child: MenuButton(
                        edgeInsetsGeometry:EdgeInsets.all(0.0),
                        iconData: Icons.arrow_back_ios,
                        disabled: currentPage == 1,
                        buttonColor: Colors.white,
                        onPressed: () {
                          if(currentPage > 1) {
                            refreshData(currentPagePrm: currentPage - 1);
                          }
                        }
                    )
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(totalCount.toString() + " kayıt - " + currentPage.toString() + " / " + lastPage.toString(), style: TextStyle(fontSize: 18),),
                    ],
                  ),
                ),
                SizedBox(width: 5,),
                SizedBox(
                    width: 40,
                    child: MenuButton(
                        edgeInsetsGeometry:EdgeInsets.all(0.0),
                        iconData: Icons.arrow_forward_ios,
                        disabled: currentPage >= lastPage,
                        buttonColor: Colors.white,
                        onPressed: () {
                          if(currentPage != lastPage) {
                            refreshData(currentPagePrm: currentPage + 1);
                          }
                        }
                    )
                ),
                SizedBox(width: 5,),
                SizedBox(
                    width: 40,
                    child: MenuButton(
                        edgeInsetsGeometry:EdgeInsets.all(0.0),
                        iconData: Icons.last_page,
                        disabled: currentPage >= lastPage,
                        buttonColor: Colors.white,
                        onPressed: () {
                          if(currentPage != lastPage) {
                            refreshData(currentPagePrm: lastPage);
                          }
                        }
                    )
                ),
              ],
            )
          )
        ],
      ),
    ));
  }
}