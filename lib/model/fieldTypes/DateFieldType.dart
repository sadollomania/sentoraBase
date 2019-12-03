import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/FilterValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';

class DateFieldType extends BaseFieldType {
  static final double datePickerHeight = 210;
  static final DateTime defaultMinTime = DateTime(2000, 1, 1);
  static final DateTime defaultMaxTime = DateTime(2199, 12, 31);
  static Map<String, TextEditingController> textEditingControllers = Map<String, TextEditingController>();
  static Map<String, TextEditingController> textEditingFilterControllers = Map<String, TextEditingController>();
  static final List<String> filterModes = List<String>.from(["dateeq","dategt","datelt"]);
  static final List<String> filterModeTitles = List<String>.from(["=",">","<"]);

  static void clearEditors() {
    textEditingControllers.values.forEach((tec){
      tec.dispose();
    });
    textEditingControllers.clear();
  }

  DateFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    bool nullable,
    DateTime defaultValue,
    bool unique = false,
    bool Function(BaseModel baseModel) nullableFn,
    bool sortable = true,
    bool filterable = true,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn, sortable : sortable, filterable : filterable);

  TextEditingController _getTec(bool formOrFilter, String initialValue, String mode) {
    TextEditingController tec;
    if(formOrFilter) {
      if(textEditingControllers.containsKey(name)) {
        tec = textEditingControllers[name];
      } else {
        tec = TextEditingController(text: initialValue);
        textEditingControllers[name] = tec;
      }
    } else {
      if(textEditingFilterControllers.containsKey(name + "-" + mode)) {
        tec = textEditingFilterControllers[name + "-" + mode];
      } else {
        tec = TextEditingController(text: initialValue);
        textEditingFilterControllers[name + "-" + mode] = tec;
      }
    }
    return tec;
  }

  TextFormField _getTff(bool formOrFilter, TextEditingController tec, BaseModel kayit, String fieldLabel, String filterMode) {
    Function validatorFn = (value) {
      if(value.isEmpty) {
        if(isNullable(kayit)) {
          return null;
        } else {
          return fieldLabel + ' Boş Bırakılamaz';
        }
      }
      return null;
    };

    if(formOrFilter) {
      return TextFormField(
        controller: tec,
        readOnly: true,
        decoration: InputDecoration(labelText: fieldLabel),
        onTap: () {},
        onSaved: (value) {
          if(value.isNotEmpty) {
            kayit.set(name, ConstantsBase.dateFormat.parse(value));
          } else {
            kayit.set(name, null);
          }
        },
        validator: validatorFn,
      );
    } else {
      return TextFormField(
        controller: tec,
        readOnly: true,
        decoration: InputDecoration(labelText: fieldLabel),
        onTap: () {},
      );
    }
  }

  Widget _getWidget(bool formOrFilter, String label, String initialValue, BaseModel kayit, BuildContext context, String filterMode) {
    TextEditingController tec = _getTec(formOrFilter, initialValue, filterMode);
    TextFormField tff = _getTff(formOrFilter, tec, kayit, label, filterMode);
    return Container(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: tff,
          ),
          SizedBox(width: 10,),
          SizedBox(
              width: 40,
              child: MenuButton(
                edgeInsetsGeometry:EdgeInsets.all(0.0),
                iconData: Icons.date_range,
                buttonColor: Colors.white,
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      theme: DatePickerTheme(
                        containerHeight: datePickerHeight,
                      ),
                      showTitleActions: true,
                      minTime: defaultMinTime,
                      maxTime: defaultMaxTime,
                      onConfirm: (date) {
                        tec.text = ConstantsBase.dateFormat.format(date);
                        if(formOrFilter == false) {
                          ConstantsBase.eventBus.fire(FilterValueChangedEvent(name, filterMode, tec.text));
                        }
                      },
                      currentTime: tec.text != null && tec.text.isNotEmpty ? ConstantsBase.dateFormat.parse(tec.text) : DateTime.now(),
                      locale: LocaleType.tr
                  );
                },
              )
          ),
          SizedBox(width: 10,),
          SizedBox(
            width: 40,
            child: MenuButton(
              edgeInsetsGeometry:EdgeInsets.all(0.0),
              iconData: Icons.cancel,
              buttonColor: Colors.white,
              onPressed: () {
                tec.text = "";
                if(formOrFilter == false) {
                  ConstantsBase.eventBus.fire(FilterValueChangedEvent(name, filterMode, null));
                }
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget constructFormField(BaseModel kayit, BuildContext context) {
    String initialValue = kayit.get(name) != null ? ConstantsBase.dateFormat.format(kayit.get(name)) : null;
    return _getWidget(true, fieldLabel, initialValue, kayit, context, null);
  }

  @override
  List<Widget> constructFilterFields(BuildContext context, Map<String, dynamic> filterMap) {
    List<Widget> retList = List<Widget>();
    String mode;
    for(int i = 0, len = filterModes.length; i < len; ++i) {
      mode = filterModes[i];
      retList.add(_getWidget(false, fieldLabel + " " + filterModeTitles[i] + " ", filterMap[name + "-" + mode], null, context, mode));
    }

    filterModes.forEach((mode){

    });
    return retList;
  }

  @override
  List<Widget> constructFilterButtons(BuildContext context, Map<String, dynamic> filterMap) {
    List<Widget> retList = List<Widget>();
    String mode;
    for(int i = 0, len = filterModes.length; i < len; ++i) {
      mode = filterModes[i];
      retList.add(SizedBox(
        width: ConstantsBase.filterDetailButtonWidth,
        child: MenuButton(
          edgeInsetsGeometry: ConstantsBase.filterButtonEdges,
          title: filterModeTitles[i],
          fontSize: ConstantsBase.filterButtonFontSize,
          buttonColor: filterMap[name + "-" + mode] != null ? Colors.greenAccent : ConstantsBase.defaultDisabledColor,
          onPressed: (){},
        ),
      ));
      retList.add(SizedBox(width:2));
    }
    return retList;
  }

  @override
  void clearFilterControllers() {
    textEditingFilterControllers.forEach((str, tec){
      tec.dispose();
    });
    textEditingFilterControllers.clear();
  }
}