import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:sentora_base/lang/AppLocalizationsBase.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ConstantsBase {
  static int pageSize = 6;
  static final String dataTag = "data";
  static final String totalCountTag = "totalCount";
  static const Color defaultDisabledColor = Colors.black26;
  static const Color defaultButtonColor = Color(0xFF42A5F5);
  static const Color defaultIconColor = Colors.teal;
  static const Color defaultEnabledColor = Colors.white;
  static const int defaultMenuButtonIconFlex = 1;
  static const int defaultMenuButtonTextFlex = 3;
  static const double filterDetailButtonWidth = 25;
  static const double filterDetailButtonLabelWidth = 130;
  static const double filterButtonFontSize = 14;
  static const EdgeInsetsGeometry filterButtonEdges = EdgeInsets.all(5.0);

  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final _uuid = Uuid();
  static bool localeExists = false;
  static SharedPreferences _prefs;
  static EventBus eventBus;
  static String _notificationPreferenceKey = "__NOTIFICATION_ID_MAP__";

  static Map<String, String> prefDefaultVals = {
  };

  static double getMaxWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getMaxHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static List<BaseModel> getDataFormGetList(Map<String, dynamic> map) {
    return map[dataTag];
  }

  static int getTotalCountFormGetList(Map<String, dynamic> map) {
    return map[totalCountTag];
  }

  static String getRandomUUID() {
    return _uuid.v1();
  }

  static String translate(BuildContext context, String key) {
    if(!localeExists) {
      throw Exception("Pass localeConfig to App first.");
    }
    return AppLocalizationsBase.of(context).translate(key);
  }

  static void showToast(BuildContext context, String text) {
    Toast.show(text, context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
  }

  static void showToastLong(BuildContext context, String text) {
    Toast.show(text, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
  }

  static Future<void> loadPrefs() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return;
  }

  static int getNotificationId(String id) {
    String str = getKeyValue(_notificationPreferenceKey);
    Map mp = json.decode(str);
    if(mp.containsKey(id)) {
      return mp[id];
    } else {
      int newId = mp.length + 1;
      mp[id] = newId;
      setKeyValue(_notificationPreferenceKey, json.encode(mp));
      return newId;
    }
  }

  static String getKeyValue(String key) {
    if(_prefs == null) {
      throw new Exception("Prefs not loaded. Consider calling ConstantsBase.loadPrefs with await");
    }
    return _prefs.getString(key) ?? (prefDefaultVals != null ? prefDefaultVals[key] : throw new Exception("ConstantsBase PREF_DEFAULT_VALS not initialized for $key"));
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

  static String convertTurkishCharacters(String str) {
    return str.replaceAll("ı", "@@s01@@")
        .replaceAll("İ", "@@s02@@")
        .replaceAll("ş", "@@s03@@")
        .replaceAll("Ş", "@@s04@@")
        .replaceAll("ö", "@@s05@@")
        .replaceAll("Ö", "@@s06@@")
        .replaceAll("ğ", "@@s07@@")
        .replaceAll("Ğ", "@@s08@@")
        .replaceAll("ç", "@@s09@@")
        .replaceAll("Ç", "@@s10@@")
        .replaceAll("ü", "@@s11@@")
        .replaceAll("Ü", "@@s12@@")
        .replaceAll(" ", "@@s13@@");
  }

  static String convertBackTurkishCharacters(String str) {
    return str.replaceAll("@@s01@@", "ı")
        .replaceAll("@@s02@@", "İ")
        .replaceAll("@@s03@@", "ş")
        .replaceAll("@@s04@@", "Ş")
        .replaceAll("@@s05@@", "ö")
        .replaceAll("@@s06@@", "Ö")
        .replaceAll("@@s07@@", "ğ")
        .replaceAll("@@s08@@", "Ğ")
        .replaceAll("@@s09@@", "ç")
        .replaceAll("@@s10@@", "Ç")
        .replaceAll("@@s11@@", "ü")
        .replaceAll("@@s12@@", "Ü")
        .replaceAll("@@s13@@", " ");
  }

  static Map<String, String> convertParamsToNameValueMap(List<String> paramList) {
    Map<String, String> retList = HashMap<String, String>();
    for(var i = 0, len = paramList.length; i < len; ++i) {
      List<String> nameValuePair = paramList[i].split("=");
      String key = convertBackTurkishCharacters(nameValuePair[0]);
      String val = convertBackTurkishCharacters(nameValuePair[1]);
      retList[key] = val;
    }
    return retList;
  }
}