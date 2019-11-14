import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/pages/BaseModelDuzenleme.dart';

import 'package:sentora_base/widgets/MenuButton.dart';

class BaseModelPage extends StatefulWidget {
  final String widgetModelName;

  BaseModelPage({
    @required this.widgetModelName,
  });

  @override
  State<StatefulWidget> createState() => new _BaseModelPageState(modelName: this.widgetModelName);
}

class _BaseModelPageState extends State<BaseModelPage> {
  String modelName;
  BaseModel ornekKayit;
  BaseModel _selectedKayit;

  _BaseModelPageState({
    @required this.modelName
  }) {
    this.ornekKayit = BaseModel.createNewObject(this.modelName);
}

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Emin Misiniz?"),
          content: Text(ornekKayit.singleTitle + " Silinecektir!"),
          actions: <Widget>[
            FlatButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Sil"),
              onPressed: () {
                BaseModel.delete(_selectedKayit).then((_){
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedKayit = null;
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ornekKayit.pageTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: MenuButton(
                    title: 'Ekle',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute<Null>(
                          builder: (BuildContext context) {
                            return BaseModelDuzenleme(widgetKayit : _selectedKayit, widgetModelName: modelName,);
                          }));
                    }),
              ),
              SizedBox(width: 10,),
              Expanded(
                flex: 3,
                child: MenuButton(
                    title: 'Düzenle',
                    disabled: _selectedKayit == null,
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute<Null>(builder: (BuildContext context) {
                            return BaseModelDuzenleme(widgetKayit : _selectedKayit, widgetModelName: modelName,);
                          }));
                    }),
              ),
              SizedBox(width: 10,),
              Expanded(
                flex: 2,
                child: MenuButton(
                    title: 'Sil',
                    disabled: _selectedKayit == null,
                    onPressed: () {
                      _showDialog();
                    }),
              ),
            ]
          ),
          Expanded(
            child: FutureBuilder<List<BaseModel>>(
              future: BaseModel.getList(ornekKayit),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView(
                  children: snapshot.data.map((kayit) => Container(
                    color: _selectedKayit != null && _selectedKayit.get("ID") == kayit.get("ID") ? Colors.yellow : Colors.white,
                    child: ListTile(
                      selected: _selectedKayit != null && _selectedKayit.get("ID") == kayit.get("ID"),
                      onTap: () {
                        if(_selectedKayit != null && _selectedKayit.get("ID") == kayit.get("ID")) {
                          setState(() {
                            _selectedKayit = null;
                          });
                        } else {
                          setState(() {
                            _selectedKayit = kayit;
                          });
                        }
                      },
                      title: Text(kayit.listTileTitle + " : " + kayit.getListTileTitleValue()),
                      subtitle: Text(kayit.listTileSubTitle + " : " + kayit.getListTileSubTitleValue()),
                      leading: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Text(kayit.getTileAvatarFieldValue(), style: TextStyle(fontSize: 18.0, color: Colors.white,)),
                      ),
                    ),
                  )).toList(),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}