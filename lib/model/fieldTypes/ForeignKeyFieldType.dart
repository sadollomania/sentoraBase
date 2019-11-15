import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';

class ForeignKeyFieldType extends BaseFieldType {
  final String foreignKeyModelName;
  BaseModel foreignKeyModel;

  ForeignKeyFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required bool nullable,
    @required this.foreignKeyModelName,
    BaseModel defaultValue,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, defaultValue: defaultValue) {
    foreignKeyModel = BaseModel.createNewObject(foreignKeyModelName);
  }

  @override
  Widget constructFormField(BaseModel kayit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(fieldLabel),
        Expanded(
          child: FutureBuilder<List<BaseModel>>(
            future: BaseModel.getList(foreignKeyModel),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              return DropdownButton<String>(
                items: snapshot.data.map((dropdownKayit) => DropdownMenuItem<String>(
                  child: Container(
                    child: Text(dropdownKayit.getListTileTitleValue()),
                  ),
                  value: dropdownKayit.get("ID") as String,
                )).toList(),
                onChanged: (String dropdownKayitId) {
                  BaseModel.getById(foreignKeyModel.modelName, foreignKeyModel.tableName, dropdownKayitId).then((newObj){
                    kayit.set(name, newObj);
                  });
                },
                isExpanded: true,
                value: kayit.get(name) != null ? kayit.get(name).get("ID") : null,
                hint: Text(fieldHint),
              );
            },
          ),
        )
      ],
    );
  }
}