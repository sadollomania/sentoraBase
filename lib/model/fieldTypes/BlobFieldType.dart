import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';

class BlobFieldType extends BaseFieldType {
  BlobFieldType({
    required String fieldLabel,
    required String fieldHint,
    required String name,
    bool? nullable,
    bool unique = false,
    bool Function(BaseModel baseModel)? nullableFn,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: null, nullableFn : nullableFn, sortable : false, filterable : false);

  @override
  List<String> getFilterModes() {
    throw Exception("Blob Not Implmented Yet : getFilterModes");
  }

  @override
  List<String> getFilterModeTitles() {
    throw Exception("Blob Not Implmented Yet : getFilterModeTitles");
  }

  @override
  Widget constructFilterField(BuildContext context, Map<String, dynamic> filterMap, int filterIndex, GlobalKey<ScaffoldState> scaffoldKey) {
    throw Exception("Blob Not Implmented Yet : constructFilterField");
  }

  @override
  Widget constructFormField(BuildContext context, BaseModel kayit, bool lastField, GlobalKey<ScaffoldState> scaffoldKey) {
    throw Exception("Blob Not Implmented Yet : constructFormField");
  }
}