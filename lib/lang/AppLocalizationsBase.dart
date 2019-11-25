import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizationsBase {
  final Locale locale;

  AppLocalizationsBase(this.locale);

  static const LocalizationsDelegate<AppLocalizationsBase> delegate = _AppLocalizationsBaseDelegate();

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalizationsBase of(BuildContext context) {
    return Localizations.of<AppLocalizationsBase>(context, AppLocalizationsBase);
  }

  Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString =
    await rootBundle.loadString('lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    if(!_localizedStrings.containsKey(key)) {
      debugPrint("Localization key : " + key + " does not exist in file. Add this key to \"lang/__.json\" ");
    }
    return _localizedStrings[key];
  }
}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations object
class _AppLocalizationsBaseDelegate
    extends LocalizationsDelegate<AppLocalizationsBase> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsBaseDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizationsBase> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizationsBase localizations = new AppLocalizationsBase(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsBaseDelegate old) => false;
}