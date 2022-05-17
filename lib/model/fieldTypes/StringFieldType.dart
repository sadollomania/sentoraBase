import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/widgets/form/field/StringField.dart';
import 'package:sentora_base/widgets/form/filterField/StringFilterField.dart';

class StringFieldType extends BaseFieldType {
  final int length;
  final int minLength;
  final int maxLength;

  StringFieldType({
    required String fieldLabel,
    required String fieldHint,
    required String name,
    bool? nullable,
    String? defaultValue,
    bool unique = false,
    this.length = -1,
    this.minLength = -1,
    this.maxLength = -1,
    bool Function(BaseModel baseModel)? nullableFn,
    bool sortable = true,
    bool filterable = true,
  }) : assert(length == -1 || length > 0),
        assert(length == -1 || ( minLength == -1 && maxLength == -1 )),
        assert(minLength == -1 || minLength > 0),
        assert(maxLength == -1 || maxLength > 0),
        assert(maxLength >= minLength),
        super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn, sortable : sortable, filterable : filterable);

  @override
  List<String> getFilterModes() {
    return List<String>.from(["like"]);
  }

  @override
  List<String> getFilterModeTitles() {
    return List<String>.from(["~"]);
  }

  @override
  Widget constructFilterField(BuildContext context, Map<String, dynamic> filterMap, int filterIndex, GlobalKey<ScaffoldState> scaffoldKey) {
    return StringFilterField(
      context: context,
      fieldType: this,
      filterIndex: filterIndex,
      filterMap: filterMap,
      scaffoldKey: scaffoldKey,
    );
  }

  @override
  Widget constructFormField(BuildContext context, BaseModel kayit, bool lastField, GlobalKey<ScaffoldState> scaffoldKey) {
    return StringField(
      context: context,
      fieldType: this,
      kayit: kayit,
      lastField: lastField,
      scaffoldKey: scaffoldKey,
    );
  }
}