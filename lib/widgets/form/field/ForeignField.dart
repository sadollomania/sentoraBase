import 'package:flutter/material.dart';
import 'package:sentora_base/model/AppBarActionHolder.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/events/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/ForeignKeyFieldType.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/pages/BaseModelPage.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/field/BaseField.dart';

class ForeignField extends BaseField {
  ForeignField({
    @required BuildContext context,
    @required ForeignKeyFieldType fieldType,
    @required BaseModel kayit,
    @required bool lastField,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
    context: context,
    kayit: kayit,
    fieldType: fieldType,
    textValue : kayit.get(fieldType.name) != null ? (kayit.get(fieldType.name) as BaseModel).getCombinedTitleValue() : null,
    realValue : kayit.get(fieldType.name),
    lastField : lastField,
    onSaved : (textValue, realValue) {
      kayit.set(fieldType.name, realValue);
    },
    suffixClearButtonFunc: () {
      kayit.set(fieldType.name, null);
    },
    scaffoldKey : scaffoldKey,
    onTapReplacementFunc: (String textValue, dynamic currentValue, String sentoraFieldBaseStateUid, GlobalKey<ScaffoldState> scaffoldKey){
      return showModalBottomSheet<bool>(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext builder) {
            return Container(
                height: ConstantsBase.getMaxHeight(context) * 0.8,
                child: BaseModelPage(
                  modelName: fieldType.foreignKeyModelName,
                  pageTitle: (_) => fieldType.fieldLabel + " " + ConstantsBase.translate("secme"),
                  pageSize: 6,
                  topActions: (_) => <AppBarActionHolder>[
                    AppBarActionHolder(
                      caption: ConstantsBase.translate("sonraki"),
                      color: ConstantsBase.defaultButtonColor,
                      icon: Icons.navigate_next,
                      onTap: (stateData) async{
                        await NavigatorBase.pop(true);
                        return;
                      },
                    ),
                    AppBarActionHolder(
                      caption: ConstantsBase.translate("sec"),
                      color: ConstantsBase.defaultButtonColor,
                      icon: Icons.done,
                      onTap: (stateData) async{
                        if(stateData.tag["selectedKayit"] != null) {
                          ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, stateData.tag["selectedKayit"].getCombinedTitleValue(), stateData.tag["selectedKayit"]));
                          await NavigatorBase.pop(true);
                        } else {
                          ConstantsBase.showSnackBarShort(scaffoldKey, ConstantsBase.translate("kayit_seciniz"));
                        }
                        return;
                      }
                    )
                  ],
                )
            );
          }
      );
    }
  );
}