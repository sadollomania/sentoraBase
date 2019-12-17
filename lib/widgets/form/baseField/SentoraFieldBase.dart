import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentora_base/model/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

class SentoraFieldBase extends StatefulWidget {
  final String title;
  final String hint;
  final String textValue;
  final dynamic realValue;
  final bool lastField;
  final bool readOnly;
  final void Function(String textValue, dynamic realValue) onSaved;
  final void Function(String sentoraFieldBaseStateUid, String textValue) onChanged;
  final void Function(String str) onFieldSubmitted;
  final String Function(String textValue, dynamic realValue) validator;
  final TextInputType keyboardType;
  final bool suffixCheckboxExists;
  final List<TextInputFormatter> inputFormatters;
  final void Function() suffixClearButtonFunc;
  final void Function() beforeInitState;
  final void Function() beforeDispose;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Future<dynamic> Function(String textValue, dynamic realValue, String sentoraFieldBaseStateUid, GlobalKey<ScaffoldState> scaffoldKey) onTapReplacementFunc;

  SentoraFieldBase({
    @required this.title,
    this.onSaved,
    this.textValue,
    this.realValue,
    this.hint,
    bool lastField,
    this.onChanged,
    bool suffixCheckboxExists,
    this.onFieldSubmitted,
    this.validator,
    this.keyboardType,
    this.suffixClearButtonFunc,
    this.beforeInitState,
    this.beforeDispose,
    this.onTapReplacementFunc,
    this.scaffoldKey,
    this.inputFormatters,
  }) : this.lastField = lastField ?? true,
    this.readOnly = onTapReplacementFunc != null,
    this.suffixCheckboxExists = suffixCheckboxExists ?? false;

  @override
  State<StatefulWidget> createState() => new _SentoraFieldBaseState();
}

class _SentoraFieldBaseState extends State<SentoraFieldBase> {
  dynamic realValue;
  String sentoraFieldBaseStateUid = ConstantsBase.getRandomUUID();
  TextEditingController tec;
  FocusNode focusNode;
  StreamSubscription valueChangeSubscription;

  void focusNodeListener() {
    if(focusNode.hasFocus) {
      focusNode.unfocus();
      widget.onTapReplacementFunc(tec.text, realValue, sentoraFieldBaseStateUid, widget.scaffoldKey).then((val){
        if(!widget.lastField && val != null && val != false) {
          List<FocusNode> focusNodeList = FocusScope.of(context).children.toList();
          int index = focusNodeList.indexOf(focusNode);
          FocusNode newFocusNode;
          for(int i = index + 1; i < focusNodeList.length; ++i) {
            newFocusNode = focusNodeList[i];
            if(newFocusNode.context.widget is EditableText) {
              break;
            }
          }
          FocusScope.of(context).requestFocus(newFocusNode);
        }
      });
    }
  }

  @override
  void initState() {
    realValue = widget.realValue;
    tec = TextEditingController(text: widget.textValue ?? "");
    focusNode = FocusNode();
    if(widget.onTapReplacementFunc != null) {
      focusNode.addListener(focusNodeListener);
    }
    if(widget.beforeInitState != null) {
      widget.beforeInitState();
    }
    valueChangeSubscription = ConstantsBase.eventBus.on<FormFieldValueChangedEvent>().listen((event){
      if(event.sentoraFieldBaseStateUid == sentoraFieldBaseStateUid) {
        setState(() {
          realValue = event.realValue;
          //tec.text = event.textValue;
          tec.value = tec.value.copyWith(text: event.textValue, selection: tec.selection);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    valueChangeSubscription.cancel();
    tec.dispose();
    if(widget.onTapReplacementFunc != null) {
      focusNode.removeListener(focusNodeListener);
    }
    focusNode.dispose();
    if(widget.beforeDispose != null) {
      widget.beforeDispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextFormField tff = TextFormField(
      controller: tec,
      readOnly: widget.readOnly,
      focusNode: focusNode,
      textInputAction : widget.lastField ? TextInputAction.done : TextInputAction.next,
      inputFormatters: widget.inputFormatters ?? null,
      decoration : InputDecoration(labelText: widget.title, hintText: widget.hint, suffixIcon : widget.suffixCheckboxExists ? Checkbox(
        value: realValue,
        tristate: true,
        onChanged: (value) {},
      ) : null),
      onSaved: (str) {
        if(widget.onSaved != null) {
          widget.onSaved(str, realValue);
        }
      },
      onChanged : (textValue) {
        if(widget.onChanged != null) {
          widget.onChanged(sentoraFieldBaseStateUid, textValue);
        }
      },
      onFieldSubmitted: widget.onFieldSubmitted ?? (_){},
      validator: (str){
        if(widget.validator != null) {
          return widget.validator(str, realValue);
        } else {
          return null;
        }
      },
      keyboardType: widget.keyboardType,
      onTap: widget.onTapReplacementFunc != null ? (){} : null,
    );
    if(widget.suffixClearButtonFunc != null) {
      return Stack(
        alignment: Alignment.centerRight,
        children: <Widget>[
          tff,
          IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  tec.text = "";
                  realValue = null;
                });
                widget.suffixClearButtonFunc();
              }
          )
        ],
      );
    } else {
      return tff;
    }
  }
}