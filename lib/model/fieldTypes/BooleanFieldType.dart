import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/widgets/form/BooleanFormField.dart';

class BooleanFieldType extends BaseFieldType {
  BooleanFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    bool nullable,
    bool defaultValue,
    bool unique = false,
    bool Function(BaseModel baseModel) nullableFn,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn);

  @override
  Widget constructFormField(BaseModel kayit) {
    return BooleanFormField(
      booleanFieldType: this,
      initialValue: kayit.get(name),
      onSaved: (bool value) {
        kayit.set(name, value);
      },
      validator: (bool value) {
        if (!isNullable(kayit) && value == null) {
          return fieldLabel + ' Giriniz';
        }
        return null;
      },
    );
  }
}