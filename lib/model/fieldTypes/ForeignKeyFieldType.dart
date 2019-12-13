import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/widgets/form/field/ForeignField.dart';
import 'package:sentora_base/widgets/form/filterField/ForeignFilterField.dart';

class ForeignKeyFieldType extends BaseFieldType {
  final String foreignKeyModelName;
  final String foreignKeyTableName;
  BaseModel foreignKeyModel;
  VoidCallback onChange;

  ForeignKeyFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required this.foreignKeyModelName,
    @required this.foreignKeyTableName,
    bool nullable,
    BaseModel defaultValue,
    bool unique = false,
    bool Function(BaseModel baseModel) nullableFn,
    bool sortable = true,
    bool filterable = false,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn, sortable : sortable, filterable : filterable) {
    foreignKeyModel = BaseModel.createNewObject(foreignKeyModelName);
  }

  @override
  List<String> getFilterModes() {
    return List<String>.from(["foreigneq"]);
  }

  @override
  List<String> getFilterModeTitles() {
    return List<String>.from(["="]);
  }

  @override
  Widget constructFilterField(BuildContext context, Map<String, dynamic> filterMap, int filterIndex, GlobalKey<ScaffoldState> scaffoldKey) {
    return ForeignFilterField(
      context: context,
      fieldType: this,
      filterIndex: filterIndex,
      filterMap: filterMap,
      scaffoldKey: scaffoldKey,
    );
  }

  @override
  Widget constructFormField(BuildContext context, BaseModel kayit, bool lastField, GlobalKey<ScaffoldState> scaffoldKey) {
    return ForeignField(
      context: context,
      fieldType: this,
      kayit: kayit,
      lastField: lastField,
      scaffoldKey: scaffoldKey,
    );
  }
}