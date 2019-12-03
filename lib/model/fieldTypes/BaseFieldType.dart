import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';

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

  Widget constructFormField(BaseModel kayit, BuildContext context);
  List<Widget> constructFilterFields(BuildContext context, Map<String, dynamic> filterMap);
  List<Widget> constructFilterButtons(BuildContext context, Map<String, dynamic> filterMap);
  void clearFilterControllers();

  bool isNullable(BaseModel kayit) {
    if(nullable == null) {
      return nullableFn(kayit);
    } else {
      return nullable;
    }
  }

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
      throw new Exception("Field Adı & ya da . işareti bulunduramaz!");
    }
    if(name.endsWith("-eq") || name.endsWith("-qt") || name.endsWith("-lt") || name.endsWith("-like")) {
      throw new Exception("Field Adı '-eq','-qt','-lt','-like' ile bitemez!");
    }
  }
}