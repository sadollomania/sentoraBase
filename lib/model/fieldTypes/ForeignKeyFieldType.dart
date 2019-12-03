import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/FilterValueChangedEvent.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';

class ForeignKeyFieldType extends BaseFieldType {
  final String foreignKeyModelName;
  BaseModel foreignKeyModel;
  VoidCallback onChange;
  static Map<String, TextEditingController> textEditingControllers = Map<String, TextEditingController>();
  static Map<String, BaseModel> selectedModels = Map<String, BaseModel>();

  static void clearEditors() {
    textEditingControllers.values.forEach((tec){
      tec.dispose();
    });
    textEditingControllers.clear();
    selectedModels.clear();
  }

  ForeignKeyFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required this.foreignKeyModelName,
    bool nullable,
    BaseModel defaultValue,
    bool unique = false,
    bool Function(BaseModel baseModel) nullableFn,
    bool sortable = false,
    bool filterable = false,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn, sortable : sortable, filterable : filterable) {
    foreignKeyModel = BaseModel.createNewObject(foreignKeyModelName);
  }

  @override
  Widget constructFormField(BaseModel kayit, BuildContext context) {
    TextEditingController tec;
    if(textEditingControllers.containsKey(name)) {
      tec = textEditingControllers[name];
    } else {
      tec = TextEditingController(text: kayit.get(name) != null ? (kayit.get(name) as BaseModel).getListTileTitleValue() : null);
      textEditingControllers[name] = tec;
      selectedModels[name] = kayit.get(name);
    }
    var tff = TextFormField(
      controller: tec,
      readOnly: true,
      decoration: InputDecoration(labelText: fieldLabel),
      onTap: () {},
      onSaved: (value) {
        if(value.isNotEmpty) {
          kayit.set(name, selectedModels[name]);
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
        }
        return null;
      },
    );
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
                iconData: Icons.format_list_bulleted,
                buttonColor: Colors.white,
                onPressed: () {
                  BaseModel.getList(foreignKeyModel).then((map){
                    List<BaseModel> dataList = ConstantsBase.getDataFormGetList(map);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text(fieldLabel + " Seçimi"),
                            content: DropdownButton<String>(
                              items: dataList.map((dropdownKayit) => DropdownMenuItem<String>(
                                child: Container(
                                  child: Text(dropdownKayit.getListTileTitleValue()),
                                ),
                                value: dropdownKayit.get("ID") as String,
                              )).toList(),
                              onChanged: (String dropdownKayitId) {
                                BaseModel.getById(foreignKeyModel.modelName, foreignKeyModel.tableName, dropdownKayitId).then((newObj){
                                  selectedModels[name] = newObj;
                                  tec.text = newObj.getListTileTitleValue();
                                  NavigatorBase.pop();
                                });
                              },
                              isExpanded: true,
                              value: selectedModels[name] != null ? selectedModels[name].get("ID") : null,
                              hint: Text(fieldHint),
                          )
                        );
                      }
                    );
                  });
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
                selectedModels[name] = null;
                tec.text = "";
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  List<Widget> constructFilterFields(BuildContext context, Map<String, dynamic> filterMap) {
    List<Widget> retList = List<Widget>(); //TODO buraya bakilacak degistirilecek.
    retList.add(TextFormField(
      decoration: InputDecoration(labelText: fieldLabel + " ~ "),
      onChanged: (value) {
        ConstantsBase.eventBus.fire(FilterValueChangedEvent(name, "eq", value));
      },
    ));
    return retList;
  }

  @override
  List<Widget> constructFilterButtons(BuildContext context, Map<String, dynamic> filterMap) {
    List<Widget> retList = List<Widget>();
    retList.add(Checkbox(
      value: null,
      tristate: true,
      onChanged: (value) {
        ConstantsBase.eventBus.fire(FilterValueChangedEvent(name, "eq", value));
      },
    ));
    return retList;
  }

  @override
  void clearFilterControllers() {
    //Nothing to clear
  }
}