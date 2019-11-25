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
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: null, nullableFn : nullableFn);

  @override
  Widget constructFormField(BaseModel kayit) {
    return Text("Blob Not Implmented Yet");
  }
}