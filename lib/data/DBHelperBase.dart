import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class DBHelperBase {
  static String nullsFirst = "NULLSFIRST";
  static String nullsLast = "NULLSLAST";
  static String nullsNone = "";

  static DBHelperBase _instance;
  static DBHelperBase get instance => _instance;
  static void init(databaseFileName, databaseVersion, versionFunctions) => _instance ??= DBHelperBase._init(databaseFileName, databaseVersion, versionFunctions);

  final String databaseFileName;
  final int databaseVersion;
  final List<Function> versionFunctions;

  DBHelperBase._init(this.databaseFileName, this.databaseVersion, this.versionFunctions);
  factory DBHelperBase() => instance;

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
      onOpen: (db) async {
        await db.execute("PRAGMA foreign_keys = ON;");
        debugPrint("Foreign Keys enabled");
      }
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

  static Future<void> openFileExplorerForDBRestore(BuildContext context) async {
    try {
      String _path = await FilePicker.getFilePath(type: FileType.ANY, fileExtension: "");
      if(null != _path) {
        await instance.restoreDB(_path);
        await instance.getDb();
      }
    } on PlatformException catch (e) {
      debugPrint("Unsupported operation" + e.toString());
      throw e;
    }
  }
}