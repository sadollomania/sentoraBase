import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTranslations {
  Locale locale;
  static Map<String, dynamic> _localisedValues = Map<String, dynamic>();

  AppTranslations(Locale locale) {
    this.locale = locale;
  }

  static AppTranslations of(BuildContext context) {
    return Localizations.of<AppTranslations>(context, AppTranslations);
  }

  static Future<AppTranslations> load(Locale locale) async {
    AppTranslations appTranslations = AppTranslations(locale);
    String jsonContent =
    await rootBundle.loadString("lang/${locale.languageCode}.json");
    _localisedValues = json.decode(jsonContent);
    return appTranslations;
  }

  get currentLanguage => locale.languageCode;

  String translate(String key) {
    if(!_localisedValues.containsKey(key)) {
      return "Localization key : " + key + " does not exist in file. Add this key to \"lang/__.json\"";
    }
    return _localisedValues[key].toString();
  }
}