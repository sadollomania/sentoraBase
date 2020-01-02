import 'dart:async';

import 'package:devicelocale/devicelocale.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:sentora_base/ads/AppAds.dart';
import 'package:sentora_base/data/DBHelperBase.dart';
import 'package:sentora_base/events/LocaleChangedEvent.dart';
import 'package:sentora_base/intro/IntroPage.dart';
import 'package:sentora_base/lang/AppTranslationsDelegate.dart';
import 'package:sentora_base/lang/SentoraLocaleConfig.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/notification/BaseNotification.dart';
import 'package:sentora_base/notification/NotificationTaskConfig.dart';
import 'package:sentora_base/notification/ReceivedNotification.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:share/receive_share_state.dart';
import 'package:share/share.dart';

abstract class BaseApp extends StatefulWidget {
  static Future<Null> defaultEmptyFutureNull() {
    return Future.value(null);
  }

  void runAppBase() async{
    await beforeRun();
    await ConstantsBase.loadPrefs();
    String currLocale = ConstantsBase.getKeyValue(ConstantsBase.localeKey);
    if(currLocale == null || currLocale.isEmpty) {
      String baseSystemLocale = await Devicelocale.currentLocale;
      String loweredSystemLocale = baseSystemLocale.toLowerCase();
      String systemLocale = loweredSystemLocale.replaceAll("-", "_");
      if(systemLocale == "tr_tr" || systemLocale == "tr") {
        await ConstantsBase.setKeyValue(ConstantsBase.localeKey, "tr");
      } else {
        await ConstantsBase.setKeyValue(ConstantsBase.localeKey, "en");
      }
    }
    await afterLoadPreferencesBeforeRun();
    runApp(this);
  }

  final String appTitle;
  final Widget Function() getMainPage;
  final Map<String, dynamic> notificationConfig;
  final Map<String, dynamic> adsConfig;
  final Map<String, dynamic> dbConfig;
  final Map<String, dynamic> bgTaskConfig;
  final Map<String, dynamic> shareConfig;
  final Future<Null> Function() beforeRun;
  final Future<Null> Function() afterLoadPreferencesBeforeRun;
  final List<SentoraLocaleConfig> localeConfig;
  final Map<String, String> prefDefaultVals;
  final List<Slide> Function(BuildContext context) introSlides;
  final Color introTopBarColor;
  final Color introBottomBarColor;


  void initBaseModelClasses(BuildContext context);
  void beforeInitState(BuildContext context);
  void afterInitState(BuildContext context);
  void beforeDispose(BuildContext context);
  void afterDispose(BuildContext context);
  void afterAppRender(BuildContext context);
  void receiveShare(BuildContext context, Share shared);

  BaseApp({
    @required this.appTitle,
    @required this.getMainPage,
    List<SentoraLocaleConfig> localeConfig,
    this.dbConfig,
    this.adsConfig,
    this.notificationConfig,
    this.bgTaskConfig,
    this.shareConfig,
    Map<String, String> prefDefaultVals,
    Future<Null> Function() beforeRun,
    Future<Null> Function() afterLoadPreferencesBeforeRun,
    this.introSlides,
    this.introTopBarColor,
    this.introBottomBarColor,
  }) :
      this.beforeRun = beforeRun ?? defaultEmptyFutureNull,
        this.afterLoadPreferencesBeforeRun = afterLoadPreferencesBeforeRun ?? defaultEmptyFutureNull,
        this.localeConfig = localeConfig == null || localeConfig.length == 0 ? [SentoraLocaleConfig(title: "English", locale: Locale("en", "US"))] : localeConfig,
        this.prefDefaultVals = prefDefaultVals ?? {},
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
        ) {
    ConstantsBase.localeConfig = this.localeConfig;
    if(!this.prefDefaultVals.containsKey(ConstantsBase.introShownKey)) {
      this.prefDefaultVals[ConstantsBase.introShownKey] = "0";
    }
    ConstantsBase.prefDefaultVals = this.prefDefaultVals;
  }

  State<StatefulWidget> createState() => new _BaseAppState();
}

class _BaseAppState extends ReceiveShareState<BaseApp> {
  bool appLoaded = false;
  StreamSubscription localeChangedSubscription;
  AppTranslationsDelegate _localeOverrideDelegate;

  @override
  void initState() {
    ConstantsBase.setIsEmulator();
    widget.beforeInitState(context);
    super.initState();
    _localeOverrideDelegate = AppTranslationsDelegate(newLocale: Locale(ConstantsBase.getKeyValue(ConstantsBase.localeKey)));
    widget.initBaseModelClasses(context);
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

    if(widget.shareConfig != null && widget.shareConfig["enableReceiveShare"] == true) {
      enableShareReceiving();
    }

    ConstantsBase.eventBus = EventBus();

    if(widget.adsConfig != null && widget.adsConfig["adsDisabled"] != true) {
      AppAds.init(widget.adsConfig);
    }
    widget.afterInitState(context);
    localeChangedSubscription  = ConstantsBase.eventBus.on<LocaleChangedEvent>().listen((event){
      if(mounted) {
        setState(() {
          _localeOverrideDelegate = AppTranslationsDelegate(newLocale: event.locale);
        });
      }
    });
    ConstantsBase.introSlides = widget.introSlides;

    WidgetsBinding.instance.addPostFrameCallback((_){
      setState((){
        appLoaded=true;
      });
      widget.afterAppRender(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if(widget.dbConfig != null) {
      DBHelperBase.instance.close();
    }
    if(widget.notificationConfig != null) {
      BaseNotification.dispose();
    }
    localeChangedSubscription.cancel();
    ConstantsBase.eventBus.destroy();
    if(widget.adsConfig != null && widget.adsConfig["adsDisabled"] != true) {
      AppAds.dispose();
    }
    widget.beforeDispose(context);
    super.dispose();
    widget.afterDispose(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorBase.navigatorKey,
      title: widget.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: ConstantsBase.getKeyValue(ConstantsBase.localeKey) != null ? Locale(ConstantsBase.getKeyValue(ConstantsBase.localeKey)) : null,
      supportedLocales: widget.localeConfig.map((cfg){ return cfg.locale; }),
      localizationsDelegates: [
        _localeOverrideDelegate,
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
      home: ConstantsBase.getKeyValue(ConstantsBase.introShownKey) == "0" && widget.introSlides != null ? IntroPage(
        slides: widget.introSlides,
        mainPage: widget.getMainPage(),
        topBarColor : widget.introTopBarColor,
        bottomBarColor: widget.introBottomBarColor,
      ) : widget.getMainPage()
    );
  }

  @override
  void receiveShare(Share shared) {
    widget.receiveShare(context, shared);
  }
}