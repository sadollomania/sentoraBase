import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';

class StringFieldType extends BaseFieldType {
  final int length;
  final int minLength;
  final int maxLength;

  StringFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    bool nullable,
    String defaultValue,
    bool unique = false,
    this.length = -1,
    this.minLength = -1,
    this.maxLength = -1,
    bool Function(BaseModel baseModel) nullableFn,
  }) : assert(length == -1 || length > 0),
        assert(length == -1 || ( minLength == -1 && maxLength == -1 )),
        assert(minLength == -1 || minLength > 0),
        assert(maxLength == -1 || maxLength > 0),
        assert(maxLength >= minLength),
        super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn);

  @override
  Widget constructFormField(BaseModel kayit) {
    return TextFormField(
      decoration: InputDecoration(labelText: fieldLabel, hintText: fieldHint),
      initialValue: kayit.get(name),
      onSaved: (value) {
        kayit.set(name, value);
      },
      validator: (value) {
        if(value.isEmpty) {
          if(isNullable(kayit)) {
            return null;
          } else {
            return fieldLabel + ' Boş Bırakılamaz';
          }
        } else {
          if(length != -1  && value.length != length) {
            return length.toString() + ' uzunluğunda bir yazı giriniz!';
          } else if(minLength != -1  && value.length < minLength) {
            return 'En az ' + minLength.toString() + ' uzunluğunda yazı giriniz!';
          } else if(maxLength != -1  && value.length > maxLength) {
            return 'En fazla ' + minLength.toString() + ' uzunluğunda yazı giriniz!';
          } else {
            return null;
          }
        }
      },
    );
  }
}