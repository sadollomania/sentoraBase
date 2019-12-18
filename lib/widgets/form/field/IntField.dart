import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/IntFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/field/BaseField.dart';

class IntField extends BaseField {
  IntField({
    @required BuildContext context,
    @required IntFieldType fieldType,
    @required BaseModel kayit,
    @required bool lastField,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
    context: context,
    fieldType: fieldType,
    kayit: kayit,
    textValue : kayit.get(fieldType.name) != null ? kayit.get(fieldType.name).toString() : null,
    realValue : kayit.get(fieldType.name),
    lastField : lastField,
    inputFormatters : ConstantsBase.getNumberTextInputFormatters(signed: fieldType.signed, decimal: false),
    keyboardType : TextInputType.numberWithOptions(signed: fieldType.signed, decimal: false),
    scaffoldKey : scaffoldKey,
    onSaved : (textValue, realValue) {
      if (textValue.isNotEmpty) {
        kayit.set(fieldType.name, int.parse(textValue));
      } else {
        kayit.set(fieldType.name, null);
      }
    },
    onChanged : (sentoraFieldBaseStateUid, textValue) {
      if(textValue.isEmpty) {
        ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, textValue, null));
      } else {
        ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, textValue, int.parse(textValue)));
      }
    },
    extraValidator : (textValue, realValue) {
      if(int.tryParse(textValue) == null) {
        return 'Tam sayı giriniz!';
      } else {
        String newStr = fieldType.signed ? textValue.replaceAll("-", "") : textValue;
        if(fieldType.length != -1  && newStr.length != fieldType.length) {
          return fieldType.length.toString() + ' uzunluğunda tam sayı giriniz!';
        } else if(fieldType.minLength != -1  && newStr.length < fieldType.minLength) {
          return 'En az ' + fieldType.minLength.toString() + ' uzunluğunda tam sayı giriniz!';
        } else if(fieldType.maxLength != -1  && newStr.length > fieldType.maxLength) {
          return 'En fazla ' + fieldType.minLength.toString() + ' uzunluğunda tam sayı giriniz!';
        } else {
          return null;
        }
      }
    }
  );
}