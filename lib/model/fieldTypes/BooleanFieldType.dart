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
    @required bool nullable,
    bool defaultValue,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, defaultValue: defaultValue);

  @override
  Widget constructFormField(BaseModel kayit) {
    return BooleanFormField(
      booleanFieldType: this,
      initialValue: kayit.get(name),
      onSaved: (bool value) {
        kayit.set(name, value);
      },
      validator: (bool value) {
        if (!nullable && value == null) {
          return fieldLabel + ' Giriniz';
        }
        return null;
      },
    );
  }
}