import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/events/ModelDuzenlemeEvent.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/SntIconButton.dart';
import 'package:sqflite/sqflite.dart';

class BaseModelDuzenleme extends StatefulWidget {
  final BaseModel widgetKayit;
  final String widgetModelName;
  final String baseModelPageId;
  final GlobalKey<ScaffoldState> baseModelPageScaffoldKey;
  BaseModelDuzenleme({
    @required this.widgetKayit,
    @required this.widgetModelName,
    @required this.baseModelPageId,
    @required this.baseModelPageScaffoldKey,
  });

  @override
  BaseModelDuzenlemeState createState() => new BaseModelDuzenlemeState(widgetKayit:this.widgetKayit, modelName: this.widgetModelName, baseModelPageId : baseModelPageId);
}

class BaseModelDuzenlemeState extends State<BaseModelDuzenleme> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  BaseModel kayit;
  String modelName;
  String baseModelPageId;
  Map<String, TextEditingController> textControllers = Map<String, TextEditingController>();
  Map<String, dynamic> formVals = Map<String, dynamic>();

  BaseModelDuzenlemeState({
    BaseModel widgetKayit,
    @required this.modelName,
    @required this.baseModelPageId,
  }) {
    if(widgetKayit == null) {
      kayit = BaseModel.createNewObject(modelName);
    } else {
      kayit = widgetKayit.clone();
    }
  }

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  List<Widget> getFormItems() {
    List<Widget> retWidgets = List<Widget>();
    for(int i = 0, len = kayit.fieldTypes.length; i < len; ++i) {
      BaseFieldType fieldType = kayit.fieldTypes[i];
      retWidgets.add(fieldType.constructFormField(context, kayit, i == len - 1, _scaffoldKey));
      retWidgets.add(SizedBox(height: 20,));
    }
    return retWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(kayit.singleTitle + (kayit.get("ID") == null ? " " + ConstantsBase.translate("ekleme") : " " + ConstantsBase.translate("duzenleme") )),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.blue.shade300),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: SntIconButton(
                    caption: ConstantsBase.translate("kaydet"),
                    color: ConstantsBase.defaultButtonColor,
                    icon: Icons.save,
                    onTap: () async{
                      _formKey.currentState.save();
                      if (_formKey.currentState.validate()) {
                        ConstantsBase.showSnackBarShort(_scaffoldKey, ConstantsBase.translate("bilgiler_kaydediliyor"));
                        if(kayit.get("ID") == null) {
                          kayit.set("ID", ConstantsBase.getRandomUUID());
                          await BaseModel.insert(kayit).then((_) async{
                            ConstantsBase.showSnackBarShort(widget.baseModelPageScaffoldKey, kayit.singleTitle + " " + ConstantsBase.translate("eklendi"));
                            await NavigatorBase.pop();
                            ConstantsBase.eventBus.fire(ModelDuzenlemeEvent(baseModelPageId));
                            return;
                          }).catchError((e){
                            debugPrint(e.toString());
                            kayit.set("ID", null);
                            if(e is DatabaseException) {
                              ConstantsBase.showSnackBarLong(_scaffoldKey, BaseModel.convertDbErrorToStr(kayit, e));
                            } else {
                              ConstantsBase.showSnackBarLong(_scaffoldKey, e.toString());
                            }
                            return;
                          });
                          return;
                        } else {
                          await BaseModel.update(kayit).then((_) async{
                            ConstantsBase.showSnackBarShort(widget.baseModelPageScaffoldKey, kayit.singleTitle + " " + ConstantsBase.translate("guncellendi"));
                            await NavigatorBase.pop();
                            ConstantsBase.eventBus.fire(ModelDuzenlemeEvent(baseModelPageId));
                            return;
                          }).catchError((e){
                            debugPrint(e.toString());
                            if(e is DatabaseException) {
                              ConstantsBase.showSnackBarLong(_scaffoldKey, BaseModel.convertDbErrorToStr(kayit, e));
                            } else {
                              ConstantsBase.showSnackBarLong(_scaffoldKey, e.toString());
                            }
                            return;
                          });
                        }
                      }
                      return;
                    })
                )
              ])
          )
        )
      ),
      body: ConstantsBase.wrapWidgetWithBanner(SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: getFormItems(),
          )
        ),
      ))
    );
  }
}