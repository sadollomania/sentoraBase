import 'package:flutter/material.dart';
import 'package:sentora_base/data/DBHelperBase.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/events/SortChangedEvent.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';

class SortDialog extends StatefulWidget {
  final String orderBy;
  final BaseModel ornekKayit;
  final String baseModelPageId;

  SortDialog({
    @required this.orderBy,
    @required this.ornekKayit,
    @required this.baseModelPageId,
  });

  @override
  _SortDialogState createState() => new _SortDialogState(baseModelPageId : baseModelPageId);
}

class _SortDialogState extends State<SortDialog> {
  List<String> listOrder = List<String>();
  List<String> listTitles = List<String>();
  List<bool> enabledList = List<bool>();
  List<String> directionList = List<String>();
  List<String> nullsOrderList = List<String>();
  String baseModelPageId;

  _SortDialogState({
    String baseModelPageId,
  }):
        this.baseModelPageId = baseModelPageId;

  @override
  void initState(){
    widget.ornekKayit.allFieldTypes.forEach((fieldType){
      if(fieldType.sortable) {
        listOrder.add(fieldType.name);
        listTitles.add(fieldType.fieldLabel);
        enabledList.add(false);
        directionList.add("ASC");
        nullsOrderList.add(DBHelperBase.nullsNone);
      }
    });

    if(widget.orderBy != null && widget.orderBy.isNotEmpty) {
      List<String> currList = widget.orderBy.split(",");
      for(int i = currList.length - 1; i >= 0; --i) {
        List<String> tmpArr = currList[i].split(" ");
        String currName = tmpArr[0];
        String currDirection = tmpArr[1];
        String nullsOrder = DBHelperBase.nullsNone;
        if(tmpArr.length == 3) {
          nullsOrder = tmpArr[2];
        }
        String title;
        int index = listOrder.indexOf(currName);
        listOrder.removeAt(index);
        listOrder.insert(0, currName);
        title = listTitles.removeAt(index);
        listTitles.insert(0, title);
        enabledList.removeAt(index);
        enabledList.insert(0, true);
        directionList.removeAt(index);
        directionList.insert(0, currDirection);
        nullsOrderList.removeAt(index);
        nullsOrderList.insert(0, nullsOrder);
      }
    }
    super.initState();
  }

  void sortListsProperly() {
    List<String> newListOrder = List<String>();
    List<bool> newEnabledList = List<bool>();
    List<String> newDirectionList = List<String>();
    List<String> newTitlesList = List<String>();
    List<String> newNullsOrderList = List<String>();

    for(int i = 0, len = listOrder.length; i < len; ++i) {
      if(enabledList[i]) {
        newListOrder.add(listOrder[i]);
        newEnabledList.add(enabledList[i]);
        newDirectionList.add(directionList[i]);
        newNullsOrderList.add(nullsOrderList[i]);
        newTitlesList.add(listTitles[i]);
      }
    }

    for(int i = 0, len = listOrder.length; i < len; ++i) {
      if(!enabledList[i]) {
        newListOrder.add(listOrder[i]);
        newEnabledList.add(enabledList[i]);
        newDirectionList.add(directionList[i]);
        newNullsOrderList.add(nullsOrderList[i]);
        newTitlesList.add(listTitles[i]);
      }
    }

    listOrder = newListOrder;
    enabledList = newEnabledList;
    directionList = newDirectionList;
    listTitles = newTitlesList;
    nullsOrderList = newNullsOrderList;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = List<Widget>();
    for(int i = 0, len = listOrder.length; i < len; ++i) {
      String fieldName = listOrder[i];
      String fieldLabel = listTitles[i];
      bool enabled = enabledList[i];
      String direction = directionList[i];
      String nullsOrder = nullsOrderList[i];
      _children.add(ListTile(
          key: ValueKey(fieldName),
          title: Text(fieldLabel),
          leading: Container(
            width: 123,
              child:Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: MenuButton(
                      iconData: enabled ? Icons.done_outline : Icons.do_not_disturb,
                      buttonColor: enabled ? Colors.greenAccent : ConstantsBase.defaultDisabledColor,
                      onPressed: () async{
                        setState(() {
                          enabledList[i] = !enabled;
                          sortListsProperly();
                        });
                        return;
                      },
                    ),
                  ),
                  SizedBox(width: 2,),
                  Expanded(
                    flex: 1,
                    child: MenuButton(
                      iconData: direction == "ASC" ? Icons.arrow_upward : Icons.arrow_downward,
                      buttonColor: Colors.white,
                      onPressed: () async{
                        setState(() {
                          directionList[i] = direction == "ASC" ? "DESC" : "ASC";
                        });
                        return;
                      },
                    ),
                  ),
                  SizedBox(width: 2,),
                  Expanded(
                    flex: 1,
                    child: MenuButton(
                      iconData: nullsOrder == DBHelperBase.nullsFirst ? Icons.minimize : (nullsOrder == DBHelperBase.nullsLast ? Icons.maximize : Icons.do_not_disturb),
                      buttonColor: Colors.white,
                      onPressed: () async{
                        setState(() {
                          nullsOrderList[i] = nullsOrder == DBHelperBase.nullsFirst ? DBHelperBase.nullsLast : (nullsOrder == DBHelperBase.nullsLast ? DBHelperBase.nullsNone : DBHelperBase.nullsFirst);
                        });
                        return;
                      },
                    ),
                  ),
                ],
              )
          )
      ));
    }

    return AlertDialog(
      title: Text(widget.ornekKayit.singleTitle + " " + ConstantsBase.translate("siralama")),
      content: Container(
        height: ConstantsBase.getMaxHeight(context) * 0.8,
        width: ConstantsBase.getMaxWidth(context) * 0.8,
        child: ReorderableListView(
          header: Text(ConstantsBase.translate("sort_dialog_description"),maxLines: 4,),
          padding: EdgeInsets.only(top: 20.0),
          children: _children,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final String itemName = listOrder.removeAt(oldIndex);
              listOrder.insert(newIndex, itemName);

              final bool itemEnabled = enabledList.removeAt(oldIndex);
              enabledList.insert(newIndex, itemEnabled);

              final String itemDirection = directionList.removeAt(oldIndex);
              directionList.insert(newIndex, itemDirection);

              final String itemTitle = listTitles.removeAt(oldIndex);
              listTitles.insert(newIndex, itemTitle);

              final String nullsOrder = nullsOrderList.removeAt(oldIndex);
              nullsOrderList.insert(newIndex, nullsOrder);
              sortListsProperly();
            });
          },
        ),
      ),
      actions: <Widget>[
        SizedBox(
          width: ConstantsBase.getMaxWidth(context) * 0.4 - ( 24 + 24 + 10 + 2 ) / 2, //(alertdialog edges + sizedbox between + 2 px) / 2
          height: 50,
          child: MenuButton(
            title: ConstantsBase.translate("iptal"),
            fontSize: 20,
            iconColor: ConstantsBase.yellowShade500Color,
            iconData: Icons.cancel,
            onPressed: () async {
              await NavigatorBase.pop();
              return;
            },
          ),
        ),
        SizedBox(width: 10,),
        SizedBox(
          width: ConstantsBase.getMaxWidth(context) * 0.4 - ( 24 + 24 + 10 + 2 ) / 2, //(alertdialog edges + sizedbox between + 2 px) / 2
          height: 50,
          child: MenuButton(
            fontSize: 20,
            iconColor: ConstantsBase.yellowShade500Color,
            title: ConstantsBase.translate("sirala"),
            iconData: Icons.sort_by_alpha,
            onPressed: () async {
              String newOrderBy = "";
              for(int i = 0, len = listOrder.length; i < len; ++i) {
                if(enabledList[i]) {
                  if(nullsOrderList[i] == DBHelperBase.nullsNone) {
                    newOrderBy += "," + listOrder[i] + " " + directionList[i];
                  } else {
                    newOrderBy += "," + listOrder[i] + " " + directionList[i] + " " + nullsOrderList[i];
                  }
                }
              }
              newOrderBy = newOrderBy.length == 0 ? newOrderBy : newOrderBy.substring(1);
              ConstantsBase.eventBus.fire(SortChangedEvent(newOrderBy, baseModelPageId));
              await NavigatorBase.pop();
              return;
            },
          ),
        ),
      ],
    );
  }
}