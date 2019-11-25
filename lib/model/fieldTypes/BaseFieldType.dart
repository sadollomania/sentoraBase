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
  dynamic defaultValue;

  Widget constructFormField(BaseModel kayit);

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
    @required this.nullableFn
  }) : assert(fieldLabel != null && fieldLabel.isNotEmpty),
        assert(name != null && name.isNotEmpty),
        assert((nullable == null && nullableFn != null) || (nullable != null && nullableFn == null)) {
    if(this.name.contains("&") || this.name.contains(".")) {
      throw new Exception("Field Adı & ya da . işareti bulunduramaz!");
    }
  }
}