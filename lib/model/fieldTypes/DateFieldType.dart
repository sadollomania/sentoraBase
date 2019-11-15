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
    @required bool nullable,
    String defaultValue,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, defaultValue: defaultValue);

  @override
  Widget constructFormField(BaseModel kayit) {
    return DateFormField(
      dateFieldType: this,
      initialValue: kayit.get(name),
      onSaved: (DateTime value) {
        kayit.set(name, value);
      },
      validator: (DateTime value) {
        if (!nullable && value == null) {
          return fieldLabel + ' Seçiniz';
        }
        return null;
      },
    );
  }
}