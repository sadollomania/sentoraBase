import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/StringField.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';

class BaseModelDuzenleme extends StatefulWidget {
  BaseModel kayit;
  String modelName;
  BaseModel ornekKayit;
  BaseModelDuzenleme({
    @required this.kayit,
    @required this.modelName,
  }) {
    this.ornekKayit = BaseModel.createNewObject(this.modelName);
  }
  @override
  _BaseModelDuzenlemeState createState() => new _BaseModelDuzenlemeState();
}

class _BaseModelDuzenlemeState extends State<BaseModelDuzenleme> {
  final _formKey = GlobalKey<FormState>();

  List<Widget> getFormItems() {
    List<Widget> retWidgets = List<Widget>();
    widget.ornekKayit.fieldTypes.forEach((fieldType){
      if(fieldType.runtimeType == StringField) {
        retWidgets.add(Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(labelText: fieldType.fieldLabel, hintText: fieldType.fieldHint),
                initialValue: widget.kayit != null ? widget.kayit.get(fieldType.name) : '',
                validator: (value) {
                  if (!fieldType.nullable && value.isEmpty) {
                    return fieldType.fieldLabel + ' Giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    if(widget.kayit == null) {
                      widget.kayit = BaseModel.createNewObject(widget.modelName);
                    }
                    widget.kayit.set(fieldType.name, value);
                  });
                },
              ),
            )
        ));
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
            if(widget.kayit.get("ID") == null) {
              widget.kayit.set("ID", ConstantsBase.getRandomUUID());
              BaseModel.insert(widget.kayit).then((_){
                ConstantsBase.showToast(context, widget.kayit.singleTitle + " Eklendi");
                Navigator.pop(context);
              });
            } else {
              BaseModel.update(widget.kayit).then((_){
                ConstantsBase.showToast(context, widget.kayit.singleTitle + " Güncellendi");
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
        title: Text(widget.ornekKayit.singleTitle + " Düzenleme"),
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