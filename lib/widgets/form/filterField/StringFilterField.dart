import 'package:flutter/material.dart';
import 'package:sentora_base/model/FilterValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/StringFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/filterField/BaseFilterField.dart';

class StringFilterField extends BaseFilterField {
  StringFilterField({
    @required BuildContext context,
    @required StringFieldType fieldType,
    @required int filterIndex,
    @required Map<String, dynamic> filterMap,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
    fieldType: fieldType,
    filterIndex: filterIndex,
    textValue : filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]],
    realValue : filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]],
    scaffoldKey : scaffoldKey,
    onChanged : (sentoraFieldBaseStateUid, textValue) {
      if(textValue.isEmpty) {
        filterMap.remove(fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]);
      } else {
        filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] = textValue;
      }
      ConstantsBase.eventBus.fire(FilterValueChangedEvent());
    }
  );
}