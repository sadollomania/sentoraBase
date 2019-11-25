import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/widgets/form/ForeignKeyFormField.dart';

class ForeignKeyFieldType extends BaseFieldType {
  final String foreignKeyModelName;
  BaseModel foreignKeyModel;
  VoidCallback onChange;

  ForeignKeyFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required this.foreignKeyModelName,
    bool nullable,
    BaseModel defaultValue,
    bool unique = false,
    bool Function(BaseModel baseModel) nullableFn,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn) {
    foreignKeyModel = BaseModel.createNewObject(foreignKeyModelName);
  }

  @override
  Widget constructFormField(BaseModel kayit) {
    return ForeignKeyFormField(
      fieldType: this,
      initialValue: kayit.get(name),
      onSaved: (BaseModel value) {
        kayit.set(name, value);
      },
      validator: (BaseModel value) {
        if (!isNullable(kayit) && value == null) {
          return fieldLabel + ' Seçiniz';
        }
        return null;
      },
    );
  }
}