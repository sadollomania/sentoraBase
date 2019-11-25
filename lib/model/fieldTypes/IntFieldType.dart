import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';

class IntFieldType extends BaseFieldType {
  final int length;
  final int minLength;
  final int maxLength;
  final bool signed;

  IntFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    bool nullable,
    int defaultValue,
    bool unique = false,
    this.length = -1,
    this.minLength = -1,
    this.maxLength = -1,
    this.signed = false,
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
      keyboardType: TextInputType.numberWithOptions(signed: signed, decimal: false),
      decoration: InputDecoration(labelText: fieldLabel),
      initialValue: kayit.get(name) != null ? kayit.get(name).toString() : null,
      onSaved: (value) {
        if(value.isNotEmpty) {
          kayit.set(name, int.parse(value));
        } else {
          kayit.set(name, null);
        }
      },
      validator: (value) {
        if(value.isEmpty) {
          if(isNullable(kayit)) {
            return null;
          } else {
            return fieldLabel + ' Boş Bırakılamaz';
          }
        } else {
          if(int.tryParse(value) == null) {
            return 'Tam sayı giriniz!';
          } else {
            String newStr = signed ? value.replaceAll("-", "") : value;
            if(length != -1  && newStr.length != length) {
              return length.toString() + ' uzunluğunda tam sayı giriniz!';
            } else if(minLength != -1  && newStr.length < minLength) {
              return 'En az ' + minLength.toString() + ' uzunluğunda tam sayı giriniz!';
            } else if(maxLength != -1  && newStr.length > maxLength) {
              return 'En fazla ' + minLength.toString() + ' uzunluğunda tam sayı giriniz!';
            } else {
              return null;
            }
          }
        }
      },
    );
  }
}