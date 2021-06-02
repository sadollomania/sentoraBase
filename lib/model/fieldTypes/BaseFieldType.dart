import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';

abstract class BaseFieldType {
  String fieldLabel;
  String fieldHint;
  String name;
  bool nullable;
  bool multiple;
  bool unique;
  bool Function(BaseModel baseModel) nullableFn;
  bool sortable;
  bool filterable;
  dynamic defaultValue;

  List<String> getFilterModes();
  List<String> getFilterModeTitles();
  Widget constructFormField(BuildContext context, BaseModel kayit, bool lastField, GlobalKey<ScaffoldState> scaffoldKey);
  Widget constructFilterField(BuildContext context, Map<String, dynamic> filterMap, int filterIndex, GlobalKey<ScaffoldState> scaffoldKey);

  BaseFieldType({
    @required this.fieldLabel,
    @required this.fieldHint,
    @required this.name,
    @required this.multiple,
    @required this.unique,
    @required this.defaultValue,
    @required this.nullable,
    @required this.nullableFn,
    this.sortable = true,
    this.filterable = true,
  }) : assert(fieldLabel != null && fieldLabel.isNotEmpty),
        assert(name != null && name.isNotEmpty),
        assert((nullable == null && nullableFn != null) || (nullable != null && nullableFn == null)) {
    if(name.contains("&") || name.contains(".")) {
      throw new Exception(ConstantsBase.translate("field_adi_bulunduramaz"));
    }
    if(name.endsWith("-eq") || name.endsWith("-qt") || name.endsWith("-lt") || name.endsWith("-like")) {
      throw new Exception(ConstantsBase.translate("field_adi_ile_bitemez"));
    }
    if(getFilterModes().length != getFilterModeTitles().length) {
      throw new Exception("getFilterModes() ile getFilterModeTitles() uzunlukları aynı olmalı.");
    }
  }

  List<Widget> constructFilterFields(BuildContext context, Map<String, dynamic> filterMap, GlobalKey<ScaffoldState> scaffoldKey) {
    List<String> filterModes = getFilterModes();
    List<Widget> retList = [];
    for(int i = 0, len = filterModes.length; i < len; ++i) {
      retList.add(constructFilterField(context, filterMap, i, scaffoldKey));
    }
    return retList;
  }

  List<Widget> constructFilterButtons(BuildContext context, Map<String, dynamic> filterMap) {
    List<String> filterModes = getFilterModes();
    List<String> filterModeTitles = getFilterModeTitles();
    List<Widget> retList = [];
    for(int i = 0, len = filterModes.length; i < len; ++i) {
      String filterMode = filterModes[i];
      String filterModeTitle = filterModeTitles[i];
      retList.add(SizedBox(
        width: ConstantsBase.filterDetailButtonWidth,
        child: MenuButton(
          edgeInsetsGeometry: ConstantsBase.filterButtonEdges,
          title: filterModeTitle,
          fontSize: ConstantsBase.filterButtonFontSize,
          buttonColor: filterMap[name + "-" + filterMode] != null ? Colors.greenAccent : ConstantsBase.defaultDisabledColor,
          onPressed: (){return;},
        ),
      ));
      retList.add(SizedBox(width:2));
    }
    return retList;
  }

  bool isNullable(BaseModel kayit) {
    if(nullable == null) {
      return nullableFn(kayit);
    } else {
      return nullable;
    }
  }
}