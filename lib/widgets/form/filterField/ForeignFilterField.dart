import 'package:flutter/material.dart';
import 'package:sentora_base/model/AppBarActionHolder.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/events/FilterValueChangedEvent.dart';
import 'package:sentora_base/events/FormFieldValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/ForeignKeyFieldType.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/pages/BaseModelPage.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/form/filterField/BaseFilterField.dart';

class ForeignFilterField extends BaseFilterField {
  ForeignFilterField({
    @required BuildContext context,
    @required ForeignKeyFieldType fieldType,
    @required int filterIndex,
    @required Map<String, dynamic> filterMap,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
    fieldType: fieldType,
    filterIndex: filterIndex,
    textValue : filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] != null ? (filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] as BaseModel).getCombinedTitleValue() : "",
    realValue : filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]],
    suffixClearButtonFunc: () {
      filterMap.remove(fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]);
      ConstantsBase.eventBus.fire(FilterValueChangedEvent());
    },
    scaffoldKey : scaffoldKey,
    onTapReplacementFunc: (String textValue, dynamic realValue, String sentoraFieldBaseStateUid, GlobalKey<ScaffoldState> scaffoldKey){
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
                    caption: ConstantsBase.translate("sec"),
                      color: ConstantsBase.defaultButtonColor,
                      icon: Icons.done,
                      onTap: (stateData) async{
                        ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, stateData.tag["selectedKayit"].getCombinedTitleValue(), stateData.tag["selectedKayit"]));
                        filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] = stateData.tag["selectedKayit"];
                        await NavigatorBase.pop(true);
                        ConstantsBase.eventBus.fire(FilterValueChangedEvent());
                        return;
                      },
                    )]
                )
            );
          }
      );
    }
  );
}