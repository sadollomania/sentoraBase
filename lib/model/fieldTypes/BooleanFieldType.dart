import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/FilterValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';
import 'package:sentora_base/widgets/form/BooleanFormField.dart';

class BooleanFieldType extends BaseFieldType {
  BooleanFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    bool nullable,
    bool defaultValue,
    bool unique = false,
    bool Function(BaseModel baseModel) nullableFn,
    bool sortable = true,
    bool filterable = true,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn, sortable : sortable, filterable : filterable);

  @override
  Widget constructFormField(BaseModel kayit, BuildContext context) {
    return BooleanFormField(
      booleanFieldType: this,
      initialValue: kayit.get(name),
      onSaved: (bool value) {
        kayit.set(name, value);
      },
      validator: (bool value) {
        if (!isNullable(kayit) && value == null) {
          return fieldLabel + ' Giriniz';
        }
        return null;
      },
    );
  }

  @override
  List<Widget> constructFilterFields(BuildContext context, Map<String, dynamic> filterMap) {
    List<Widget> retList = List<Widget>();
    retList.add(Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(fieldLabel),
            Checkbox(
              value: filterMap[name + "-booleq"],
              tristate: true,
              onChanged: (value) {
                if(value == null) {
                  ConstantsBase.eventBus.fire(FilterValueChangedEvent(name, "booleq", null));
                } else {
                  ConstantsBase.eventBus.fire(FilterValueChangedEvent(name, "booleq", value));
                }
              },
            )
          ],
        )
    ));
    return retList;
  }

  @override
  List<Widget> constructFilterButtons(BuildContext context, Map<String, dynamic> filterMap) {
    List<Widget> retList = List<Widget>();
    retList.add(SizedBox(
      width: ConstantsBase.filterDetailButtonWidth,
      child: MenuButton(
        edgeInsetsGeometry: ConstantsBase.filterButtonEdges,
        title: "=",
        fontSize: ConstantsBase.filterButtonFontSize,
        buttonColor: filterMap[name + "-booleq"] != null ? Colors.greenAccent : ConstantsBase.defaultDisabledColor,
        onPressed: (){},
      ),
    ));
    return retList;
  }

  @override
  void clearFilterControllers() {
    //Nothing to clear
  }
}