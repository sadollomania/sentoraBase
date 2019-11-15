import 'package:flutter/src/widgets/framework.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/pages/BaseModelDuzenleme.dart';
import 'package:sentora_base/widgets/form/DateFormField.dart';

class DateFieldType extends BaseFieldType {
  DateFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required bool nullable,
    String defaultValue,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, defaultValue: defaultValue);

  @override
  Widget constructFormField(BaseModelDuzenlemeState state) {
    return DateFormField(
      dateFieldType: this,
      initialValue: state.kayit != null ? state.kayit.get(name) : null,
      onSaved: (DateTime value) {
        state.setState(() {
          if(state.kayit == null) {
            state.kayit = BaseModel.createNewObject(state.modelName);
          }
          state.kayit.set(name, value);
        });
      },
      validator: (DateTime value) {
        if (!nullable && value == null) {
          return fieldLabel + ' Seçiniz';
        }
        return null;
      },
    );
  }
}