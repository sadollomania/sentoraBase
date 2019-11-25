import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';

class BaseModelQueryPage extends StatefulWidget {
  final String pageTitle;
  final String getListQuery;
  final String widgetModelName;
  final Row Function(BaseModel selectedKayit) constructButtonsRow;

  BaseModelQueryPage({
    @required this.widgetModelName,
    @required this.pageTitle,
    @required this.getListQuery,
    @required this.constructButtonsRow,
  });

  @override
  State<StatefulWidget> createState() => new _BaseModelQueryPageState(modelName: widgetModelName, pageTitle: pageTitle, getListQuery: getListQuery, constructButtonsRow: constructButtonsRow);
}

class _BaseModelQueryPageState extends State<BaseModelQueryPage> {
  String pageTitle;
  String getListQuery;
  String modelName;
  BaseModel ornekKayit;
  BaseModel _selectedKayit;
  Row Function(BaseModel selectedKayit) constructButtonsRow;

  _BaseModelQueryPageState({
    @required this.modelName,
    @required this.pageTitle,
    @required this.getListQuery,
    @required this.constructButtonsRow,
  }) {
    this.ornekKayit = BaseModel.createNewObject(this.modelName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          constructButtonsRow(_selectedKayit),
          Expanded(
            child: FutureBuilder<List<BaseModel>>(
              future: BaseModel.getListByQuery(ornekKayit, getListQuery),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView(
                  children: snapshot.data.map((kayit) => Container(
                    color: _selectedKayit != null && _selectedKayit.get("ID") == kayit.get("ID") ? Colors.yellow : ( kayit.listBgColor != null ? kayit.listBgColor(kayit) : Colors.white ),
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