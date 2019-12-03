import 'package:flutter/material.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/model/fieldTypes/BlobFieldType.dart';
import 'package:sentora_base/model/fieldTypes/BooleanFieldType.dart';
import 'package:sentora_base/model/fieldTypes/DateFieldType.dart';
import 'package:sentora_base/model/fieldTypes/ForeignKeyFieldType.dart';
import 'package:sentora_base/model/fieldTypes/IntFieldType.dart';
import 'package:sentora_base/model/fieldTypes/RealFieldType.dart';
import 'package:sentora_base/model/fieldTypes/StringFieldType.dart';
import 'package:sentora_base/pages/BaseModelPage.dart';
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
  static Map<String, Color Function(BaseModel baseModel)> _modelListBgColors = Map<String, Color Function(BaseModel baseModel)>();
  static Map<String, List<List<String>>> _modelMultiColumnUniqueConstraints = Map<String, List<List<String>>>();

  Future<void> beforeInsert() async{}
  Future<void> afterInsert() async{}

  Future<void> beforeUpdate() async{}
  Future<void> afterUpdate() async{}

  Future<void> beforeDelete() async{}
  Future<void> afterDelete() async{}

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
  List<List<String>> multiColumnUniqueConstraints;
  Color Function(BaseModel baseModel) listBgColor;

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
    @required this.multiColumnUniqueConstraints,
    this.listBgColor,
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
      _modelMultiColumnUniqueConstraints[modelName] = multiColumnUniqueConstraints;
      _modelListBgColors[modelName] = listBgColor;
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

     BaseModel ret = BaseModel(
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
      multiColumnUniqueConstraints: _modelMultiColumnUniqueConstraints[modelName],
       listBgColor: _modelListBgColors[modelName],
    );

    ret.allFieldTypes.forEach((fieldType){
      ret._fieldValues[fieldType.name] = fieldType.defaultValue;
    });

    return ret;
  }

  BaseModelPage createBaseModelPage() {
    return BaseModelPage(widgetModelName: modelName,);
  }

  BaseModelPage createBaseModelQueryPage(String pageTitle, String getListQuery, Row Function(BaseModel selectedKayit) constructButtonsRow) {
    return BaseModelPage(widgetModelName: modelName, pageTitle: pageTitle, getListQuery: getListQuery, constructButtonsRow: constructButtonsRow,);
  }

  List<BaseFieldType> _constructFields() {
    List<BaseFieldType> allFieldTypes = List<BaseFieldType>();
    allFieldTypes.add(StringFieldType(fieldLabel:"ID", fieldHint:"Kayıt No", name:"ID", nullable: false, filterable: false));
    allFieldTypes.add(DateFieldType(fieldLabel:"Kyt.Trh.", fieldHint:"Kayıt Tarihi", name:"INSDATE", nullable: false));
    allFieldTypes.add(StringFieldType(fieldLabel:"Kyt.Eden", fieldHint:"Kayıt Eden", name:"INSBY", nullable: false, sortable: false, filterable: false));
    allFieldTypes.add(DateFieldType(fieldLabel:"Gün.Trh.", fieldHint:"Güncelleme Tarihi", name:"UPDDATE", nullable: false));
    allFieldTypes.add(StringFieldType(fieldLabel:"Gün.Yapan", fieldHint:"Güncelleme Yapan", name:"UPDBY", nullable: false, sortable: false, filterable: false));
    allFieldTypes.addAll(fieldTypes);
    return allFieldTypes;
  }

  Map<String, dynamic> _toMap() {
    Map<String, dynamic> retVals = Map<String, dynamic>();
    allFieldTypes.forEach((fieldType){
      if(fieldType.runtimeType == BlobFieldType) {
        retVals[fieldType.name] = _fieldValues[fieldType.name];
      } else if(fieldType.runtimeType == BooleanFieldType) {
        retVals[fieldType.name] = _fieldValues[fieldType.name] == true ? 1 : 0;
      } else if(fieldType.runtimeType == DateFieldType) {
        if(_fieldValues[fieldType.name] != null) {
          retVals[fieldType.name] = ConstantsBase.dateTimeFormat.format(_fieldValues[fieldType.name]);
        } else {
          retVals[fieldType.name] = null;
        }
      } else if(fieldType.runtimeType == ForeignKeyFieldType) {
        if(_fieldValues[fieldType.name] != null) {
          retVals[fieldType.name] = (_fieldValues[fieldType.name] as BaseModel).get("ID");
        } else {
          retVals[fieldType.name] = null;
        }
      } else if(fieldType.runtimeType == IntFieldType) {
        retVals[fieldType.name] = _fieldValues[fieldType.name];
      } else if(fieldType.runtimeType == RealFieldType) {
        retVals[fieldType.name] = _fieldValues[fieldType.name];
      } else if(fieldType.runtimeType == StringFieldType) {
        retVals[fieldType.name] = _fieldValues[fieldType.name];
      } else {
        throw new Exception("Unknown FieldType : " + fieldType.runtimeType.toString());
      }
    });
    return retVals;
  }

  Future<void> _fromMap(Map<String, dynamic> map) async {
    for(int i = 0, len = allFieldTypes.length; i < len; ++i) {
      BaseFieldType fieldType = allFieldTypes[i];
      if(fieldType.runtimeType == BlobFieldType) {
        set(fieldType.name, map[fieldType.name]);
      } else if(fieldType.runtimeType == BooleanFieldType) {
        set(fieldType.name, map[fieldType.name] == 1);
      } else if(fieldType.runtimeType == DateFieldType) {
        if(map[fieldType.name] != null) {
          set(fieldType.name, ConstantsBase.dateTimeFormat.parse(map[fieldType.name]));
        } else {
          set(fieldType.name, null);
        }
      } else if(fieldType.runtimeType == ForeignKeyFieldType) {
        if(map[fieldType.name] != null) {
          ForeignKeyFieldType foreignKeyField = fieldType as ForeignKeyFieldType;
          BaseModel baseModel = await getById(foreignKeyField.foreignKeyModel.modelName, foreignKeyField.foreignKeyModel.tableName, map[fieldType.name]);
          set(fieldType.name, baseModel);
        } else {
          set(fieldType.name, null);
        }
      } else if(fieldType.runtimeType == IntFieldType) {
        set(fieldType.name, map[fieldType.name]);
      } else if(fieldType.runtimeType == RealFieldType) {
        set(fieldType.name, map[fieldType.name]);
      } else if(fieldType.runtimeType == StringFieldType) {
        set(fieldType.name, map[fieldType.name]);
      } else {
        throw new Exception("Unknown FieldType : " + fieldType.runtimeType.toString());
      }
    }
  }

  String _createDbTableScript() {
    String str = " CREATE TABLE " + tableName + " ( ";
    int index = 0, len = allFieldTypes.length;
    allFieldTypes.forEach((fieldType){
      ++index;
      str += fieldType.name;
      if(fieldType.runtimeType == StringFieldType || fieldType.runtimeType == DateFieldType || fieldType.runtimeType == ForeignKeyFieldType) {
        str += " TEXT";
      } else if(fieldType.runtimeType == IntFieldType || fieldType.runtimeType == BooleanFieldType) {
        str += " INTEGER";
      } else if(fieldType.runtimeType == RealFieldType) {
        str += " REAL";
      } else if(fieldType.runtimeType == BlobFieldType) {
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

        if(fieldType.nullable == false) {
          str += " NOT NULL";
        } else {
          str += " NULL";
        }
      }

      if(fieldType.unique) {
        str += " UNIQUE";
      }

      if(index != len) {
        str += ",";
      }
    });

    multiColumnUniqueConstraints.forEach((List<String> uniqueConstraint){
      String uniqueStr = ",UNIQUE(";
      for (int i = 0, len = uniqueConstraint.length; i < len; ++i) {
        String columnName = uniqueConstraint[i];
        uniqueStr += columnName;
        if(i != len - 1) {
          uniqueStr += ",";
        }
      }
      uniqueStr += ")";
      str += uniqueStr;
    });

    str += " ); ";
    return str;
  }

  Future<int> _insertToDb() async {
    await beforeInsert();
    final Database db = await DBHelperBase.instance.getDb();
    _fieldValues["INSDATE"] = DateTime.now();
    _fieldValues["INSBY"] = "AUTO";
    _fieldValues["UPDDATE"] = DateTime.now();
    _fieldValues["UPDBY"] = "AUTO";
    int retVal;
    try {
      retVal = await db.insert(
        tableName,
        _toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch(e) {
      debugPrint(e.toString());
      throw e;
    }

    await afterInsert();
    return retVal;
  }

  Future<int> _updateInDb() async {
    await beforeUpdate();
    final Database db = await DBHelperBase.instance.getDb();
    _fieldValues["UPDDATE"] = DateTime.now();
    _fieldValues["UPDBY"] = "AUTO";
    int retVal = await db.update(
      tableName,
      _toMap(),
      where: "ID = ?",
      whereArgs: [get("ID")],
    );
    await afterUpdate();
    return retVal;
  }

  Future<int> _deleteFromDb() async {
    await beforeDelete();
    final db = await DBHelperBase.instance.getDb();
    int retVal = await db.delete(
      tableName,
      where: "ID = ?",
      whereArgs: [get("ID")],
    );
    await afterDelete();
    return retVal;
  }

  Future<Map<String, dynamic>> _getList(int limit, int offset, String orderBy, String rawQuery, Map<String, dynamic> filterMap) async {
    Map<String, dynamic> retMap = Map<String, dynamic>();
    final Database db = await DBHelperBase.instance.getDb();
    String where;
    List<dynamic> whereArgs = List<dynamic>();
    if(filterMap != null && filterMap.length > 0) {
      String str;
      dynamic val;
      where = "";
      List<String> filterKeys =  filterMap.keys.toList();
      for(int i = 0, len = filterKeys.length; i < len; ++i) {
        str = filterKeys[i];
        val = filterMap[str];

        List<String> tmpArr = str.split("-");
        String fieldName = tmpArr[0];
        String operator = tmpArr[1];
        if(i != 0) {
          where += " and ";
        }

        switch(operator) {
          case "isnotnull":
            where += fieldName + " is not null ";
            break;
          case "isnull":
            where += fieldName + " is null ";
            break;
          case "like":
            where += fieldName + " like '%' || ? || '%' ";
            break;
          case "dateeq":
            where += " substr(" + fieldName + ",1,10) = ? ";
            break;
          case "dategt":
            where += " substr(" + fieldName + ",1,10) > ? ";
            break;
          case "datelt":
            where += " substr(" + fieldName + ",1,10) < ? ";
            break;
          case "inteq":
          case "realeq":
          case "foreigneq":
            where += fieldName + " = ? ";
            break;
          case "booleq":
            val = val ? 1 : 0;
            where += fieldName + " = ? ";
            break;
          case "intgt":
          case "realgt":
            where += fieldName + " > ? ";
            break;
          case "intlt":
          case "reallt":
            where += fieldName + " < ? ";
            break;
          default:
            throw Exception("unknown filter mode : " + operator);
        }
        whereArgs.add(val);
      }
    }

    List<Map<String, dynamic>> maps;
    if(rawQuery == null) {
      if(limit == -1) {
        if(where == null) {
          maps = await db.query(tableName);
        } else {
          maps = await db.query(tableName, where: where, whereArgs: whereArgs);
        }
      } else {
        if(where == null) {
          maps = await db.query(tableName, limit: limit, offset: offset, orderBy: orderBy != null && orderBy.isNotEmpty ? orderBy : null);
        } else {
          maps = await db.query(tableName, limit: limit, offset: offset, orderBy: orderBy != null && orderBy.isNotEmpty ? orderBy : null, where: where, whereArgs: whereArgs);
        }
      }
    } else {
      String pagedQuery = rawQuery;
      if(where != null) {
        pagedQuery += " WHERE " + where;
      }
      if(orderBy != null && orderBy.isNotEmpty) {
        pagedQuery += " ORDER BY " + orderBy;
      }
      if(limit != -1) {
        pagedQuery += " LIMIT " + limit.toString() + " OFFSET " + offset.toString();
      }
      if(where == null) {
        maps = await db.rawQuery(pagedQuery);
      } else {
        maps = await db.rawQuery(pagedQuery, whereArgs);
      }
    }
    List<BaseModel> retList = List<BaseModel>();
    for(int i = 0, len = maps.length; i < len; ++i) {
      BaseModel newObj = BaseModel.createNewObject(modelName);
      await newObj._fromMap(maps[i]);
      retList.add(newObj);
    }
    int totalCount;
    if(limit == -1) {
      totalCount = maps.length;
    } else {
      if(rawQuery == null) {
        if(where == null) {
          totalCount = (await db.query(tableName)).length;
        } else {
          totalCount = (await db.query(tableName, where: where, whereArgs: whereArgs)).length;
        }
      } else {
        if(where == null) {
          totalCount = (await db.rawQuery(rawQuery)).length;
        } else {
          totalCount = (await db.rawQuery(rawQuery + " WHERE " + where)).length;
        }
      }
    }
    retMap[ConstantsBase.totalCountTag] = totalCount;
    retMap[ConstantsBase.dataTag] = retList;
    return retMap;
  }

  BaseFieldType _getFieldTypeByName(String name) {
    for(int i = 0, len = allFieldTypes.length; i < len; ++i) {
      if(allFieldTypes[i].name == name) {
        return allFieldTypes[i];
      }
    }
    return null;
  }

  String _convertDbErrorToStr(DatabaseException e) {
    String errorMsg = e.toString();
    String defaultRetStr = "Detaylandırılmamış Hata ( BaseModel ) : " + errorMsg;
    String retStr = "";
    if(errorMsg.contains("UNIQUE")) { //TODO eğer burda çoklu kolon varsa ne olur bak
      int tableNameIndex = errorMsg.indexOf(tableName);
      if(tableNameIndex == -1) {
        retStr = defaultRetStr;
      } else {
        String columnName = errorMsg.substring(tableNameIndex + tableName.length + 1).split(" ")[0];
        BaseFieldType fieldType = _getFieldTypeByName(columnName);
        if(fieldType == null) {
          retStr = defaultRetStr;
        } else {
          retStr = singleTitle + " tablosunda " + fieldType.fieldLabel + " kolonunda -> \"" + get(fieldType.name) + "\" değerinde kayıt zaten mevcut";
        }
      }
    } else {
      retStr = defaultRetStr;
    }
    return retStr;
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
    String retStr;
    dynamic objVal = currentModel.get(path[i]);
    if(objVal.runtimeType == DateTime) {
      retStr = ConstantsBase.dateTimeFormat.format(objVal as DateTime);
    } else {
      retStr = objVal == null ? "" : objVal.toString();
    }
    return retStr;
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

  dynamic getValueByPath(pathStr, {convertToStr = false}) {
    List<String> path = pathStr.split(".");
    BaseModel currentModel = this;
    int i = 0;
    for(int len = path.length - 1; i < len; ++i) {
      currentModel = currentModel.get(path[i]) as BaseModel;
    }
    dynamic objVal = currentModel.get(path[i]);
    if(!convertToStr) {
      return objVal;
    } else {
      if(objVal.runtimeType == DateTime) {
        return ConstantsBase.dateTimeFormat.format(objVal as DateTime);
      } else {
        return objVal == null ? "" : objVal.toString();
      }
    }
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

  static Future<Map<String, dynamic>> getList(BaseModel baseModel, { int pageSize = -1, int currentPage = 1, String orderBy, String rawQuery, Map<String, dynamic> filterMap }) async{
    assert(pageSize >= -1);
    assert(currentPage > 0);
    int offset = 0;
    if(pageSize != -1) {
      offset = (currentPage - 1) * pageSize;
    }
    return await baseModel._getList(pageSize, offset, orderBy, rawQuery, filterMap);
  }

  static String convertDbErrorToStr(BaseModel baseModel, DatabaseException e) {
    return baseModel._convertDbErrorToStr(e);
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

  static String dropDbTableScript(BaseModel baseModel) {
    return "DROP TABLE " + baseModel.tableName + ";";
  }
}