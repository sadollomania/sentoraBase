import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentora_base/ads/AppAds.dart';
import 'package:sentora_base/data/DBHelperBase.dart';
import 'package:sentora_base/lang/AppLocalizationsBase.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/notification/BaseNotification.dart';
import 'package:sentora_base/notification/NotificationTaskConfig.dart';
import 'package:sentora_base/notification/ReceivedNotification.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:share/receive_share_state.dart';
import 'package:share/share.dart';

abstract class BaseApp extends StatefulWidget {

  final String appTitle;
  final Widget Function() getMainPage;
  final Map<String, dynamic> notificationConfig;
  final Map<String, dynamic> adsConfig;
  final Map<String, dynamic> dbConfig;
  final Map<String, dynamic> bgTaskConfig;
  final Map<String, dynamic> localeConfig;
  final Map<String, dynamic> shareConfig;
  //_BaseAppState _baseAppState;

  void initBaseModelClasses();
  void beforeInitState();
  void afterInitState();
  void beforeDispose();
  void afterDispose();
  void receiveShare(Share shared);

  BaseApp({
    @required this.appTitle,
    @required this.getMainPage,
    this.dbConfig,
    this.adsConfig,
    this.notificationConfig,
    this.bgTaskConfig,
    this.localeConfig,
    this.shareConfig,
  }) :
        assert(
            dbConfig == null ||
            (
                dbConfig["databaseFileName"] != null && dbConfig["databaseFileName"] is String &&
                dbConfig["databaseVersion"] != null && dbConfig["databaseVersion"] is int &&
                dbConfig["versionFunctions"] != null && dbConfig["versionFunctions"] is List<Function>
            )
        ),
        assert(
            adsConfig == null ||
            adsConfig["adsDisabled"] == true ||
            (
                List<String>.from(["AdMob", "UnityAds"]).contains(adsConfig["type"]) &&
                (
                    adsConfig["type"] == "AdMob" &&
                    adsConfig["adsAppId"] != null &&
                    (
                        adsConfig["adsBannerUnitId"] != null ||
                        adsConfig["adsScreenUnitId"] != null ||
                        adsConfig["adsRewardUnitId"] != null
                    )
                ) ||
                (
                    adsConfig["type"] == "UnityAds" &&
                    adsConfig["androidId"] != null &&
                    adsConfig["iosId"] != null &&
                    adsConfig["testMode"] != null && adsConfig["testMode"] is bool &&
                    (
                        adsConfig["bannerPlacementId"] != null ||
                        adsConfig["screenPlacementId"] != null ||
                        adsConfig["videoPlacementId"] != null
                    )
                )
            )
        ),
        assert(
            notificationConfig == null ||
            (
                (notificationConfig["receiveFun"] == null || notificationConfig["receiveFun"] is Function(ReceivedNotification)) &&
                (notificationConfig["payloadFun"] == null || notificationConfig["payloadFun"] is Function(String)) &&
                (
                    notificationConfig["tasks"] == null ||
                    notificationConfig["tasks"] is List<NotificationTaskConfig>
                )
            )
        ),
        assert(
          localeConfig == null ||
          (
            localeConfig["supportedLocales"] != null && localeConfig["supportedLocales"] is Iterable<Locale> && (localeConfig["supportedLocales"] as Iterable<Locale>).length > 0
          )
        );

  State<StatefulWidget> createState() => new _BaseAppState();

  /*@override
  State<StatefulWidget> createState() {
    _baseAppState = ;
    return _baseAppState;
  }

  void setState(Function f) {
    _baseAppState.setState(f);
  }*/
}

class _BaseAppState extends ReceiveShareState<BaseApp> {
  @override
  void initState() {
    ConstantsBase.setIsEmulator();
    widget.beforeInitState();
    ConstantsBase.loadPrefs();
    super.initState();
    widget.initBaseModelClasses();
    if(widget.dbConfig != null) {
      DBHelperBase.init(widget.dbConfig["databaseFileName"], widget.dbConfig["databaseVersion"], widget.dbConfig["versionFunctions"]);
    }

    if(widget.notificationConfig != null) {
      BaseNotification.init(widget.notificationConfig["receiveFun"], widget.notificationConfig["payloadFun"]).then((_) async{
        if(widget.notificationConfig["cancelAll"] == true) {
          await BaseNotification.cancelAll();
        }

        if(widget.notificationConfig["tasks"] != null) {
          (widget.notificationConfig["tasks"] as List<NotificationTaskConfig>).forEach((notificationTaskConfig) async {
            await BaseNotification.newNotification(notificationTaskConfig.id, notificationTaskConfig.title, notificationTaskConfig.body, time : notificationTaskConfig.time, interval: notificationTaskConfig.interval, payload: notificationTaskConfig.payload);
          });
        }
      });
    }

    if(widget.localeConfig != null) {
      ConstantsBase.localeExists = true;
    }

    if(widget.shareConfig != null && widget.shareConfig["enableReceiveShare"] == true) {
      enableShareReceiving();
    }

    ConstantsBase.eventBus = EventBus();

    if(widget.adsConfig != null && widget.adsConfig["adsDisabled"] != true) {
      AppAds.init(widget.adsConfig);
    }
    widget.afterInitState();
  }

  @override
  void dispose() {
    if(widget.dbConfig != null) {
      DBHelperBase.instance.close();
    }
    if(widget.notificationConfig != null) {
      BaseNotification.dispose();
    }
    ConstantsBase.eventBus.destroy();
    if(widget.adsConfig != null && widget.adsConfig["adsDisabled"] != true) {
      AppAds.dispose();
    }
    widget.beforeDispose();
    super.dispose();
    widget.afterDispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigatorBase.navigatorKey,
      title: widget.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: widget.localeConfig != null ? widget.localeConfig["supportedLocales"] : [const Locale('tr', 'TR')],
      localizationsDelegates: widget.localeConfig != null ? [
        // THIS CLASS WILL BE ADDED LATER
        // A class which loads the translations from JSON files
        AppLocalizationsBase.delegate,
        // Built-in localization of basic text for Material widgets
        GlobalMaterialLocalizations.delegate,
        // Built-in localization for text direction LTR/RTL
        GlobalWidgetsLocalizations.delegate,
      ] : [
        // Built-in localization of basic text for Material widgets
        GlobalMaterialLocalizations.delegate,
        // Built-in localization for text direction LTR/RTL
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          debugPrint("*language locale is null!!!");
          if(supportedLocales == null || supportedLocales.length == 0) {
            return Locale('en', 'US');
          } else {
            return supportedLocales.first;
          }
        }

        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      home:  widget.getMainPage()
    );
  }

  @override
  void receiveShare(Share shared) {
    widget.receiveShare(shared);
  }
}