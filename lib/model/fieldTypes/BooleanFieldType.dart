import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/widgets/form/field/BooleanField.dart';
import 'package:sentora_base/widgets/form/filterField/BooleanFilterField.dart';

class BooleanFieldType extends BaseFieldType {
  BooleanFieldType({
    required String fieldLabel,
    required String fieldHint,
    required String name,
    bool? nullable,
    bool? defaultValue,
    bool unique = false,
    bool Function(BaseModel baseModel)? nullableFn,
    bool sortable = true,
    bool filterable = true,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn, sortable : sortable, filterable : filterable);

  @override
  List<String> getFilterModes() {
    return List<String>.from(["booleq"]);
  }

  @override
  List<String> getFilterModeTitles() {
    return List<String>.from(["="]);
  }

  @override
  Widget constructFilterField(BuildContext context, Map<String, dynamic> filterMap, int filterIndex, GlobalKey<ScaffoldState> scaffoldKey) {
    return BooleanFilterField(
      context: context,
      fieldType: this,
      filterIndex: filterIndex,
      filterMap: filterMap,
      scaffoldKey: scaffoldKey,
    );
  }

  @override
  Widget constructFormField(BuildContext context, BaseModel kayit, bool lastField, GlobalKey<ScaffoldState> scaffoldKey) {
    return BooleanField(
      context: context,
      fieldType: this,
      kayit: kayit,
      lastField: lastField,
      scaffoldKey: scaffoldKey,
    );
  }
}