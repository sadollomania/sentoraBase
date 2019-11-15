import 'package:flutter/material.dart';
import 'package:sentora_base/model/fieldTypes/BooleanFieldType.dart';

class BooleanFormField extends FormField<bool> {
  BooleanFormField({
    @required BooleanFieldType booleanFieldType,
    FormFieldSetter<bool> onSaved,
    FormFieldValidator<bool> validator,
    bool initialValue,
    bool autovalidate = false,
    bool enabled = true,
  }) : super(
      onSaved: onSaved,
      validator: validator,
      initialValue: initialValue,
      autovalidate: autovalidate,
      enabled: enabled,
      builder: (FormFieldState<bool> state) {
        return Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(child:Text(booleanFieldType.fieldLabel)),
                Checkbox(
                  value: state.value != null ? state.value : ( booleanFieldType.defaultValue != null ? booleanFieldType.defaultValue : null ),
                  tristate: booleanFieldType.defaultValue == null,
                  onChanged: (value) {
                    state.didChange(value);
                  },
                )
              ],
            )
        );
      });
}
