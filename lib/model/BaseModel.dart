import 'package:flutter/material.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/model/fieldTypes/BlobField.dart';
import 'package:sentora_base/model/fieldTypes/BooleanField.dart';
import 'package:sentora_base/model/fieldTypes/DateField.dart';
import 'package:sentora_base/model/fieldTypes/ForeignKeyField.dart';
import 'package:sentora_base/model/fieldTypes/IntField.dart';
import 'package:sentora_base/model/fieldTypes/RealField.dart';
import 'package:sentora_base/model/fieldTypes/StringField.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sentora_base/data/DBHelperBase.dart';

class BaseModel {
  static List<String> _models = List<String>();
  static Map<String, String> _modelTableNames = Map<String, String>();
  static Map<String, List<BaseFieldType>> _modelFieldTypes = Map<String, List<BaseFieldType>>();
  static Map<String, String> _modelListTileTitles = Map<String, String>();
  static Map<String, String> _modelListTileTitleFields = Map<String, String>();
  static Map<String, String> _modelListTileAvatarFields = Map<String, String>();
  static Map<String, String> _modelListTileSubTitles = Map<String, String>();
  static Map<String, String> _modelListTileSubTitleFields = Map<String, String>();
  static Map<String, String> _modelPageTitles = Map<String, String>();
  static Map<String, String> _modelSingleTitles = Map<String, String>();

  String modelName;
  String tableName;
  List<BaseFieldType> fieldTypes;
  List<BaseFieldType> allFieldTypes;
  String listTileTitle;
  String listTileTitleField;
  String listTileAvatarField;
  String listTileSubTitle;
  String listTileSubTitleField;
  String pageTitle;
  String singleTitle;

  Map<String, dynamic> _fieldValues = Map<String, dynamic>();

  BaseModel({
    @required this.modelName,
    @required this.tableName,
    @required this.fieldTypes,
    @required this.listTileTitle,
    @required this.listTileTitleField,
    @required this.listTileAvatarField,
    @required this.listTileSubTitle,
    @required this.listTileSubTitleField,
    @required this.pageTitle,
    @required this.singleTitle,
  }) {
    if(!_models.contains(modelName)) {
      _modelTableNames[modelName] = tableName;
      _modelFieldTypes[modelName] = fieldTypes;
      _modelListTileTitles[modelName] = listTileTitle;
      _modelListTileTitleFields[modelName] = listTileTitleField;
      _modelListTileAvatarFields[modelName] = listTileAvatarField;
      _modelListTileSubTitles[modelName] = listTileSubTitle;
      _modelListTileSubTitleFields[modelName] = listTileSubTitleField;
      _modelPageTitles[modelName] = pageTitle;
      _modelSingleTitles[modelName] = singleTitle;
      _models.add(modelName);
    }

    allFieldTypes = _constructFields();
    allFieldTypes.forEach((fieldType){
      _fieldValues[fieldType.name] = null;
    });
  }

  static BaseModel createNewObject(String modelName) {
    if(!_models.contains(modelName)) {
      throw new Exception("Tanımsız Model Adı : " + modelName);
    }

    return BaseModel(
      modelName: modelName,
      tableName: _modelTableNames[modelName],
      fieldTypes: _modelFieldTypes[modelName],
      listTileTitle: _modelListTileTitles[modelName],
      listTileTitleField: _modelListTileTitleFields[modelName],
      listTileAvatarField: _modelListTileAvatarFields[modelName],
      listTileSubTitle: _modelListTileSubTitles[modelName],
      listTileSubTitleField: _modelListTileSubTitleFields[modelName],
      pageTitle: _modelPageTitles[modelName],
      singleTitle: _modelSingleTitles[modelName],
    );
  }

  List<BaseFieldType> _constructFields() {
    List<BaseFieldType> allFieldTypes = List<BaseFieldType>();
    allFieldTypes.add(StringField(fieldLabel:"ID", fieldHint:"ID", name:"ID", nullable: false));
    allFieldTypes.add(DateField(fieldLabel:"INSDATE", fieldHint:"INSDATE", name:"INSDATE", nullable: false));
    allFieldTypes.add(StringField(fieldLabel:"INSBY", fieldHint:"INSBY", name:"INSBY", nullable: false));
    allFieldTypes.add(DateField(fieldLabel:"UPDDATE", fieldHint:"UPDDATE", name:"UPDDATE", nullable: false));
    allFieldTypes.add(StringField(fieldLabel:"UPDBY", fieldHint:"UPDBY", name:"UPDBY", nullable: false));
    allFieldTypes.addAll(fieldTypes);
    return allFieldTypes;
  }

  Map<String, dynamic> _toMap() {
    Map<String, dynamic> retVals = Map<String, dynamic>();
    allFieldTypes.forEach((fieldType){
      if(fieldType.runtimeType == BlobField) {
        retVals[fieldType.name] = _fieldValues[fieldType.name];
      } else if(fieldType.runtimeType == BooleanField) {
        retVals[fieldType.name] = _fieldValues[fieldType.name] == true ? 1 : 0;
      } else if(fieldType.runtimeType == DateField) {
        retVals[fieldType.name] = ConstantsBase.dateFormat.format(_fieldValues[fieldType.name]);
      } else if(fieldType.runtimeType == ForeignKeyField) {
        retVals[fieldType.name] = (_fieldValues[fieldType.name] as BaseModel).get("ID");
      } else if(fieldType.runtimeType == IntField) {
        retVals[fieldType.name] = _fieldValues[fieldType.name];
      } else if(fieldType.runtimeType == RealField) {
        retVals[fieldType.name] = _fieldValues[fieldType.name];
      } else if(fieldType.runtimeType == StringField) {
        retVals[fieldType.name] = _fieldValues[fieldType.name];
      } else {
        throw new Exception("Unknown FieldType : " + fieldType.runtimeType.toString());
      }
    });
    return retVals;
  }

  Future<void> _fromMap(Map<String, dynamic> map) async{
    await allFieldTypes.forEach((fieldType) async{
      if(fieldType.runtimeType == BlobField) {
        set(fieldType.name, map[fieldType.name]);
      } else if(fieldType.runtimeType == BooleanField) {
        set(fieldType.name, map[fieldType.name] == 1);
      } else if(fieldType.runtimeType == DateField) {
        set(fieldType.name, ConstantsBase.dateFormat.parse(map[fieldType.name]));
      } else if(fieldType.runtimeType == ForeignKeyField) {
        ForeignKeyField foreignKeyField = fieldType as ForeignKeyField;
        BaseModel baseModel = await getById(foreignKeyField.foreignKeyModel.modelName, foreignKeyField.foreignKeyModel.tableName, map[fieldType.name]);
        set(fieldType.name, baseModel);
      } else if(fieldType.runtimeType == IntField) {
        set(fieldType.name, map[fieldType.name]);
      } else if(fieldType.runtimeType == RealField) {
        set(fieldType.name, map[fieldType.name]);
      } else if(fieldType.runtimeType == StringField) {
        set(fieldType.name, map[fieldType.name]);
      } else {
        throw new Exception("Unknown FieldType : " + fieldType.runtimeType.toString());
      }
    });
  }

  String _createDbTableScript() {
    String str = " CREATE TABLE " + tableName + " ( ";
    int index = 0, len = allFieldTypes.length;
    allFieldTypes.forEach((fieldType){
      ++index;
      str += fieldType.name;
      if(fieldType.runtimeType == StringField || fieldType.runtimeType == DateField || fieldType.runtimeType == ForeignKeyField) {
        str += " TEXT";
      } else if(fieldType.runtimeType == IntField || fieldType.runtimeType == BooleanField) {
        str += " INTEGER";
      } else if(fieldType.runtimeType == RealField) {
        str += " REAL";
      } else if(fieldType.runtimeType == BlobField) {
        str += " BLOB";
      } else {
        throw new Exception("Unknown type : " + fieldType.runtimeType.toString());
      }

      if(fieldType.name == "ID") {
        str += " PRIMARY KEY";
      } else {
        /*if(fieldType.defaultValue != null) {
          str += " DEFAULT " + fieldType.defaultValue;
        }*/

        if(fieldType.nullable) {
          str += " NULL";
        } else {
          str += " NOT NULL";
        }
      }

      if(index != len) {
        str += ",";
      }
    });
    str += " ); ";
    return str;
  }

  Future<int> _insertToDb() async {
    final Database db = await DBHelperBase.instance.getDb();
    _fieldValues["INSDATE"] = DateTime.now();
    _fieldValues["INSBY"] = "AUTO";
    _fieldValues["UPDDATE"] = DateTime.now();
    _fieldValues["UPDBY"] = "AUTO";
    return await db.insert(
      tableName,
      _toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> _updateInDb() async {
    final Database db = await DBHelperBase.instance.getDb();
    _fieldValues["UPDDATE"] = DateTime.now();
    _fieldValues["UPDBY"] = "AUTO";
    return await db.update(
      tableName,
      _toMap(),
      where: "ID = ?",
      whereArgs: [get("ID")],
    );
  }

  Future<int> _deleteFromDb() async {
    final db = await DBHelperBase.instance.getDb();
    return await db.delete(
      tableName,
      where: "ID = ?",
      whereArgs: [get("ID")],
    );
  }

  Future<List<BaseModel>> _getList() async {
    final Database db = await DBHelperBase.instance.getDb();
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    List<BaseModel> retList = List<BaseModel>();
    for(int i = 0, len = maps.length; i < len; ++i) {
      BaseModel newObj = BaseModel.createNewObject(modelName);
      await newObj._fromMap(maps[i]);
      retList.add(newObj);
    }
    return retList;
  }

  dynamic get(String fieldName) {
    return _fieldValues[fieldName];
  }

  void set(String fieldName, dynamic fieldValue) {
    _fieldValues[fieldName] = fieldValue;
  }

  String _getPathValueFromObj(pathStr) {
    List<String> path = pathStr.split(".");
    BaseModel currentModel = this;
    int i = 0;
    for(int len = path.length - 1; i < len; ++i) {
      currentModel = currentModel.get(path[i]) as BaseModel;
    }
    return currentModel.get(path[i]);
  }

  String _getPathListValuesFromObj(String tileFieldValue) {
    List<String> pathList = tileFieldValue.split("&");
    String retStr = "";
    for(int i = 0, len = pathList.length; i < len; ++i) {
      retStr += _getPathValueFromObj(pathList[i]);
      if(i != len - 1) {
        retStr += " / ";
      }
    }
    return retStr;
  }

  String getListTileTitleValue() {
    return _getPathListValuesFromObj(listTileTitleField);
  }

  String getListTileSubTitleValue() {
    return _getPathListValuesFromObj(listTileSubTitleField);
  }

  String getTileAvatarFieldValue() {
    return _getPathListValuesFromObj(listTileAvatarField)[0];
  }

  static Future<int> insert(BaseModel baseModel) {
    return baseModel._insertToDb();
  }

  static Future<int> update(BaseModel baseModel) {
    return baseModel._updateInDb();
  }

  static Future<int> delete(BaseModel baseModel) {
    return baseModel._deleteFromDb();
  }

  static Future<List<BaseModel>> getList(BaseModel baseModel) {
    return baseModel._getList();
  }

  static Future<BaseModel> getById(String fromModel, String fromTable, String id) async {
    final Database db = await DBHelperBase.instance.getDb();
    final List<Map<String, dynamic>> maps = await db.query(fromTable, where: "ID = ?", whereArgs: List<String>.from([id]));
    if(maps.length > 0) {
      BaseModel newObj = BaseModel.createNewObject(fromModel);
      await newObj._fromMap(maps[0]);
      return newObj;
    }
    return null;
  }

  static String createDbTableScript(BaseModel baseModel) {
    return baseModel._createDbTableScript();
  }
}