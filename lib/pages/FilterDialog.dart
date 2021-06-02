import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/events/FilterChangedEvent.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';
import 'package:sentora_base/events/FilterValueChangedEvent.dart';

class FilterDialog extends StatefulWidget {
  final Map<String, dynamic> filterMap;
  final BaseModel ornekKayit;
  final String baseModelPageId;
  final GlobalKey<ScaffoldState> scaffoldKey;

  FilterDialog({
    @required this.filterMap,
    @required this.ornekKayit,
    @required this.baseModelPageId,
    @required this.scaffoldKey,
  }) :
  assert(ornekKayit != null),
  assert(baseModelPageId != null);

  @override
  _FilterDialogState createState() => new _FilterDialogState(widgetFilterMap: filterMap, baseModelPageId : baseModelPageId);
}

class _FilterDialogState extends State<FilterDialog> {
  Map<String, dynamic> filterMap;
  String baseModelPageId;
  StreamSubscription filterValueChangedSubscription;

  _FilterDialogState({
    Map<String, dynamic> widgetFilterMap,
    this.baseModelPageId,
  }) {
    filterMap = Map<String, dynamic>();
    if(widgetFilterMap != null) {
      widgetFilterMap.forEach((name, val){
        filterMap[name] = val;
      });
    }
  }

  @override
  void initState(){
    filterValueChangedSubscription = ConstantsBase.eventBus.on<FilterValueChangedEvent>().listen((event){
      setState(() {
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    filterValueChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> filterWidgetList = [];
    widget.ornekKayit.allFieldTypes.forEach((fieldType){
      if(fieldType.filterable) {
        filterWidgetList.add(ExpandablePanel(
          header: Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: ConstantsBase.filterDetailButtonLabelWidth,
                  child: Text(fieldType.fieldLabel, overflow: TextOverflow.ellipsis,),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: fieldType.constructFilterButtons(context, filterMap),
                )
              ],
            ),
          ),
          collapsed: Container(
            height: 2,
          ),
          expanded: Container(
            child: Column(
                children: fieldType.constructFilterFields(context, filterMap, widget.scaffoldKey)
            ),
          ),
          theme: ExpandableThemeData(hasIcon: true, tapHeaderToExpand: true),
        ));
        filterWidgetList.add(SizedBox(height: 10,));
        //filterWidgetList.addAll(fieldType.constructFilterFields(context));
      }
    });

    return AlertDialog(
      title: Text(widget.ornekKayit.singleTitle + " " + ConstantsBase.translate("filtreleme")),
      content: Container(
        height: ConstantsBase.getMaxHeight(context) * 0.8,
        width: ConstantsBase.getMaxWidth(context) * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: filterWidgetList,
          )
        )
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
            onPressed: () async{
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
            title: ConstantsBase.translate("filtrele"),
            iconData: Icons.filter_list,
            onPressed: () async {
              ConstantsBase.eventBus.fire(FilterChangedEvent(filterMap, baseModelPageId));
              await NavigatorBase.pop();
              return;
            },
          ),
        ),
      ],
    );
  }
}