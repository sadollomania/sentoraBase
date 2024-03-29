import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentora_base/events/FilterValueChangedEvent.dart';
import 'package:sentora_base/events/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/BooleanFieldType.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/filterField/BaseFilterField.dart';

class BooleanFilterField extends BaseFilterField {
  BooleanFilterField({
    required BuildContext context,
    required BooleanFieldType fieldType,
    required int filterIndex,
    required Map<String, dynamic> filterMap,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
    fieldType: fieldType,
    filterIndex: filterIndex,
    textValue : "",
    realValue : filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]],
    scaffoldKey : scaffoldKey,
    suffixCheckboxExists : true,
    onTapReplacementFunc : (String textValue, dynamic realValue, String sentoraFieldBaseStateUid, GlobalKey<ScaffoldState> scaffoldKey) {
      return showModalBottomSheet(
          context: context,
          builder: (BuildContext builder) {
            return Container(
                height: 240,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      height: 50,
                      child: CupertinoButton(
                        pressedOpacity: 0.3,
                        padding: EdgeInsets.only(left: 16, top: 0),
                        child: Text(
                          fieldType.fieldLabel,
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                        onPressed: (){},
                      ),
                    ),
                    Container(
                      height: 60,
                      child: ListTile(
                        leading: Icon(Icons.indeterminate_check_box),
                        selected: realValue == null,
                        title: Center(child: Text("-")),
                        onTap: () async{
                          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, null, null));
                          filterMap.remove(fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]);
                          await NavigatorBase.pop(true);
                          ConstantsBase.eventBus.fire(FilterValueChangedEvent());
                          return;
                        },
                      ),
                    ),
                    Container(
                      height: 60,
                      child: ListTile(
                        leading: Icon(Icons.check_box),
                        selected: realValue == true,
                        title: Center(child: Text(ConstantsBase.translate("evet"))),
                        onTap: () async{
                          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, null, true));
                          filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] = true;
                          await NavigatorBase.pop(true);
                          ConstantsBase.eventBus.fire(FilterValueChangedEvent());
                          return;
                        },
                      ),
                    ),
                    Container(
                      height: 60,
                      child: ListTile(
                        leading: Icon(Icons.check_box_outline_blank),
                        selected: realValue == false,
                        title: Center(child: Text(ConstantsBase.translate("hayir"))),
                        onTap: () async{
                          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, null, false));
                          filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] = false;
                          await NavigatorBase.pop(true);
                          ConstantsBase.eventBus.fire(FilterValueChangedEvent());
                          return;
                        },
                      ),
                    )
                  ],
                )
            );
          }
      );
    }
  );
}