import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/events/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/TimeFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/field/BaseField.dart';

class TimeField extends BaseField {
  TimeField({
    required BuildContext context,
    required TimeFieldType fieldType,
    required BaseModel kayit,
    required bool lastField,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
    context: context,
    kayit: kayit,
    fieldType: fieldType,
    textValue : kayit.get(fieldType.name) != null ? ConstantsBase.timeFormat.format(kayit.get(fieldType.name)) : null,
    realValue : kayit.get(fieldType.name),
    lastField : lastField,
    onSaved : (textValue, realValue) {
      kayit.set(fieldType.name, realValue);
    },
    suffixClearButtonFunc: () {
      kayit.set(fieldType.name, null);
    },
    scaffoldKey : scaffoldKey,
    onTapReplacementFunc: (String textValue, dynamic realValue, String sentoraFieldBaseStateUid, GlobalKey<ScaffoldState> scaffoldKey,){
      return DatePicker.showTimePicker(context,
        theme: DatePickerTheme(
          containerHeight: ConstantsBase.datePickerHeight,
          //title: fieldType.fieldLabel,
        ),
        onConfirm: (date) {
          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, ConstantsBase.timeFormat.format(date), date));
          return true;
          /*if(!lastField) {
              FocusScope.of(context).nextFocus();
            }*/
        },
        currentTime: realValue ?? DateTime.now(),
        locale: ConstantsBase.convertLocaleToLocaleType()
      );
    }
  );
}