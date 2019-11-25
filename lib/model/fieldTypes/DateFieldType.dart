import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/widgets/form/DateFormField.dart';

class DateFieldType extends BaseFieldType {
  DateFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    bool nullable,
    DateTime defaultValue,
    bool unique = false,
    bool Function(BaseModel baseModel) nullableFn,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn);

  @override
  Widget constructFormField(BaseModel kayit) {
    return DateFormField(
      fieldType: this,
      initialValue: kayit.get(name),
      onSaved: (DateTime value) {
        kayit.set(name, value);
      },
      validator: (DateTime value) {
        if (!isNullable(kayit) && value == null) {
          return fieldLabel + ' Seçiniz';
        }
        return null;
      },
    );
  }
}