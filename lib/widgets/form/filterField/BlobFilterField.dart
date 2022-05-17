import 'package:flutter/material.dart';
import 'package:sentora_base/events/FilterValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/BlobFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/filterField/BaseFilterField.dart';

class BlobFilterField extends BaseFilterField {
  BlobFilterField({
    required BuildContext context,
    required BlobFieldType fieldType,
    required int filterIndex,
    required Map<String, dynamic> filterMap,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
    fieldType: fieldType,
    filterIndex: filterIndex,
    textValue : "",
    realValue : filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]],
    scaffoldKey : scaffoldKey,
    onChanged : (sentoraFieldBaseStateUid, textValue) {
      filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] = textValue;
      ConstantsBase.eventBus.fire(FilterValueChangedEvent());
    }
  );
}