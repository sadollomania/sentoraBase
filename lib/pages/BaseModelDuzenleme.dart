import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/MenuButton.dart';
import 'package:sqflite/sqflite.dart';

class BaseModelDuzenleme extends StatefulWidget {
  final BaseModel widgetKayit;
  final String widgetModelName;
  BaseModelDuzenleme({
    @required this.widgetKayit,
    @required this.widgetModelName,
  });

  @override
  BaseModelDuzenlemeState createState() => new BaseModelDuzenlemeState(kayit:this.widgetKayit, modelName: this.widgetModelName);
}

class BaseModelDuzenlemeState extends State<BaseModelDuzenleme> {
  final _formKey = GlobalKey<FormState>();
  BaseModel ornekKayit;
  BaseModel kayit;
  String modelName;
  BaseModelDuzenlemeState({
    @required this.kayit,
    @required this.modelName
  }) {
    ornekKayit = BaseModel.createNewObject(modelName);
    if(kayit == null) {
      kayit = BaseModel.createNewObject(modelName);
    }
  }

  List<Widget> getFormItems() {
    List<Widget> retWidgets = List<Widget>();
    ornekKayit.fieldTypes.forEach((fieldType){
      retWidgets.add(fieldType.constructFormField(kayit));
      retWidgets.add(SizedBox(height: 20,));
    });
    retWidgets.add(
      MenuButton(
        title: 'Kaydet',
        onPressed: () {
          _formKey.currentState.save();
          if (_formKey.currentState.validate()) {
            ConstantsBase.showToast(context, "Bilgiler Kaydediliyor");
            if(kayit.get("ID") == null) {
              kayit.set("ID", ConstantsBase.getRandomUUID());
              BaseModel.insert(kayit).then((_){
                ConstantsBase.showToast(context, kayit.singleTitle + " Eklendi");
                Navigator.pop(context);
              }).catchError((e){
                debugPrint(e.toString());
                kayit.set("ID", null);
                if(e is DatabaseException) {
                  ConstantsBase.showToast(context, BaseModel.convertDbErrorToStr(kayit, e));
                } else {
                  ConstantsBase.showToast(context, e.toString());
                }
              });
            } else {
              BaseModel.update(kayit).then((_){
                ConstantsBase.showToast(context, kayit.singleTitle + " Güncellendi");
                Navigator.pop(context);
              }).catchError((e){
                debugPrint(e.toString());
                if(e is DatabaseException) {
                  ConstantsBase.showToast(context, BaseModel.convertDbErrorToStr(kayit, e));
                } else {
                  ConstantsBase.showToast(context, e.toString());
                }
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
        title: Text(ornekKayit.singleTitle + (kayit == null || kayit.get("ID") == null ? " Ekleme" : " Düzenleme")),
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