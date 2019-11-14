import 'package:flutter/material.dart';
import 'package:sentora_base/data/DBHelperBase.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BlobField.dart';
import 'package:sentora_base/model/fieldTypes/BooleanField.dart';
import 'package:sentora_base/model/fieldTypes/DateField.dart';
import 'package:sentora_base/model/fieldTypes/ForeignKeyField.dart';
import 'package:sentora_base/model/fieldTypes/IntField.dart';
import 'package:sentora_base/model/fieldTypes/RealField.dart';
import 'package:sentora_base/model/fieldTypes/StringField.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';

class BaseModelDuzenleme extends StatefulWidget {
  final BaseModel widgetKayit;
  final String widgetModelName;
  BaseModelDuzenleme({
    @required this.widgetKayit,
    @required this.widgetModelName,
  });

  @override
  _BaseModelDuzenlemeState createState() => new _BaseModelDuzenlemeState(kayit:this.widgetKayit, modelName: this.widgetModelName);
}

class _BaseModelDuzenlemeState extends State<BaseModelDuzenleme> {
  final _formKey = GlobalKey<FormState>();
  BaseModel ornekKayit;
  BaseModel kayit;
  String modelName;
  _BaseModelDuzenlemeState({
    @required this.kayit,
    @required this.modelName
  }) {
    this.ornekKayit = BaseModel.createNewObject(this.modelName);
  }

  bool _checkDateValidity(value) {
    if (value.isEmpty || value.length != 10 || value[4] != '-' || value[7] != '-') {
      return false;
    } else {
      try {
        DateTime dt = ConstantsBase.dateFormat.parse(value + " 00:00:00");
        if(ConstantsBase.dateFormat.format(dt) != value + " 00:00:00") {
          return false;
        }
      } on FormatException {
        return false;
      }
    }
    return true;
  }

  List<Widget> getFormItems() {
    List<Widget> retWidgets = List<Widget>();
    ornekKayit.fieldTypes.forEach((fieldType){
      if(fieldType.runtimeType == BlobField) {
        throw new Exception("BlobField için şu anda düzenleme formuna component konulmadı.");
      } else if(fieldType.runtimeType == BooleanField) {
        retWidgets.add(Expanded(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child:Text(fieldType.fieldLabel)),
                    Checkbox(
                      value: kayit != null ? kayit.get(fieldType.name) : ( fieldType.defaultValue != null ? fieldType.defaultValue : false ),
                      tristate: fieldType.defaultValue == null,
                      onChanged: (value) async{
                        setState(() {
                          if(kayit == null) {
                            kayit = BaseModel.createNewObject(modelName);
                          }
                          kayit.set(fieldType.name, value);
                        });
                      },
                    )
                  ],
                )
              ),
          )
        ));
      } else if(fieldType.runtimeType == DateField) {
        retWidgets.add(Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(labelText: fieldType.fieldLabel),
                initialValue: kayit != null ? ConstantsBase.dateFormat.format(kayit.get(fieldType.name)) : null,
                validator: (value) {
                  if (!fieldType.nullable && !_checkDateValidity(value)) {
                    return 'yyyy-MM-dd şeklinde tarih giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  if(kayit == null) {
                    kayit = BaseModel.createNewObject(modelName);
                  }
                  if(value == null) {
                    kayit.set(fieldType.name, null);
                  } else {
                    kayit.set(fieldType.name, ConstantsBase.dateFormat.parse(value));
                  }
                },
              ),
            )
        ));
      } else if(fieldType.runtimeType == ForeignKeyField) {
        ForeignKeyField foreignKeyField = fieldType as ForeignKeyField;
        retWidgets.add(
          Expanded(
            child: FutureBuilder<List<BaseModel>>(
              future: BaseModel.getList(foreignKeyField.foreignKeyModel),
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
                    BaseModel.getById(foreignKeyField.foreignKeyModel.modelName, foreignKeyField.foreignKeyModel.tableName, dropdownKayitId).then((newObj){
                      setState(() {
                        if(kayit == null) {
                          kayit = BaseModel.createNewObject(modelName);
                        }
                        kayit.set(foreignKeyField.name, newObj);
                      });
                    });
                  },
                  isExpanded: true,
                  value: kayit != null && kayit.get(foreignKeyField.name) != null ? kayit.get(foreignKeyField.name).get("ID") : null,
                  hint: Text(foreignKeyField.fieldHint),
                );
              },
            ),
          ),
        );
      } else if(fieldType.runtimeType == IntField) {
        retWidgets.add(Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: fieldType.fieldLabel),
                initialValue: kayit != null ? (kayit.get(fieldType.name) != null ? kayit.get(fieldType.name).toString() : null) : null,
                validator: (value) {
                  if (!fieldType.nullable && value.isEmpty || int.tryParse(value) == null) {
                    return 'Bir tam sayı giriniz!';
                  }
                  return null;
                },
                onSaved: (value) {
                  if(kayit == null) {
                    kayit = BaseModel.createNewObject(modelName);
                  }
                  kayit.set(fieldType.name, int.parse(value));
                },
              ),
            )
        ));
      } else if(fieldType.runtimeType == RealField) {
        retWidgets.add(Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: fieldType.fieldLabel),
                initialValue: kayit != null ? (kayit.get(fieldType.name) != null ? kayit.get(fieldType.name).toString() : null) : null,
                validator: (value) {
                  if (!fieldType.nullable && value.isEmpty || double.tryParse(value) == null) {
                    return 'Ondalıklı sayı giriniz!';
                  }
                  return null;
                },
                onSaved: (value) {
                  if(kayit == null) {
                    kayit = BaseModel.createNewObject(modelName);
                  }
                  kayit.set(fieldType.name, double.parse(value));
                },
              ),
            )
        ));
      } else if(fieldType.runtimeType == StringField) {
        retWidgets.add(Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(labelText: fieldType.fieldLabel, hintText: fieldType.fieldHint),
                initialValue: kayit != null ? kayit.get(fieldType.name) : '',
                validator: (value) {
                  if (!fieldType.nullable && value.isEmpty) {
                    return fieldType.fieldLabel + ' Giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    if(kayit == null) {
                      kayit = BaseModel.createNewObject(modelName);
                    }
                    kayit.set(fieldType.name, value);
                  });
                },
              ),
            )
        ));
      } else {
        throw new Exception("Unknown FieldType : " + fieldType.runtimeType.toString());
      }
      retWidgets.add(SizedBox(height: 20,));
    });
    retWidgets.add(
      MenuButton(
        title: 'Kaydet',
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            ConstantsBase.showToast(context, "Bilgiler Kaydediliyor");
            if(kayit.get("ID") == null) {
              kayit.set("ID", ConstantsBase.getRandomUUID());
              BaseModel.insert(kayit).then((_){
                ConstantsBase.showToast(context, kayit.singleTitle + " Eklendi");
                Navigator.pop(context);
              });
            } else {
              BaseModel.update(kayit).then((_){
                ConstantsBase.showToast(context, kayit.singleTitle + " Güncellendi");
                Navigator.pop(context);
              });
            }
          }
        },
      ),
    );
    return retWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ornekKayit.singleTitle + " Düzenleme"),
      ),
      body: Padding(
          padding:EdgeInsets.all(8.0)
          ,child:Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: getFormItems(),
            )
          )
      )
    );
  }
}