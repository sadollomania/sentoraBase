import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/BooleanFieldType.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/field/BaseField.dart';

class BooleanField extends BaseField {
  BooleanField({
    @required BuildContext context,
    @required BooleanFieldType fieldType,
    @required BaseModel kayit,
    @required bool lastField,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
    context: context,
    kayit: kayit,
    fieldType: fieldType,
    textValue : null,
    realValue : kayit.get(fieldType.name),
    lastField : lastField,
    suffixCheckboxExists : true,
    onSaved : (textValue, realValue) {
      kayit.set(fieldType.name, realValue);
    },
    scaffoldKey : scaffoldKey,
    onTapReplacementFunc : (String textValue, dynamic realValue, String sentoraFieldBaseStateUid, GlobalKey<ScaffoldState> scaffoldKey) {
      return showModalBottomSheet<bool>(
          context: context,
          builder: (BuildContext builder) {
            return Container(
                height: fieldType.isNullable(kayit) ? 240 : 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          CupertinoButton(
                            pressedOpacity: 0.3,
                            padding: EdgeInsets.only(left: 16, top: 0),
                            child: Text(
                              fieldType.fieldLabel,
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                            onPressed: (){},
                          ),
                          IconButton(
                              icon: Icon(Icons.navigate_next),
                              onPressed: () {
                                NavigatorBase.pop(true);
                              }
                          )
                        ],
                      ),
                    ),
                    fieldType.isNullable(kayit) ?
                    Container(
                      height: 60,
                      child: ListTile(
                        leading: Icon(Icons.indeterminate_check_box),
                        selected: realValue == null,
                        title: Center(child: Text(BooleanFieldType.NULL_CHECKED)),
                        onTap: (){
                          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, null, null));
                          NavigatorBase.pop(true);
                        },
                      ),
                    ) :
                    Container(
                      height: 0,
                    ),
                    Container(
                      height: 60,
                      child: ListTile(
                        leading: Icon(Icons.check_box),
                        selected: realValue == true,
                        title: Center(child: Text(BooleanFieldType.CHECKED)),
                        onTap: (){
                          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, null, true));
                          NavigatorBase.pop(true);
                        },
                      ),
                    ),
                    Container(
                      height: 60,
                      child: ListTile(
                        leading: Icon(Icons.check_box_outline_blank),
                        selected: realValue == false,
                        title: Center(child: Text(BooleanFieldType.NOT_CHECKED)),
                        onTap: (){
                          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, null, false));
                          NavigatorBase.pop(true);
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