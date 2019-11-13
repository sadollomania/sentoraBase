import 'package:flutter/material.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/model/fieldTypes/BlobField.dart';
import 'package:sentora_base/model/fieldTypes/DateField.dart';
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
    List<BaseFieldType> fieldTypes = List<BaseFieldType>();
    fieldTypes.add(StringField(fieldLabel:"ID", fieldHint:"ID", name:"ID", nullable: false));
    fieldTypes.add(StringField(fieldLabel:"INSDATE", fieldHint:"INSDATE", name:"INSDATE", nullable: false));
    fieldTypes.add(StringField(fieldLabel:"INSBY", fieldHint:"INSBY", name:"INSBY", nullable: false));
    fieldTypes.add(StringField(fieldLabel:"UPDDATE", fieldHint:"UPDDATE", name:"UPDDATE", nullable: false));
    fieldTypes.add(StringField(fieldLabel:"UPDBY", fieldHint:"UPDBY", name:"UPDBY", nullable: false));
    fieldTypes.addAll(fieldTypes);
    return fieldTypes;
  }

  Map<String, dynamic> _toMap() {
    Map<String, dynamic> retVals = Map<String, dynamic>();
    allFieldTypes.forEach((fieldType){
      if(fieldType.runtimeType == DateField) {
        retVals[fieldType.name] = ConstantsBase.dateFormat.format(_fieldValues[fieldType.name]);
      } else {
        retVals[fieldType.name] = _fieldValues[fieldType.name];
      }
    });
    return retVals;
  }

  void _fromMap(Map<String, dynamic> map) {
    allFieldTypes.forEach((fieldType){
      if(fieldType.runtimeType == DateField) {
        set(fieldType.name, ConstantsBase.dateFormat.format(map[fieldType.name]));
      } else {
        set(fieldType.name, map[fieldType.name]);
      }
    });
  }

  String _createDbTableScript() {
    String str = " CREATE TABLE " + tableName + " ( ";
    int index = 0, len = allFieldTypes.length;
    allFieldTypes.forEach((fieldType){
      ++index;
      str += fieldType.name;
      if(fieldType.runtimeType == StringField || fieldType.runtimeType == DateField) {
        str += " TEXT";
      } else if(fieldType.runtimeType == IntField) {
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
    return await db.insert(
      tableName,
      _toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> _updateInDb() async {
    final Database db = await DBHelperBase.instance.getDb();
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
    return List.generate(maps.length, (i) {
      BaseModel newObj = BaseModel.createNewObject(modelName);
      newObj._fromMap(maps[i]);
      return newObj;
    });
  }

  dynamic get(String fieldName) {
    return _fieldValues[fieldName];
  }

  void set(String fieldName, dynamic fieldValue) {
    _fieldValues[fieldName] = fieldValue;
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

  static String createDbTableScript(BaseModel baseModel) {
    return baseModel._createDbTableScript();
  }
}