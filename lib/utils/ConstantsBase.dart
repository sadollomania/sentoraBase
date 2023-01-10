import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:sentora_base/events/UpdatePageStateEvent.dart';
import 'package:sentora_base/lang/LangBase.dart';
import 'package:sentora_base/lang/SentoraLocaleConfig.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum SnackbarDuration {
  SHORT,
  LONG,
  ALWAYS,
  NONE,
}

class ConstantsBase {
  static bool isWeb = false;
  static bool isWindows = false;
  static bool isLinux = false;
  static bool isMacOS = false;
  static bool isDesktop = false;

  static final double datePickerHeight = 210;
  static final DateTime defaultMinTime = DateTime(2000, 1, 1);
  static final DateTime defaultMaxTime = DateTime(2199, 12, 31);

  static bool bannerEnabled = false;
  static late Row unityBannerAd;
  static Map<String, dynamic> _localisedValues = Map<String, dynamic>();
  static Future loadLocalizedValues() async {
    String languageCode = ConstantsBase.getKeyValue(ConstantsBase.localeKey)!;
    String jsonContentApp =
        await rootBundle.loadString("lang/$languageCode.json");
    Map<String, dynamic> baseVals = LangBase.getLocaleVals(languageCode);
    Map<String, dynamic> appVals = json.decode(jsonContentApp);

    Iterable<String> baseKeys = baseVals.keys;
    Iterable<String> appKeys = appVals.keys;
    appKeys.forEach((appKey) {
      if (baseKeys.contains(appKey)) {
        debugPrint("appKey overrides baseKey : " + appKey);
        debugPrint("baseKeyValue : " + baseVals[appKey].toString());
        debugPrint("appKeyValue : " + appVals[appKey].toString());
      }
    });
    _localisedValues.clear();
    _localisedValues
      ..addAll(baseVals)
      ..addAll(appVals);
  }

  static Widget wrapWidgetWithBanner(Widget body) {
    if (ConstantsBase.bannerEnabled) {
      return Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(flex: 1, child: body), ConstantsBase.unityBannerAd],
      ));
    } else {
      return body;
    }
  }

  static List<ContentConfig> Function(BuildContext context)? introSlides;
  static Color transparentColor = Color(0x00ffffff);
  static late List<SentoraLocaleConfig> localeConfig;
  static const String introShownKey = "intro_shown";
  static const String localeKey = "sentora_selected_locale";
  static int pageSize = 8;
  static final String dataTag = "data";
  static final String totalCountTag = "totalCount";
  static const Color defaultDisabledColor = Colors.black26;
  static const Color defaultButtonColor = Colors.blue;
  static const Color defaultIconColor = Colors.teal;
  static const Color defaultEnabledColor = Colors.white;
  static Color greenAccentShade100Color = Colors.greenAccent.shade100;
  static Color yellowShade500Color = Colors.yellow.shade500;
  static const int defaultMenuButtonIconFlex = 1;
  static const int defaultMenuButtonTextFlex = 3;
  static const double filterDetailButtonWidth = 25;
  static const double filterDetailButtonLabelWidth = 130;
  static const double filterButtonFontSize = 14;
  static const EdgeInsetsGeometry filterButtonEdges = EdgeInsets.all(5.0);
  static HashMap<String, String> decimalConversion =
      HashMap.fromEntries([MapEntry(",", "."), MapEntry(".", ",")]);
  static late String decimalSeparator;

  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat timeFormat = DateFormat('HH:mm:ss');
  static final _uuid = Uuid();
  static late SharedPreferences _prefs;
  static late EventBus eventBus;
  static String _notificationPreferenceKey = "__NOTIFICATION_ID_MAP__";
  static bool isAndroid = true;
  static bool isEmulator = true;

  static String getCompFieldName(String name, String? filterMode) {
    return name + (filterMode == null ? "" : ("-" + filterMode));
  }

  static Future setIsEmulator() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      isEmulator = androidInfo.isPhysicalDevice;
      isAndroid = true;
    } catch (e) {}

    try {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      isEmulator = iosInfo.isPhysicalDevice;
      isAndroid = false;
    } catch (e) {}
  }

  static Map<String, String> prefDefaultVals = {};

  static void fireUpdateStateEvent(String pageId) {
    eventBus.fire(UpdatePageStateEvent(pageId));
  }

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

  static DateTime? tryParse(DateFormat dateFormat, String str) {
    try {
      return dateFormat.parse(str);
    } catch (e) {
      return null;
    }
  }

  static String translate(String key) {
    return _localisedValues[key] ?? "key : " + key;
  }

  static void showToast(BuildContext context, String text) {
    Toast.show(text, duration: Toast.lengthShort, gravity: Toast.bottom);
  }

  static void showToastLong(BuildContext context, String text) {
    Toast.show(text, duration: Toast.lengthLong, gravity: Toast.bottom);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackBarShort(GlobalKey<ScaffoldState> _scaffoldKey, String text) {
    return showSnackBar(_scaffoldKey, text, SnackbarDuration.SHORT);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackBarLong(GlobalKey<ScaffoldState> _scaffoldKey, String text) {
    return showSnackBar(_scaffoldKey, text, SnackbarDuration.LONG);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackBarAlways(GlobalKey<ScaffoldState> _scaffoldKey, String text) {
    return showSnackBar(_scaffoldKey, text, SnackbarDuration.ALWAYS);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackBarWithDuration(GlobalKey<ScaffoldState> _scaffoldKey,
          String text, Duration duration) {
    return showSnackBar(_scaffoldKey, text, SnackbarDuration.NONE,
        duration: duration);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      GlobalKey<ScaffoldState> _scaffoldKey,
      String text,
      SnackbarDuration snackBarDuration,
      {Duration? duration}) {
    Duration? compDuration;
    switch (snackBarDuration) {
      case SnackbarDuration.SHORT:
        compDuration = Duration(seconds: 3);
        break;
      case SnackbarDuration.LONG:
        compDuration = Duration(seconds: 10);
        break;
      case SnackbarDuration.ALWAYS:
        compDuration = null;
        break;
      case SnackbarDuration.NONE:
        compDuration = duration ?? const Duration(seconds: 3);
        break;
    }
    if (compDuration == null) {
      return ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    } else {
      return ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(
        content: Text(text),
        duration: compDuration,
      ));
    }
  }

  static SizedBox createSizedBoxWithBgColor(
      {double? width, double? height, Color? color}) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color ?? Colors.white),
      ),
    );
  }

  static Future<void> loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!prefDefaultVals.containsKey(ConstantsBase.localeKey)) {
      prefDefaultVals[ConstantsBase.localeKey] = "tr";
    }
    return;
  }

  static int getNotificationId(String id) {
    String str = getKeyValue(_notificationPreferenceKey)!;
    Map mp = json.decode(str);
    if (mp.containsKey(id)) {
      return mp[id];
    } else {
      int newId = mp.length + 1;
      mp[id] = newId;
      setKeyValue(_notificationPreferenceKey, json.encode(mp));
      return newId;
    }
  }

  static String? getKeyValue(String key) {
    /*if(_prefs == null) {
      throw new Exception("Prefs not loaded. Consider calling ConstantsBase.loadPrefs with await");
    }*/
    return _prefs.getString(key) ??
        (prefDefaultVals[key] != null
            ? prefDefaultVals[key]
            : throw new Exception(
                "ConstantsBase PREF_DEFAULT_VALS not initialized for $key"));
  }

  static Future<void> setKeyValue(String key, String value) async {
    /*if(_prefs == null) {
      throw new Exception("Prefs not loaded. Consider calling ConstantsBase.loadPrefs with await");
    }*/
    await _prefs.setString(key, value);
  }

  static Future<String> getVisiblePath() async {
    if (Platform.isAndroid) {
      Directory? appDir = await getExternalStorageDirectory();
      return appDir!.path;
    } else {
      Directory appDir = await getApplicationDocumentsDirectory();
      return appDir.path;
    }
  }

  static String convertTurkishCharacters(String str) {
    return str
        .replaceAll("ı", "@@s01@@")
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
    return str
        .replaceAll("@@s01@@", "ı")
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

  static Map<String, String> convertParamsToNameValueMap(
      List<String> paramList) {
    Map<String, String> retList = HashMap<String, String>();
    for (var i = 0, len = paramList.length; i < len; ++i) {
      List<String> nameValuePair = paramList[i].split("=");
      String key = convertBackTurkishCharacters(nameValuePair[0]);
      String val = convertBackTurkishCharacters(nameValuePair[1]);
      retList[key] = val;
    }
    return retList;
  }

  static double? tryParseDouble(String str) {
    str = str.replaceAll(",", ".");
    if (str.endsWith(".")) {
      str = str.substring(0, str.length - 1);
    }
    return double.tryParse(str);
  }

  static double parseDouble(String str) {
    str = str.replaceAll(",", ".");
    if (str.endsWith(".")) {
      str = str.substring(0, str.length - 1);
    }
    return double.parse(str);
  }

  static LocaleType convertLocaleToLocaleType() {
    switch (ConstantsBase.getKeyValue(ConstantsBase.localeKey)) {
      case "tr":
        return LocaleType.tr;
      default:
        return LocaleType.en;
    }
  }

  static List<TextInputFormatter> getNumberTextInputFormatters(
      {required bool signed, required bool decimal}) {
    List<TextInputFormatter> textInputFormatters = [];
    textInputFormatters.add(FilteringTextInputFormatter.allow(RegExp(
        (signed ? "-?" : "") +
            "(0|[1-9]\\d*)" +
            (decimal ? "[\\.\\,]?\\d?" : ""))));
    return textInputFormatters;
  }

  static String? convertErrorToStr(dynamic exception, String errorTitle,
      String uniqueErrDescr, String foreignKeyErrDescr) {
    DatabaseException e;
    if (exception is DatabaseException) {
      e = exception;
    } else {
      return null;
    }

    String errorMsg = e.toString();
    String defaultRetStr = errorTitle + " : " + errorMsg;
    String retStr = "";
    if (errorMsg.contains("UNIQUE") || errorMsg.contains("unique")) {
      //TODO eğer burda çoklu kolon varsa ne olur bak
      retStr = uniqueErrDescr;
    } else if (errorMsg.contains("FOREIGN KEY") ||
        errorMsg.contains("foreign key")) {
      retStr = foreignKeyErrDescr;
    } else {
      retStr = defaultRetStr;
    }
    return retStr;
  }

  static String convertLanguageCodeToTitle(String languageCode) {
    switch (languageCode) {
      case "tr":
        return "Türkçe";
      case "en":
        return "English";
      default:
        throw Exception("Bilinmeyen languageCode : " + languageCode);
    }
  }

  static Image convertLanguageCodeToImage(String languageCode) {
    switch (languageCode) {
      case "tr":
        return Image.asset('assets/images/lang/tr.png', fit: BoxFit.fill);
      case "en":
        return Image.asset('assets/images/lang/en.png', fit: BoxFit.fill);
      default:
        throw Exception("Bilinmeyen languageCode : " + languageCode);
    }
  }
}
