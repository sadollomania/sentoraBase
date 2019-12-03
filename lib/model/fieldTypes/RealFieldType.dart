import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/FilterValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';

class RealFieldType extends BaseFieldType {
  static final List<String> filterModes = List<String>.from(["realeq","realgt","reallt"]);
  static final List<String> filterModeTitles = List<String>.from(["=",">","<"]);

  final int length;
  final int minLength;
  final int maxLength;
  final int fractionLength;
  final bool signed;

  RealFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    bool nullable,
    double defaultValue,
    bool unique = false,
    this.length = -1,
    this.minLength = -1,
    this.maxLength = -1,
    this.fractionLength = -1,
    this.signed = false,
    bool Function(BaseModel baseModel) nullableFn,
    bool sortable = true,
    bool filterable = true,
  }) : assert(length == -1 || length > 0),
        assert(length == -1 || ( minLength == -1 && maxLength == -1 )),
        assert(minLength == -1 || minLength > 0),
        assert(maxLength == -1 || maxLength > 0),
        assert(maxLength >= minLength),
        assert(fractionLength == -1 || fractionLength > 0),
        super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn, sortable : sortable, filterable : filterable);

  @override
  Widget constructFormField(BaseModel kayit, BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(signed: signed, decimal: true),
      decoration: InputDecoration(labelText: fieldLabel),
      initialValue: kayit.get(name) != null ? kayit.get(name).toString() : null,
      onSaved: (value) {
        if(value.isNotEmpty) {
          if(fractionLength == -1) {
            kayit.set(name, double.parse(value));
          } else {
            double d = double.parse(value);
            String newStr = d.toStringAsFixed(fractionLength);
            kayit.set(name, double.parse(newStr));
          }
        } else {
          kayit.set(name, null);
        }
      },
      validator: (value) {
        if(value.isEmpty) {
          if(isNullable(kayit)) {
            return null;
          } else {
            return fieldLabel + ' Boş Bırakılamaz';
          }
        } else {
          if(double.tryParse(value) == null) {
            return 'Ondalıklı sayı giriniz!';
          } else {
            String newStr = signed ? value.replaceAll("-", "") : value;
            String intPart = newStr.contains(".") ? newStr.split(".")[0] : newStr;
            if(length != -1  && intPart.length != length) {
              return 'Noktadan önce ' + length.toString() + ' uzunluğunda ondalıklı sayı giriniz!';
            } else if(minLength != -1  && intPart.length < minLength) {
              return 'Noktadan önce En az ' + minLength.toString() + ' uzunluğunda ondalıklı sayı giriniz!';
            } else if(maxLength != -1  && intPart.length > maxLength) {
              return 'Noktadan önce En fazla ' + minLength.toString() + ' uzunluğunda ondalıklı sayı giriniz!';
            } else {
              return null;
            }
          }
        }
      },
    );
  }

  @override
  List<Widget> constructFilterFields(BuildContext context, Map<String, dynamic> filterMap) {
    List<Widget> retList = List<Widget>();
    for(int i = 0, len = filterModes.length; i < len; ++i) {
      retList.add(TextFormField(
        keyboardType: TextInputType.numberWithOptions(signed: signed, decimal: false),
        initialValue: filterMap[name + "-" + filterModes[i]],
        decoration: InputDecoration(labelText: fieldLabel + " " + filterModeTitles[i] + " "),
        onChanged: (value) {
          if(value == "") {
            ConstantsBase.eventBus.fire(FilterValueChangedEvent(name, filterModes[i], null));
          } else {
            ConstantsBase.eventBus.fire(FilterValueChangedEvent(name, filterModes[i], double.parse(value)));
          }
        },
      ));
    }
    return retList;
  }

  @override
  List<Widget> constructFilterButtons(BuildContext context, Map<String, dynamic> filterMap) {
    List<Widget> retList = List<Widget>();
    for(int i = 0, len = filterModes.length; i < len; ++i) {
      retList.add(SizedBox(
        width: ConstantsBase.filterDetailButtonWidth,
        child: MenuButton(
          edgeInsetsGeometry: ConstantsBase.filterButtonEdges,
          title: filterModeTitles[i],
          fontSize: ConstantsBase.filterButtonFontSize,
          buttonColor: filterMap[name + "-" + filterModes[i]] != null ? Colors.greenAccent : ConstantsBase.defaultDisabledColor,
          onPressed: (){},
        ),
      ));
      retList.add(SizedBox(width:2));
    }
    return retList;
  }

  @override
  void clearFilterControllers() {
    //Nothing to clear
  }
}