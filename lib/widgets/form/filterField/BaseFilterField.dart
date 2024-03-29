import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/widgets/form/baseField/SentoraFieldBase.dart';

class BaseFilterField extends SentoraFieldBase{
  BaseFilterField({
    required BaseFieldType fieldType,
    required int filterIndex,
    required GlobalKey<ScaffoldState> scaffoldKey,
    void Function(String sentoraFieldBaseStateUid, String textValue)? onChanged,
    String? textValue,
    dynamic realValue,
    TextInputType? keyboardType,
    void Function()? suffixClearButtonFunc,
    Future<dynamic> Function(String textValue, dynamic realValue, String sentoraFieldBaseStateUid, GlobalKey<ScaffoldState> scaffoldKey)? onTapReplacementFunc,
    List<TextInputFormatter>? inputFormatters,
    bool? suffixCheckboxExists,
  }) : super(
    title : fieldType.fieldLabel + " " + fieldType.getFilterModeTitles()[filterIndex],
    textValue : textValue,
    realValue : realValue,
    hint : fieldType.fieldHint,
    lastField : true,
    onChanged : onChanged,
    inputFormatters : inputFormatters,
    keyboardType : keyboardType,
    suffixClearButtonFunc : suffixClearButtonFunc,
    onTapReplacementFunc : onTapReplacementFunc,
    scaffoldKey : scaffoldKey,
    suffixCheckboxExists : suffixCheckboxExists,
  );
}