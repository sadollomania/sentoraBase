import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/events/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/StringFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/field/BaseField.dart';

class StringField extends BaseField {
  final String? Function(String value)? extraValidatorFunc;

  StringField({
    required BuildContext context,
    required StringFieldType fieldType,
    required BaseModel kayit,
    required bool lastField,
    required GlobalKey<ScaffoldState> scaffoldKey,
    this.extraValidatorFunc,
  }) : super(
    context: context,
    kayit: kayit,
    fieldType: fieldType,
    textValue : kayit.get(fieldType.name),
    realValue : kayit.get(fieldType.name),
    lastField : lastField,
    scaffoldKey : scaffoldKey,
    onChanged : (sentoraFieldBaseStateUid, textValue) {
      if(textValue.isEmpty) {
        ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, textValue, null));
      } else {
        ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, textValue, textValue));
      }
    },
    onSaved : (textValue, realValue) {
      kayit.set(fieldType.name, textValue);
    },
    extraValidator : (textValue, realValue) {
      if (fieldType.length != -1 && textValue.length != fieldType.length) {
        return fieldType.length.toString() + " " + ConstantsBase.translate("uzunlugunda_yazi_giriniz");
      } else if (fieldType.minLength != -1 && textValue.length < fieldType.minLength) {
        return ConstantsBase.translate("en_az") + " " + fieldType.minLength.toString() + " " + ConstantsBase.translate("uzunlugunda_yazi_giriniz");
      } else if (fieldType.maxLength != -1 && textValue.length > fieldType.maxLength) {
        return ConstantsBase.translate("en_fazla") + " " + fieldType.minLength.toString() + " " + ConstantsBase.translate("uzunlugunda_yazi_giriniz");
      } else {
        if(extraValidatorFunc != null) {
          return extraValidatorFunc(textValue);
        } else {
          return null;
        }
      }
    }
  );
}