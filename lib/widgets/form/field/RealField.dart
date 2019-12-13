import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/RealFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/field/BaseField.dart';

class RealField extends BaseField {
  RealField({
    @required BuildContext context,
    @required RealFieldType fieldType,
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
      keyboardType : TextInputType.numberWithOptions(signed: fieldType.signed, decimal: true),
      scaffoldKey : scaffoldKey,
      onChanged : (sentoraFieldBaseStateUid, textValue) {
        if(textValue.isEmpty) {
          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, textValue, null));
        } else {
          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, textValue, double.parse(textValue)));
        }
      },
      onSaved : (textValue, realValue) {
        if (textValue.isNotEmpty) {
          kayit.set(fieldType.name, double.parse(textValue));
        } else {
          kayit.set(fieldType.name, null);
        }
      },
      extraValidator : (textValue, realValue) {
        if(double.tryParse(textValue) == null) {
          return 'Ondalıklı sayı giriniz!';
        } else {
          String newStr = fieldType.signed ? textValue.replaceAll("-", "") : textValue;
          String intPart = newStr.contains(".") ? newStr.split(".")[0] : newStr;
          if(fieldType.length != -1  && intPart.length != fieldType.length) {
            return 'Noktadan önce ' + fieldType.length.toString() + ' uzunluğunda ondalıklı sayı giriniz!';
          } else if(fieldType.minLength != -1  && intPart.length < fieldType.minLength) {
            return 'Noktadan önce En az ' + fieldType.minLength.toString() + ' uzunluğunda ondalıklı sayı giriniz!';
          } else if(fieldType.maxLength != -1  && intPart.length > fieldType.maxLength) {
            return 'Noktadan önce En fazla ' + fieldType.minLength.toString() + ' uzunluğunda ondalıklı sayı giriniz!';
          } else {
            return null;
          }
        }
      }
  );
}