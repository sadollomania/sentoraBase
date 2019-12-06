import 'package:flutter/material.dart';
import 'package:unity_ads_flutter/unity_ads_flutter.dart';

class UnityAds with UnityAdsListener{
  static UnityAds _instance;
  static UnityAds get instance => _instance;
  static void init(androidId, iosId, testMode, bannerPlacementId, screenPlacementId, videoPlacementId) => _instance ??= UnityAds._init(androidId, iosId, testMode, bannerPlacementId, screenPlacementId, videoPlacementId);
  static DateTime lastShowTime;
  static int minMinute = 5;

  final String androidId;
  final String iosId;
  final bool testMode;
  final String bannerPlacementId;
  final String screenPlacementId;
  final String videoPlacementId;

  UnityAds._init(this.androidId, this.iosId, this.testMode, this.bannerPlacementId, this.screenPlacementId, this.videoPlacementId) {
    UnityAdsFlutter.initialize(androidId, iosId, this, testMode);
  }
  factory UnityAds() => instance;

  @override
  void onUnityAdsError(UnityAdsError error, String message) {
    debugPrint('Unity $error occurred: $message');
  }

  @override
  void onUnityAdsFinish(String placementId, FinishState result) {
    debugPrint('Unity Finished $placementId with $result');
  }

  @override
  void onUnityAdsReady(String placementId) {
    debugPrint('Unity Ad Ready: $placementId');
  }

  @override
  void onUnityAdsStart(String placementId) {
    lastShowTime = DateTime.now();
    debugPrint('Unity Start: $placementId');
  }

  static void showBanner() {
    if(instance.bannerPlacementId != null && instance.bannerPlacementId.isNotEmpty) {
      UnityAdsFlutter.show(instance.bannerPlacementId);
    } else {
      debugPrint("Banner Ads not initialized. Construct UnityAds with bannerPlacementId");
    }
  }

  static bool minTimePassed() {
    if(lastShowTime == null) {
      return true;
    } else {
      DateTime now = DateTime.now();
      if(lastShowTime.add(Duration(minutes: minMinute)).isBefore(now)) {
        return true;
      } else {
        return false;
      }
    }
  }

  static void showScreen() {
    if(instance.screenPlacementId != null && instance.screenPlacementId.isNotEmpty) {
      if(minTimePassed()) {
        UnityAdsFlutter.show(instance.screenPlacementId);
      } else {
        debugPrint("Interstitial Ad not shown. minElapsedTime not passed");
      }
    } else {
      debugPrint("Interstitial Ads not initialized. Construct UnityAds with screenPlacementId");
    }
  }

  static void showVideo() {
    if(instance.videoPlacementId != null && instance.videoPlacementId.isNotEmpty) {
      if(minTimePassed()) {
        UnityAdsFlutter.show(instance.videoPlacementId);
      } else {
        debugPrint("Interstitial Ad not shown. minElapsedTime not passed");
      }
    } else {
      debugPrint("Reward Ads not initialized. Construct UnityAds with videoPlacementId");
    }
  }

  static void dispose(){

  }
}