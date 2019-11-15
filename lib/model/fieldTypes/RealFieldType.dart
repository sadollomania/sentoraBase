import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/pages/BaseModelDuzenleme.dart';

class RealFieldType extends BaseFieldType {
  RealFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required bool nullable,
    double defaultValue,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, defaultValue: defaultValue);

  @override
  Widget constructFormField(BaseModelDuzenlemeState state) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: fieldLabel),
      initialValue: state.kayit != null ? (state.kayit.get(name) != null ? state.kayit.get(name).toString() : null) : null,
      validator: (value) {
        if (!nullable && value.isEmpty || double.tryParse(value) == null) {
          return 'Ondalıklı sayı giriniz!';
        }
        return null;
      },
      onSaved: (value) {
        state.setState(() {
          if(state.kayit == null) {
            state.kayit = BaseModel.createNewObject(state.modelName);
          }
          state.kayit.set(name, double.parse(value));
        });
      },
    );
  }


}