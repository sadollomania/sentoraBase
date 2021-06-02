import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sentora_base/events/FilterChangedEvent.dart';
import 'package:sentora_base/events/ModelDuzenlemeEvent.dart';
import 'package:sentora_base/events/SortChangedEvent.dart';
import 'package:sentora_base/events/UpdatePageStateEvent.dart';
import 'package:sentora_base/model/AppBarActionHolder.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/StateData.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/pages/BaseModelDuzenleme.dart';
import 'package:sentora_base/pages/BasePage.dart';
import 'package:sentora_base/pages/FilterDialog.dart';
import 'package:sentora_base/pages/SortDialog.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/SntIconButton.dart';

import 'package:sqflite/sqflite.dart';

class BaseModelPage extends BasePage {
  final String modelName;

  final String Function(StateData stateData) addButtonTitle;
  final String Function(StateData stateData) editButtonTitle;
  final String Function(StateData stateData) deleteButtonTitle;
  final List<AppBarActionHolder> Function(StateData) topActions;

  static void _showDialog(StateData stateData, BaseModel kayit) {
    showDialog(
      context: stateData.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ConstantsBase.translate("emin_misiniz") + "?"),
          content: Text(stateData.tag["ornekKayit"].singleTitle + " " + kayit.getCombinedTitleValue() + " " + ConstantsBase.translate("silinecektir") + "!"),
          actions: <Widget>[
            TextButton(
              child: Text(ConstantsBase.translate("iptal")),
              onPressed: () async{
                await NavigatorBase.pop();
              },
            ),
            TextButton(
              child: Text(ConstantsBase.translate("sil")),
              onPressed: () async{
                await BaseModel.delete(kayit).then((_) async{
                  await NavigatorBase.pop();
                  stateData.tag["selectedKayit"] = null;
                  ConstantsBase.eventBus.fire(UpdatePageStateEvent(stateData.pageId));
                  ConstantsBase.eventBus.fire(ModelDuzenlemeEvent(stateData.pageId));
                  return;
                }).catchError((e) async{
                  debugPrint(e.toString());
                  await NavigatorBase.pop();
                  if(e is DatabaseException) {
                    ConstantsBase.showSnackBarLong(stateData.scaffoldKey, BaseModel.convertDbErrorToStr(kayit, e));
                  } else {
                    ConstantsBase.showSnackBarLong(stateData.scaffoldKey, e.toString());
                  }
                  return;
                });
                return;
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showSortPopup(StateData stateData) {
    return showDialog(
      context: stateData.context,
      builder: (_) {
        return SortDialog(ornekKayit: stateData.tag["ornekKayit"],orderBy: stateData.tag["orderBy"],baseModelPageId: stateData.pageId,);
      }
    );
  }

  static Future<void> showFilterPopup(StateData stateData) {
    return showDialog(
      context: stateData.context,
      builder: (_) {
        return FilterDialog(ornekKayit: stateData.tag["ornekKayit"],filterMap: stateData.tag["filterMap"],baseModelPageId: stateData.pageId,scaffoldKey: stateData.scaffoldKey,);
      }
    );
  }

  static Future<void> dataLoaded(StateData stateData, map, compCurrentPage, compOrderBy, compFilterMap) async{
    int dataCnt = ConstantsBase.getTotalCountFormGetList(map);
    List<BaseModel> listData = ConstantsBase.getDataFormGetList(map);
    bool selectedKayitExists = false;
    if(stateData.tag["selectedKayit"] != null){
      for(int i = 0, len = listData.length; i < len; ++i) {
        if(listData[i].get("ID") == stateData.tag["selectedKayit"].get("ID")) {
          selectedKayitExists = true;
          break;
        }
      }
    }
    int compLastPage = ((dataCnt * 1.0) / stateData.tag["pageSize"]).ceil();
    if(compLastPage == 0) {
      compLastPage = 1;
    }
    if(compCurrentPage > compLastPage) {
      await refreshData(stateData, currentPagePrm: compLastPage, orderByPrm: compOrderBy, filterMapPrm: compFilterMap);
      return;
    }

    stateData.tag["currentListData"] = listData;
    stateData.tag["totalCount"] = dataCnt;
    stateData.tag["lastPage"] = compLastPage;
    stateData.tag["currentPage"] = compCurrentPage;
    stateData.tag["orderBy"] = compOrderBy;
    stateData.tag["filterMap"] = compFilterMap;
    stateData.tag["selectedKayit"] = selectedKayitExists ? stateData.tag["selectedKayit"] : null;

    ConstantsBase.eventBus.fire(UpdatePageStateEvent(stateData.pageId));
    return;
  }

  static Future<void> refreshData(StateData stateData, {int currentPagePrm, String orderByPrm, Map<String, dynamic> filterMapPrm}) async{
    int compCurrentPage = currentPagePrm ?? stateData.tag["currentPage"];
    String compOrderBy = orderByPrm ?? stateData.tag["orderBy"];
    Map<String, dynamic> compFilterMap = filterMapPrm ?? stateData.tag["filterMap"];

    var map = await BaseModel.getList(stateData.tag["ornekKayit"], rawQuery: stateData.tag["getLisQuery"], pageSize: stateData.tag["pageSize"], currentPage: compCurrentPage, orderBy: compOrderBy, filterMap: compFilterMap);
    return dataLoaded(stateData, map, compCurrentPage, compOrderBy, compFilterMap);
  }

  BaseModelPage({
    @required this.modelName,
    String Function(StateData stateData) pageTitle,
    String getListQuery,
    String orderBy,
    int pageSize,
    this.addButtonTitle,
    this.editButtonTitle,
    this.deleteButtonTitle,
    this.topActions,
  })
  : assert(modelName != null),
  super(
    pageTitle: pageTitle ?? (stateData){ return BaseModel.createNewObject(modelName).pageTitle; },
    initialTag : (_) => {
      "getLisQuery" : getListQuery,
      "modelName" : modelName,
      "ornekKayit" : BaseModel.createNewObject(modelName),
      "selectedKayit" : null,
      "pageSize" : pageSize ?? ConstantsBase.pageSize,
      "currentPage" : 1,
      "totalCount" : 0,
      "lastPage" : 1,
      "orderBy" : orderBy ?? BaseModel.createNewObject(modelName).defaultOrderBy,
      "filterMap" : null,
      "currentListData" : null,
    },
    initStateFunction : (StateData stateData) {
      stateData.tag["modelDuzenlemeSubscription"] = ConstantsBase.eventBus.on<ModelDuzenlemeEvent>().listen((event){
        if(event.pageId == stateData.pageId) {
          refreshData(stateData);
        }
      });
      stateData.tag["sortChangedSubscription"] = ConstantsBase.eventBus.on<SortChangedEvent>().listen((event){
        if(event.pageId == stateData.pageId) {
          refreshData(stateData, orderByPrm: event.orderBy);
        }
      });
      stateData.tag["filterChangedSubscription"] = ConstantsBase.eventBus.on<FilterChangedEvent>().listen((event){
        if(event.pageId == stateData.pageId) {
          refreshData(stateData, filterMapPrm: event.filterMap);
        }
      });
    },
    afterRender : (StateData stateData) {
      refreshData(stateData);
    },
    disposeFunction : (StateData stateData) {
      stateData.tag["modelDuzenlemeSubscription"].cancel();
      stateData.tag["sortChangedSubscription"].cancel();
      stateData.tag["filterChangedSubscription"].cancel();
    },
    topBar : (StateData stateData) {
      return PreferredSize(
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
                  ..addAll(addButtonTitle != null ? [
                    Expanded(
                      child: SntIconButton(
                        caption: addButtonTitle(stateData),
                        color: Colors.blue,
                        icon: Icons.add,
                        onTap: () async {
                          await NavigatorBase.push(BaseModelDuzenleme(widgetKayit : stateData.tag["selectedKayit"], widgetModelName: modelName,baseModelPageId: stateData.pageId,baseModelPageScaffoldKey: stateData.scaffoldKey,));
                          return;
                        },
                      ),
                    )
                  ] : [])
                  ..addAll(topActions == null ? [] : topActions(stateData).map((action){
                    return Expanded(
                      child: SntIconButton(
                        caption: action.caption,
                        color: action.color,
                        icon: action.icon,
                        onTap: () => action.onTap(stateData),
                      ),
                    );
                  }))
                  ..addAll([
                    Expanded(
                      child: SntIconButton(
                        caption: ConstantsBase.translate("filtrele"),
                        color: stateData.tag["filterMap"] != null && stateData.tag["filterMap"].length > 0 ? ConstantsBase.greenAccentShade100Color : ConstantsBase.defaultButtonColor,
                        icon: Icons.filter_list,
                        onTap: () async{
                          return await showFilterPopup(stateData);
                        },
                      ),
                    ),
                    Expanded(
                      child: SntIconButton(
                        caption: ConstantsBase.translate("sirala"),
                        color: stateData.tag["orderBy"] != null && stateData.tag["orderBy"].isNotEmpty ? ConstantsBase.greenAccentShade100Color : ConstantsBase.defaultButtonColor,
                        icon: Icons.sort_by_alpha,
                        onTap: () async{
                          return await showSortPopup(stateData);
                        },
                      ),
                    ),
                  ])
            ),
          )
      );
    },
    body : (StateData stateData) {
      return Container(
        padding: EdgeInsets.all(8.0),
        child: stateData.tag["currentListData"] == null ? Center(child: CircularProgressIndicator()) :
          ListView(
            children: stateData.tag["currentListData"].asMap().entries.map<Widget>((entry) => Container(
              decoration: BoxDecoration(
                //border: Border.all(width: 1),
                color: stateData.tag["selectedKayit"] != null && stateData.tag["selectedKayit"].get("ID") == entry.value.get("ID") ? Colors.yellow : ( entry.value.listBgColor != null ? entry.value.listBgColor(entry.value) : Colors.white ),
              ),
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                controller: SlidableController(),
                actionExtentRatio: 0.25,
                child: Card(
                    color: entry.key % 2 == 0 ? Colors.white : ConstantsBase.greenAccentShade100Color,
                    elevation: 5.0,
                    child: ListTile(
                      selected: stateData.tag["selectedKayit"] != null && stateData.tag["selectedKayit"].get("ID") == entry.value.get("ID"),
                      onLongPress: () {
                        debugPrint("Long Pressed");
                      },
                      onTap: () {
                        if(stateData.tag["selectedKayit"] != null && stateData.tag["selectedKayit"].get("ID") == entry.value.get("ID")) {
                          stateData.tag["selectedKayit"] = null;
                          ConstantsBase.eventBus.fire(UpdatePageStateEvent(stateData.pageId));
                        } else {
                          stateData.tag["selectedKayit"] = entry.value;
                          ConstantsBase.eventBus.fire(UpdatePageStateEvent(stateData.pageId));
                        }
                      },
                      title: entry.value.getListTileTitleWidget(),
                      subtitle: entry.value.getListTileSubTitleWidget(),
                      leading: entry.value.getTileLeadingWidget(),
                      trailing: entry.value.getTileTrailingWidget(),
                    )
                ),
                secondaryActions: []
                  ..addAll(editButtonTitle != null ? [
                    Card(
                        child: IconSlideAction(
                          caption: editButtonTitle(stateData),
                          color: Colors.black45,
                          icon: Icons.edit,
                          onTap: () {
                            NavigatorBase.push(BaseModelDuzenleme(widgetKayit : entry.value, widgetModelName: modelName,baseModelPageId: stateData.pageId,baseModelPageScaffoldKey: stateData.scaffoldKey));
                          },
                        )
                    )
                  ] : [])
                  ..addAll(deleteButtonTitle != null ? [
                    Card(
                      child: IconSlideAction(
                        caption: deleteButtonTitle(stateData),
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => _showDialog(stateData, entry.value),
                      ),
                    )
                  ] : []),
              ),
            )).toList()
          ),
        );
    },
    bottomBar : (StateData stateData) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: SntIconButton(
                color: stateData.tag["currentPage"] == 1 ? ConstantsBase.defaultDisabledColor : ConstantsBase.defaultButtonColor,
                icon: Icons.first_page,
                onTap: () async{
                  if(stateData.tag["currentPage"] > 1) {
                    await refreshData(stateData, currentPagePrm: 1);
                  }
                  return;
                }
            ),
          ),
          Expanded(
            flex: 1,
            child: SntIconButton(
                color: stateData.tag["currentPage"] == 1 ? ConstantsBase.defaultDisabledColor : ConstantsBase.defaultButtonColor,
                icon: Icons.arrow_back_ios,
                onTap: () async {
                  if(stateData.tag["currentPage"] > 1) {
                    await refreshData(stateData, currentPagePrm: stateData.tag["currentPage"] - 1);
                  }
                  return;
                }
            ),
          ),
          Expanded(
              flex: 3,
              child: Center(
                child: Text(stateData.tag["totalCount"].toString() + " " + ConstantsBase.translate("kayit") + " - " + stateData.tag["currentPage"].toString() + " / " + stateData.tag["lastPage"].toString(), style: TextStyle(fontSize: 18),),
              )
          ),
          Expanded(
            flex: 1,
            child: SntIconButton(
                color: stateData.tag["currentPage"] >= stateData.tag["lastPage"] ? ConstantsBase.defaultDisabledColor : ConstantsBase.defaultButtonColor,
                icon: Icons.arrow_forward_ios,
                onTap: () async {
                  if(stateData.tag["currentPage"] != stateData.tag["lastPage"]) {
                    await refreshData(stateData, currentPagePrm: stateData.tag["currentPage"] + 1);
                  }
                  return;
                }
            ),
          ),
          Expanded(
            flex: 1,
            child: SntIconButton(
                color: stateData.tag["currentPage"] >= stateData.tag["lastPage"] ? ConstantsBase.defaultDisabledColor : ConstantsBase.defaultButtonColor,
                icon: Icons.last_page,
                onTap: () async {
                  if(stateData.tag["currentPage"] != stateData.tag["lastPage"]) {
                    await refreshData(stateData, currentPagePrm: stateData.tag["lastPage"]);
                  }
                  return;
                }
            ),
          )
        ],
      );
    }
  );
}