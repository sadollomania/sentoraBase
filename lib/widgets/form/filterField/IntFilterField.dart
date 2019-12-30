import 'package:flutter/material.dart';
import 'package:sentora_base/events/FilterValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/IntFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/filterField/BaseFilterField.dart';

class IntFilterField extends BaseFilterField {
  IntFilterField({
    @required BuildContext context,
    @required IntFieldType fieldType,
    @required int filterIndex,
    @required Map<String, dynamic> filterMap,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
      fieldType: fieldType,
      filterIndex: filterIndex,
      textValue : filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] != null ? filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]].toString() : "",
      realValue : filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]],
      inputFormatters : ConstantsBase.getNumberTextInputFormatters(signed: fieldType.signed, decimal: false),
      keyboardType : TextInputType.numberWithOptions(signed: fieldType.signed, decimal: false),
      scaffoldKey : scaffoldKey,
      onChanged : (sentoraFieldBaseStateUid, textValue) {
        if(textValue.isEmpty) {
          filterMap.remove(fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]);
        } else {
          filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] = int.parse(textValue);
        }
        ConstantsBase.eventBus.fire(FilterValueChangedEvent());
      }
  );
}