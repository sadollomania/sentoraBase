import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/SortChangedEvent.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';

class SortDialog extends StatefulWidget {
  final String orderBy;
  final BaseModel ornekKayit;

  SortDialog({
    @required this.orderBy,
    @required this.ornekKayit,
  });

  @override
  _SortDialogState createState() => new _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  List<String> listOrder = List<String>();
  List<bool> enabledList = List<bool>();
  List<String> directionList = List<String>();

  @override
  void initState(){
    widget.ornekKayit.allFieldTypes.forEach((fieldType){
      if(fieldType.sortable) {
        listOrder.add(fieldType.name);
        enabledList.add(false);
        directionList.add("ASC");
      }
    });

    if(widget.orderBy != null && widget.orderBy.isNotEmpty) {
      List<String> currList = widget.orderBy.split(",");
      for(int i = currList.length - 1; i >= 0; --i) {
        List<String> tmpArr = currList[i].split(" ");
        String currName = tmpArr[0];
        String currDirection = tmpArr[1];
        int index = listOrder.indexOf(currName);
        listOrder.removeAt(index);
        listOrder.insert(0, currName);
        enabledList.removeAt(index);
        enabledList.insert(0, true);
        directionList.removeAt(index);
        directionList.insert(0, currDirection);
      }
    }
    super.initState();
  }

  void sortListsProperly() {
    List<String> newListOrder = List<String>();
    List<bool> newEnabledList = List<bool>();
    List<String> newDirectionList = List<String>();

    for(int i = 0, len = listOrder.length; i < len; ++i) {
      if(enabledList[i]) {
        newListOrder.add(listOrder[i]);
        newEnabledList.add(enabledList[i]);
        newDirectionList.add(directionList[i]);
      }
    }

    for(int i = 0, len = listOrder.length; i < len; ++i) {
      if(!enabledList[i]) {
        newListOrder.add(listOrder[i]);
        newEnabledList.add(enabledList[i]);
        newDirectionList.add(directionList[i]);
      }
    }

    listOrder = newListOrder;
    enabledList = newEnabledList;
    directionList = newDirectionList;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = List<Widget>();
    for(int i = 0, len = listOrder.length; i < len; ++i) {
      String fieldName = listOrder[i];
      bool enabled = enabledList[i];
      String direction = directionList[i];
      _children.add(ListTile(
          key: ValueKey(fieldName),
          title: Text(fieldName),
          leading: Container(
            width: 82,
              child:Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: MenuButton(
                      iconData: enabled ? Icons.done_outline : Icons.do_not_disturb,
                      buttonColor: enabled ? Colors.greenAccent : ConstantsBase.defaultDisabledColor,
                      onPressed: (){
                        setState(() {
                          enabledList[i] = !enabled;
                          sortListsProperly();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 2,),
                  Expanded(
                    flex: 1,
                    child: MenuButton(
                      iconData: direction == "ASC" ? Icons.arrow_upward : Icons.arrow_downward,
                      buttonColor: Colors.white,
                      onPressed: (){
                        setState(() {
                          directionList[i] = direction == "ASC" ? "DESC" : "ASC";
                        });
                      },
                    ),
                  ),
                ],
              )
          )
      ));
    }

    return AlertDialog(
      title: Text(widget.ornekKayit.singleTitle + " Sıralama"),
      content: Container(
        height: ConstantsBase.getMaxHeight(context) * 0.8,
        width: ConstantsBase.getMaxWidth(context) * 0.8,
        child: ReorderableListView(
          header: Text("Sıralama için uzun basılı tutun."),
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
            title: "İptal",
            fontSize: 20,
            iconData: Icons.cancel,
            onPressed: () {
              NavigatorBase.pop();
            },
          ),
        ),
        SizedBox(width: 10,),
        SizedBox(
          width: ConstantsBase.getMaxWidth(context) * 0.4 - ( 24 + 24 + 10 + 2 ) / 2, //(alertdialog edges + sizedbox between + 2 px) / 2
          height: 50,
          child: MenuButton(
            fontSize: 20,
            title: "Sırala",
            iconData: Icons.sort_by_alpha,
            onPressed: () {
              String newOrderBy = "";
              for(int i = 0, len = listOrder.length; i < len; ++i) {
                if(enabledList[i]) {
                  newOrderBy += "," + listOrder[i] + " " + directionList[i];
                }
              }
              newOrderBy = newOrderBy.length == 0 ? newOrderBy : newOrderBy.substring(1);
              ConstantsBase.eventBus.fire(SortChangedEvent(newOrderBy));
              NavigatorBase.pop();
            },
          ),
        ),
      ],
    );
  }
}