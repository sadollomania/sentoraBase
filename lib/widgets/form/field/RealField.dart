import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/events/FormFieldValueChangedEvent.dart';
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
      inputFormatters : ConstantsBase.getNumberTextInputFormatters(signed: fieldType.signed, decimal: true),
      keyboardType : TextInputType.numberWithOptions(signed: fieldType.signed, decimal: true),
      scaffoldKey : scaffoldKey,
      onChanged : (sentoraFieldBaseStateUid, textValue) {
        if(textValue.isEmpty) {
          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, textValue, null));
        } else {
          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, textValue, ConstantsBase.parseDouble(textValue)));
        }
      },
      onSaved : (textValue, realValue) {
        if (textValue.isNotEmpty) {
          kayit.set(fieldType.name, ConstantsBase.parseDouble(textValue));
        } else {
          kayit.set(fieldType.name, null);
        }
      },
      extraValidator : (textValue, realValue) {
        if(ConstantsBase.tryParseDouble(textValue) == null) {
          return ConstantsBase.translate("ondalikli_sayi_giriniz");
        } else {
          String newStr = fieldType.signed ? textValue.replaceAll("-", "") : textValue;
          String intPart = newStr.contains(".") ? newStr.split(".")[0] : newStr;
          if(fieldType.length != -1  && intPart.length != fieldType.length) {
            return ConstantsBase.translate("noktadan_once") + " " + fieldType.length.toString() + " " + ConstantsBase.translate("uzunlugunda_ondalikli_sayi_giriniz");
          } else if(fieldType.minLength != -1  && intPart.length < fieldType.minLength) {
            return ConstantsBase.translate("noktadan_once") + " " + ConstantsBase.translate("en_az") + " " + fieldType.minLength.toString() + " " + ConstantsBase.translate("uzunlugunda_ondalikli_sayi_giriniz");
          } else if(fieldType.maxLength != -1  && intPart.length > fieldType.maxLength) {
            return ConstantsBase.translate("noktadan_once") + " " + ConstantsBase.translate("en_fazla") + " " + fieldType.minLength.toString() + " " + ConstantsBase.translate("uzunlugunda_ondalikli_sayi_giriniz");
          } else {
            return null;
          }
        }
      }
  );
}