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
    @required DateFieldType fieldType,
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
              return Container(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(fieldType.fieldLabel),
                    SizedBox(width: 10,),
                    SntIconButton(
                      edgeInsetsGeometry:EdgeInsets.all(0.0),
                      iconData: Icons.date_range,
                      fontSize: 18,
                      buttonColor: Colors.white,
                      onPressed: () {
                        DatePicker.showDatePicker(state.context,
                            theme: DatePickerTheme(
                              containerHeight: datePickerHeight,
                            ),
                            showTitleActions: true,
                            minTime: defaultMinTime,
                            maxTime: defaultMaxTime, onConfirm: (date) {
                              state.didChange(date);
                            }, currentTime: state.value != null ? state.value : DateTime.now(), locale: LocaleType.en);
                      },
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                        child: Text(
                          state.value != null
                              ? ConstantsBase.dateFormat.format(state.value)
                              : "",
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        )),
                    SizedBox(width: 10,),
                    SntIconButton(
                        edgeInsetsGeometry:EdgeInsets.all(0.0),
                        fontSize: 18,
                        buttonColor: Colors.white,
                        iconData: Icons.delete_outline,
                        onPressed: () {
                          state.didChange(null);
                        }),
                  ],
                ),
              );
            });
}
