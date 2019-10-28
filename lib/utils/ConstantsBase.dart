import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ConstantsBase {
  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final _uuid = Uuid();
  static SharedPreferences _prefs;

  static Map<String, String> prefDefaultVals;

  static String getRandomUUID() {
    return _uuid.v1();
  }

  static void showToast(BuildContext context, String text) {
    Toast.show(text, context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
  }

  static void showToastLong(BuildContext context, String text) {
    Toast.show(text, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
  }

  static Future<void> loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String getKeyValue(String key) {
    if(_prefs == null) {
      throw new Exception("Prefs not loaded. Consider calling ConstantsBase.loadPrefs with await");
    }
    return _prefs.getString(key) ?? prefDefaultVals ? prefDefaultVals[key] : throw new Exception("ConstantsBase PREF_DEFAULT_VALS not initialized for $key");
  }

  static Future<void> setKeyValue(String key, String value) async{
    if(_prefs == null) {
      throw new Exception("Prefs not loaded. Consider calling ConstantsBase.loadPrefs with await");
    }
    await _prefs.setString(key, value);
  }

  static Future<String> getVisiblePath() async{
    if(Platform.isAndroid) {
      Directory appDir = await getExternalStorageDirectory();
      return appDir.path;
    } else {
      Directory appDir = await getApplicationDocumentsDirectory();
      return appDir.path;
    }
  }
}