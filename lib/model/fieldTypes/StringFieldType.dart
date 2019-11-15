import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/pages/BaseModelDuzenleme.dart';

class StringFieldType extends BaseFieldType {
  StringFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required bool nullable,
    String defaultValue,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, defaultValue: defaultValue);

  @override
  Widget constructFormField(BaseModelDuzenlemeState state) {
    return TextFormField(
      decoration: InputDecoration(labelText: fieldLabel, hintText: fieldHint),
      initialValue: state.kayit != null ? state.kayit.get(name) : '',
      validator: (value) {
        if (!nullable && value.isEmpty) {
          return fieldLabel + ' Giriniz';
        }
        return null;
      },
      onSaved: (value) {
        state.setState(() {
          if(state.kayit == null) {
            state.kayit = BaseModel.createNewObject(state.modelName);
          }
          state.kayit.set(name, value);
        });
      },
    );
  }
}