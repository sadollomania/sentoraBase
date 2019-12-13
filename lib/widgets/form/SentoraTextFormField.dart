/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentora_base/model/FilterValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/model/fieldTypes/BlobFieldType.dart';
import 'package:sentora_base/model/fieldTypes/BooleanFieldType.dart';
import 'package:sentora_base/model/fieldTypes/DateFieldType.dart';
import 'package:sentora_base/model/fieldTypes/ForeignKeyFieldType.dart';
import 'package:sentora_base/model/fieldTypes/FormAttributes.dart';
import 'package:sentora_base/model/fieldTypes/IntFieldType.dart';
import 'package:sentora_base/model/fieldTypes/RealFieldType.dart';
import 'package:sentora_base/model/fieldTypes/StringFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

class SentoraTextFormField extends TextFormField {
  SentoraTextFormField({
    BuildContext context,
    BaseFieldType fieldType,
    String filterMode,
    FormAttributes formAttributes,
    int focusIndex,
    Key key,
    TextEditingController controller,
    String initialValue,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextStyle style,
    StrutStyle strutStyle,
    TextDirection textDirection,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    ToolbarOptions toolbarOptions,
    bool showCursor,
    bool obscureText = false,
    bool autocorrect = true,
    bool autovalidate = false,
    bool maxLengthEnforced = true,
    int maxLines = 1,
    int minLines,
    bool expands = false,
    int maxLength,
    VoidCallback onEditingComplete,
    List<TextInputFormatter> inputFormatters,
    bool enabled = true,
    double cursorWidth = 2.0,
    Radius cursorRadius,
    Color cursorColor,
    Brightness keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    InputCounterWidgetBuilder buildCounter,
  }) : super(
    key : key,
    controller : formAttributes.tecMap[ConstantsBase.getCompFieldName(fieldType.name, filterMode)],
    focusNode : focusIndex != null ? formAttributes.focusNodes[focusIndex] : null,
    textInputAction : focusIndex == null ? TextInputAction.done : getTextInputAction(formAttributes.focusNodes, focusIndex),
    decoration : InputDecoration(labelText: fieldType.fieldLabel + ( filterMode != null ? " " + filterMode + " " : "" ), hintText: fieldType.fieldHint, suffixIcon: getSuffixIcon(fieldType, formAttributes, filterMode)),
    onTap : fieldType.overrideOnTapFunction(context, formAttributes, focusIndex, filterMode),
    readOnly : getReadOnly(fieldType),
    onSaved: (value) {
      switch(fieldType.runtimeType) {
        case StringFieldType:
          formAttributes.formKayit.set(ConstantsBase.getCompFieldName(fieldType.name, filterMode), value);
          break;
        case IntFieldType:
          if (value.isNotEmpty) {
            formAttributes.formKayit.set(ConstantsBase.getCompFieldName(fieldType.name, filterMode), int.parse(value));
          } else {
            formAttributes.formKayit.set(ConstantsBase.getCompFieldName(fieldType.name, filterMode), null);
          }
          break;
        case RealFieldType:
          if(value.isNotEmpty) {
            int fractionLength = (fieldType as RealFieldType).fractionLength;
            if(fractionLength == -1) {
              formAttributes.formKayit.set(ConstantsBase.getCompFieldName(fieldType.name, filterMode), double.parse(value));
            } else {
              double d = double.parse(value);
              String newStr = d.toStringAsFixed(fractionLength);
              formAttributes.formKayit.set(ConstantsBase.getCompFieldName(fieldType.name, filterMode), double.parse(newStr));
            }
          } else {
            formAttributes.formKayit.set(ConstantsBase.getCompFieldName(fieldType.name, filterMode), null);
          }
          break;
        case DateFieldType:
          if(value.isNotEmpty) {
            formAttributes.formKayit.set(ConstantsBase.getCompFieldName(fieldType.name, filterMode), ConstantsBase.dateFormat.parse(value));
          } else {
            formAttributes.formKayit.set(ConstantsBase.getCompFieldName(fieldType.name, filterMode), null);
          }
          break;
      }
    },
    onChanged : (value) {
      if(filterMode != null && filterMode.isNotEmpty) {
        if(value == "") {
          ConstantsBase.eventBus.fire(FilterValueChangedEvent(fieldType.name, filterMode, null));
        } else {
          ConstantsBase.eventBus.fire(FilterValueChangedEvent(fieldType.name, filterMode, value));
        }
      }
    },
    onFieldSubmitted: (term){
      if(focusIndex != null) {
        fieldFocusChange(context, formAttributes.focusNodes, focusIndex);
      }
    },
    validator: (value) {
      var val = formAttributes.formKayit.get(fieldType.name);
      if (val == null || value == null || value.isEmpty) {
        if (fieldType.isNullable(formAttributes.formKayit)) {
          return null;
        } else {
          return fieldType.fieldLabel + ' Boş Bırakılamaz';
        }
      } else {
        return fieldType.extraValidator(value, val);
      }
    },
    keyboardType : getKeyboardTypeFromField(fieldType),
    initialValue : initialValue,
    textCapitalization : textCapitalization,
    style : style,
    strutStyle : strutStyle,
    textDirection : textDirection,
    textAlign : textAlign,
    autofocus : autofocus,
    toolbarOptions : toolbarOptions,
    showCursor : showCursor,
    obscureText : obscureText,
    autocorrect : autocorrect,
    autovalidate : autovalidate,
    maxLengthEnforced : maxLengthEnforced,
    maxLines : maxLines,
    minLines : minLines,
    expands : expands,
    maxLength : maxLength,
    onEditingComplete : onEditingComplete,
    inputFormatters : inputFormatters,
    enabled : enabled,
    cursorWidth : cursorWidth,
    cursorRadius : cursorRadius,
    cursorColor : cursorColor,
    keyboardAppearance : keyboardAppearance,
    scrollPadding : scrollPadding,
    enableInteractiveSelection : enableInteractiveSelection,
    buildCounter : buildCounter,
  );

  static bool getReadOnly(BaseFieldType fieldType) {
    switch(fieldType.runtimeType) {
      case BlobFieldType:
      case ForeignKeyFieldType:
      case BooleanFieldType:
      case DateFieldType:
        return true;
      case StringFieldType:
      case RealFieldType:
      case IntFieldType:
      default:
        return false;
    }
  }

  static TextInputType getKeyboardTypeFromField(BaseFieldType fieldType) {
    switch(fieldType.runtimeType) {
      case IntFieldType:
        return TextInputType.numberWithOptions(signed: (fieldType as IntFieldType).signed, decimal: false);
      case RealFieldType:
        return TextInputType.numberWithOptions(signed: (fieldType as RealFieldType).signed, decimal: true);
      case StringFieldType:
      case BlobFieldType:
      case ForeignKeyFieldType:
      case BooleanFieldType:
      case DateFieldType:
      default:
        return null;
    }
  }

  static TextInputAction getTextInputAction(List<FocusNode> focusNodes, int focusIndex) {
    if(focusNodes == null || focusNodes.length == 0) {
      return null;
    }

    if(focusIndex != focusNodes.length - 1) {
      return TextInputAction.next;
    } else {
      return TextInputAction.done;
    }
  }

  static void fieldFocusChange(BuildContext context, List<FocusNode> focusNodes, int focusIndex) {
    if(focusIndex == null) {
      return;
    }

    if(focusIndex != focusNodes.length - 1) {
      FocusScope.of(context).requestFocus(focusNodes[focusIndex+1]);
    }/* else {
      focusNodes[focusIndex].unfocus();
    }*/
  }

  static Widget getSuffixIcon(BaseFieldType fieldType, FormAttributes formAttributes, String filterMode) {
    if(fieldType is BooleanFieldType) {
      return Checkbox(
        value: formAttributes.formKayit.get(ConstantsBase.getCompFieldName(fieldType.name, filterMode)),
        tristate: true,
        onChanged: (value) {
          formAttributes.formKayit.set(ConstantsBase.getCompFieldName(fieldType.name, filterMode), value);
        },
      );
    }
    return null;
  }
}*/