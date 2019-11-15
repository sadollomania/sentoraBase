import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/pages/BaseModelDuzenleme.dart';
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
  Widget constructFormField(BaseModelDuzenlemeState state) {
    return BooleanFormField(
      booleanFieldType: this,
      initialValue: state.kayit != null ? state.kayit.get(name) : null,
      onSaved: (bool value) {
        state.setState(() {
          if(state.kayit == null) {
            state.kayit = BaseModel.createNewObject(state.modelName);
          }
          state.kayit.set(name, value);
        });
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