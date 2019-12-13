import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/StringFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/field/BaseField.dart';

class StringField extends BaseField {
  StringField({
    @required BuildContext context,
    @required StringFieldType fieldType,
    @required BaseModel kayit,
    @required bool lastField,
    @required GlobalKey<ScaffoldState> scaffoldKey,
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
        return fieldType.length.toString() + ' uzunluğunda bir yazı giriniz!';
      } else if (fieldType.minLength != -1 && textValue.length < fieldType.minLength) {
        return 'En az ' + fieldType.minLength.toString() + ' uzunluğunda yazı giriniz!';
      } else if (fieldType.maxLength != -1 && textValue.length > fieldType.maxLength) {
        return 'En fazla ' + fieldType.minLength.toString() + ' uzunluğunda yazı giriniz!';
      } else {
        return null;
      }
    }
  );
}