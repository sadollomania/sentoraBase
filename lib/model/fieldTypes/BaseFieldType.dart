import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';

abstract class BaseFieldType {
  String fieldLabel;
  String fieldHint;
  String name;
  bool nullable;
  bool multiple;
  dynamic defaultValue;

  Widget constructFormField(BaseModel kayit);

  BaseFieldType({
    @required this.fieldLabel,
    @required this.fieldHint,
    @required this.name,
    @required this.nullable,
    @required this.multiple,
    this.defaultValue
  }) {
    if(this.name.contains("&") || this.name.contains(".")) {
      throw new Exception("Field Adı & ya da . işareti bulunduramaz!");
    }
  }
}