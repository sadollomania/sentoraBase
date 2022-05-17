import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sentora_base/events/FilterValueChangedEvent.dart';
import 'package:sentora_base/events/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/DateFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/filterField/BaseFilterField.dart';

class DateFilterField extends BaseFilterField {
  DateFilterField({
    required BuildContext context,
    required DateFieldType fieldType,
    required int filterIndex,
    required Map<String, dynamic> filterMap,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
    fieldType: fieldType,
    filterIndex: filterIndex,
    textValue : filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] != null ? ConstantsBase.dateFormat.format(filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]]) : "",
    realValue : filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]],
    suffixClearButtonFunc: () {
      filterMap.remove(fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]);
      ConstantsBase.eventBus.fire(FilterValueChangedEvent());
    },
    scaffoldKey : scaffoldKey,
    onTapReplacementFunc: (String textValue, dynamic realValue, String sentoraFieldBaseStateUid, GlobalKey<ScaffoldState> scaffoldKey){
      return DatePicker.showDatePicker(context,
          theme: DatePickerTheme(
            containerHeight: ConstantsBase.datePickerHeight,
            //title: fieldType.fieldLabel,
          ),
          showTitleActions: true,
          minTime: ConstantsBase.defaultMinTime,
          maxTime: ConstantsBase.defaultMaxTime,
          onConfirm: (date) {
            ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, ConstantsBase.dateFormat.format(date), date));
            filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] = date;
            ConstantsBase.eventBus.fire(FilterValueChangedEvent());
            return true;
          },
          currentTime: realValue ?? DateTime.now(),
          locale: ConstantsBase.convertLocaleToLocaleType()
      );
    }
  );
}