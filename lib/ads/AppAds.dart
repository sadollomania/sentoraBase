import 'package:flutter/cupertino.dart';
import 'package:sentora_base/ads/AdMobAds.dart';
import 'package:sentora_base/ads/UnityAds.dart';

class AppAds {
  static String _type;
  static bool _disabled;

  static void init(adsConfig){
    _type = adsConfig["type"];
    _disabled = adsConfig["adsDisabled"];
    switch(_type) {
      case "AdMob":
        AdMobAds.init(adsConfig["adsAppId"], bannerUnitId: adsConfig["adsBannerUnitId"], screenUnitId: adsConfig["adsScreenUnitId"], rewardUnitId: adsConfig["adsRewardUnitId"]);
        break;
      case "UnityAds":
        UnityAds.init(adsConfig["androidId"], adsConfig["iosId"], adsConfig["testMode"], adsConfig["bannerPlacementId"], adsConfig["screenPlacementId"], adsConfig["videoPlacementId"]);
        break;
    }
  }

  static void showBanner() {
    if(_disabled) {
      debugPrint("Apps are Disabled from config.");
      return;
    }

    switch(_type) {
      case "AdMob":
        AdMobAds.showBanner();
        break;
      case "UnityAds":
        UnityAds.showBanner();
        break;
    }
  }

  static void showScreen() {
    if(_disabled) {
      debugPrint("Apps are Disabled from config.");
      return;
    }

    switch(_type) {
      case "AdMob":
        AdMobAds.showScreen();
        break;
      case "UnityAds":
        UnityAds.showScreen();
        break;
    }
  }

  static void showVideo() {
    if(_disabled) {
      debugPrint("Apps are Disabled from config.");
      return;
    }

    switch(_type) {
      case "AdMob":
        AdMobAds.showVideo();
        break;
      case "UnityAds":
        UnityAds.showVideo();
        break;
    }
  }

  static void dispose(){
    if(_disabled) {
      debugPrint("Apps are Disabled from config.");
      return;
    }

    switch(_type) {
      case "AdMob":
        AdMobAds.dispose();
        break;
      case "UnityAds":
        UnityAds.dispose();
        break;
    }
  }
}