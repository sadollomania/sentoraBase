import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class DBHelperBase {
  static DBHelperBase instance = new DBHelperBase._internal();
  String databaseFileName;
  int databaseVersion;
  List<Function> versionFunctions;

  DBHelperBase._internal();

  factory DBHelperBase({
    String databaseFileName,
    int databaseVersion,
    List<Function> versionFunctions,
  }) {
    instance.databaseFileName = databaseFileName;
    instance.databaseVersion = databaseVersion;
    instance.versionFunctions = versionFunctions;
    return instance;
  }

  Database _database;
  bool _didInit = false;

  Future<String> _getDBPath() async {
    String dbFolder = await getDatabasesPath();
    return join(dbFolder, databaseFileName);
  }

  Future _init() async {
    _database = await openDatabase(
      await _getDBPath(),
      onCreate: (db, version) async {
        for(int i = 0; i < version; ++i) {
          await versionFunctions[i](db);
          debugPrint("Upgraded to Version " + ( i + 1 ).toString());
        }
        return true;
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for(int i = oldVersion; i < newVersion; ++i) {
          await versionFunctions[i](db);
          debugPrint("Upgraded to Version " + ( i + 1 ).toString());
        }
        return true;
      },
      version: databaseVersion,
    );
    _didInit = true;
  }

  Future<Database> getDb() async {
    if(!_didInit) await _init();
    return _database;
  }

  Future<bool> close() async{
    if(_database != null && _database.isOpen) {
      await _database.close();
      _database = null;
      _didInit = false;
      return true;
    }
    return false;
  }

  Future<void> backupDB() async {
    bool dbOpen = await close();
    String dbPath = await _getDBPath();
    String backupPath = await ConstantsBase.getVisiblePath() + "/" + databaseFileName + ".backup";
    File f = File(dbPath);
    f.copySync(backupPath);
    if(dbOpen) {
      await getDb();
    }
  }

  Future<void> restoreDB(String path) async {
    bool dbOpen = await close();
    String dbPath = await _getDBPath();
    File f = File(path);
    f.copySync(dbPath);
    if(dbOpen) {
      await getDb();
    }
  }
}