import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentora_base/lang/AppTranslations.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

class AppTranslationsDelegate extends LocalizationsDelegate<AppTranslations> {
  final Locale newLocale;

  const AppTranslationsDelegate({this.newLocale});

  @override
  bool isSupported(Locale locale) {
    return ConstantsBase.localeConfig.any((cfg) {
      if(cfg.locale.languageCode == locale.languageCode) {
        return true;
      }
      return false;
    });
  }

  @override
  Future<AppTranslations> load(Locale locale) {
    return AppTranslations.load(newLocale ?? locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppTranslations> old) {
    return true;
  }
}