import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/baseField/SentoraFieldBase.dart';

class BaseField extends SentoraFieldBase{
  static String? _defaultExtraValidator(textValue, realValue) { return null; }

  BaseField({
    required BuildContext context,
    required BaseFieldType fieldType,
    required BaseModel kayit,
    required GlobalKey<ScaffoldState> scaffoldKey,
    void Function(String?, dynamic)? onSaved,
    void Function(String sentoraFieldBaseStateUid, String textValue)? onChanged,
    String? Function(String, dynamic) extraValidator = _defaultExtraValidator,
    String? textValue,
    dynamic realValue,
    bool lastField = false,
    TextInputType? keyboardType,
    bool? suffixCheckboxExists,
    void Function()? beforeInitState,
    void Function()? beforeDispose,
    void Function()? suffixClearButtonFunc,
    Future<dynamic> Function(String textValue, dynamic realValue, String sentoraFieldBaseStateUid, GlobalKey<ScaffoldState> scaffoldKey)? onTapReplacementFunc,
    List<TextInputFormatter>? inputFormatters,
  }) : super(
    title : fieldType.fieldLabel,
    hint : fieldType.fieldHint,
    onSaved : onSaved,
    textValue : textValue,
    realValue : realValue,
    lastField : lastField,
    onChanged : onChanged,
    suffixCheckboxExists : suffixCheckboxExists,
    beforeInitState : beforeInitState,
    beforeDispose : beforeDispose,
    inputFormatters : inputFormatters,
    onFieldSubmitted : (term){
      if(!lastField) {
        FocusScope.of(context).nextFocus();
      }
    },
    validator : (textValue, realValue) {
      if (realValue == null || realValue == "") {
        if (fieldType.isNullable(kayit)) {
          return null;
        } else {
          return fieldType.fieldLabel + ' ' + ConstantsBase.translate("bos_birakilamaz");
        }
      } else {
        return extraValidator(textValue!, realValue);
      }
    },
    keyboardType : keyboardType,
    suffixClearButtonFunc : suffixClearButtonFunc,
    onTapReplacementFunc : onTapReplacementFunc,
    scaffoldKey : scaffoldKey,
  );
}