import 'package:flutter/material.dart';
import 'package:sentora_base/model/AppBarActionHolder.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/FilterValueChangedEvent.dart';
import 'package:sentora_base/model/FormFieldValueChangedEvent.dart';
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
                  widgetModelName: fieldType.foreignKeyModelName,
                  pageTitle: fieldType.fieldLabel + " Seçme",
                  pageSize: 6,
                  appBarActions: <AppBarActionHolder>[
                    AppBarActionHolder(
                    caption: 'Seç',
                      color: ConstantsBase.defaultButtonColor,
                      icon: Icons.done,
                      onTap: (context, selectedKayit, baseModelPageId, scaffoldKey) {
                        ConstantsBase.eventBus.fire(FormFieldValueChangedEvent(sentoraFieldBaseStateUid, selectedKayit.getCombinedTitleValue(), selectedKayit));
                        filterMap[fieldType.name + "-" + fieldType.getFilterModes()[filterIndex]] = selectedKayit;
                        NavigatorBase.pop(true);
                        ConstantsBase.eventBus.fire(FilterValueChangedEvent());
                      },
                    )]
                )
            );
          }
      );
    }
  );
}