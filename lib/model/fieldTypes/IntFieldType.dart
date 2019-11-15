import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';

class IntFieldType extends BaseFieldType {
  IntFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required bool nullable,
    int defaultValue,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, defaultValue: defaultValue);

  @override
  Widget constructFormField(BaseModel kayit) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: fieldLabel),
      initialValue: kayit.get(name) != null ? kayit.get(name).toString() : null,
      validator: (value) {
        if (!nullable && value.isEmpty || int.tryParse(value) == null) {
          return 'Bir tam sayı giriniz!';
        }
        return null;
      },
      onSaved: (value) {
        kayit.set(name, int.parse(value));
      },
    );
  }
}