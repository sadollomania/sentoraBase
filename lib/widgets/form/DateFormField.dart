import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sentora_base/model/fieldTypes/DateFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/SntIconButton.dart';

class DateFormField extends FormField<DateTime> {
  static final double datePickerHeight = 210;
  static final DateTime defaultMinTime = DateTime(2000, 1, 1);
  static final DateTime defaultMaxTime = DateTime(2199, 12, 31);

  DateFormField({
    @required DateFieldType dateFieldType,
    FormFieldSetter<DateTime> onSaved,
    FormFieldValidator<DateTime> validator,
    DateTime initialValue,
    bool autovalidate = false,
    bool enabled = true,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidate: autovalidate,
            enabled: enabled,
            builder: (FormFieldState<DateTime> state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(dateFieldType.fieldLabel),
                  SntIconButton(
                    iconData: Icons.date_range,
                    onPressed: () {
                      DatePicker.showDatePicker(state.context,
                          theme: DatePickerTheme(
                            containerHeight: datePickerHeight,
                          ),
                          showTitleActions: true,
                          minTime: defaultMinTime,
                          maxTime: defaultMaxTime, onConfirm: (date) {
                        state.didChange(date);
                      }, currentTime: initialValue, locale: LocaleType.en);
                    },
                  ),
                  Expanded(
                      child: Text(
                    state.value != null
                        ? ConstantsBase.dateFormat.format(state.value)
                        : "",
                    style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  )),
                  SntIconButton(
                      iconData: Icons.delete_outline,
                      onPressed: () {
                        state.didChange(null);
                      }),
                ],
              );
            });
}
