import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';

class BlobFieldType extends BaseFieldType {
  BlobFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    bool nullable,
    bool unique = false,
    bool Function(BaseModel baseModel) nullableFn,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: null, nullableFn : nullableFn, sortable : false, filterable : false);

  @override
  Widget constructFormField(BaseModel kayit, BuildContext context) {
    throw Exception("Blob Not Implmented Yet : constructFormField");
  }

  @override
  List<Widget> constructFilterFields(BuildContext context, Map<String, dynamic> filterMap) {
    throw Exception("Blob can not be filtered : constructFilterFields");
  }

  @override
  List<Widget> constructFilterButtons(BuildContext context, Map<String, dynamic> filterMap) {
    throw Exception("Blob can not be filtered : constructFilterButtons");
  }

  @override
  void clearFilterControllers() {
    //Nothing to clear
  }
}