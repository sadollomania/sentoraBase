import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/widgets/form/field/DateField.dart';
import 'package:sentora_base/widgets/form/filterField/DateFilterField.dart';

class DateFieldType extends BaseFieldType {
  static final double datePickerHeight = 210;
  static final DateTime defaultMinTime = DateTime(2000, 1, 1);
  static final DateTime defaultMaxTime = DateTime(2199, 12, 31);

  DateFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    bool nullable,
    DateTime defaultValue,
    bool unique = false,
    bool Function(BaseModel baseModel) nullableFn,
    bool sortable = true,
    bool filterable = true,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn, sortable : sortable, filterable : filterable);

  @override
  List<String> getFilterModes() {
    return List<String>.from(["dateeq","dategt","datelt"]);
  }

  @override
  List<String> getFilterModeTitles() {
    return List<String>.from(["=",">","<"]);
  }

  @override
  Widget constructFilterField(BuildContext context, Map<String, dynamic> filterMap, int filterIndex, GlobalKey<ScaffoldState> scaffoldKey) {
    return DateFilterField(
      context: context,
      fieldType: this,
      filterIndex: filterIndex,
      filterMap: filterMap,
      scaffoldKey: scaffoldKey,
    );
  }

  @override
  Widget constructFormField(BuildContext context, BaseModel kayit, bool lastField, GlobalKey<ScaffoldState> scaffoldKey) {
    return DateField(
      context: context,
      fieldType: this,
      kayit: kayit,
      lastField: lastField,
      scaffoldKey: scaffoldKey,
    );
  }
}