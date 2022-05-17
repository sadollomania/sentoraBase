import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsSentora {
  static UnityAdsSentora? _instance;
  static UnityAdsSentora get instance => _instance!;
  static void init(androidId, iosId, testMode, bannerPlacementId, screenPlacementId, videoPlacementId, minInterval) =>
      _instance ??= UnityAdsSentora._init(androidId, iosId, testMode, bannerPlacementId, screenPlacementId, videoPlacementId, minInterval);
  static DateTime? lastShowTime;
  static int minMinute = 20;

  final String androidId;
  final String iosId;
  final bool testMode;
  final String? bannerPlacementId;
  final String? screenPlacementId;
  final String? videoPlacementId;
  final int? minInterval;

  UnityAdsSentora._init(this.androidId, this.iosId, this.testMode, this.bannerPlacementId, this.screenPlacementId, this.videoPlacementId, this.minInterval) {
    minMinute = minInterval ?? minMinute;
    String gameId;
    if (Platform.isAndroid) {
      gameId = androidId;
    } else {
      gameId = iosId;
    }
    UnityAds.init(
        gameId: gameId,
        testMode: testMode,
        onComplete: () => print('Initialization Complete'),
        onFailed: (error, message) => print('Initialization Failed: $error $message'),
    );
        /*listener: (state, args) {
          if (state == UnityAdState.started) {
            onUnityAdsStart(instance.screenPlacementId);
          } else if (state == UnityAdState.ready) {
            onUnityAdsReady(instance.screenPlacementId);
          } else if (state == UnityAdState.complete) {
            onUnityAdsComplete(instance.screenPlacementId);
          } else if (state == UnityAdState.error) {
            onUnityAdsError(args);
          } else if (state == UnityAdState.skipped) {
            onUnityAdsSkipped(instance.screenPlacementId);
          }
        });*/
  }
  factory UnityAdsSentora() => instance;

  static void onUnityAdsError(String placementId, error, message) {
    lastShowTime = DateTime.now();
    debugPrint('Unity Ad $placementId failed: $error $message');
  }

  static void onUnityAdsComplete(String placementId) {
    if(placementId != instance.bannerPlacementId) {
      lastShowTime = DateTime.now();
    }
    debugPrint('Unity Finished $placementId completed');
  }

  static void onUnityAdsSkipped(String placementId) {
    debugPrint('Unity Finished $placementId skipped');
  }

  /*void onUnityAdsReady(String placementId) {
    debugPrint('Unity Ad Ready: $placementId');
  }*/
  
  static void onUnityAdsStart(String placementId) {
    debugPrint('Unity Start: $placementId');
  }

  static bool minTimePassed() {
    if (lastShowTime == null) {
      return true;
    } else {
      DateTime now = DateTime.now();
      if (lastShowTime!.add(Duration(minutes: minMinute)).isBefore(now)) {
        return true;
      } else {
        return false;
      }
    }
  }

  static void showScreen() {
    if (instance.screenPlacementId != null && instance.screenPlacementId!.isNotEmpty) {
      if (minTimePassed()) {
        UnityAds.showVideoAd(
          placementId: instance.screenPlacementId!,
          onStart: (placementId) => onUnityAdsStart(placementId),
          onClick: (placementId) => print('Video Ad $placementId click'),
          onSkipped: (placementId) => onUnityAdsSkipped(placementId),
          onComplete: (placementId) => onUnityAdsComplete(placementId),
          onFailed: (placementId, error, message) => onUnityAdsError(placementId,error,message),
        );
      } else {
        debugPrint("Interstitial Ad not shown. minElapsedTime not passed");
      }
    } else {
      debugPrint("Interstitial Ads not initialized. Construct UnityAds with screenPlacementId");
    }
  }

  static void showVideo() {
    if (instance.videoPlacementId != null && instance.videoPlacementId!.isNotEmpty) {
      if (minTimePassed()) {
        UnityAds.showVideoAd(
          placementId: instance.videoPlacementId!,
          onStart: (placementId) => onUnityAdsStart(placementId),
          onClick: (placementId) => print('Video Ad $placementId click'),
          onSkipped: (placementId) => onUnityAdsSkipped(placementId),
          onComplete: (placementId) => onUnityAdsComplete(placementId),
          onFailed: (placementId, error, message) => onUnityAdsError(placementId,error,message),
        );
      } else {
        debugPrint("Rewarded Video Ad not shown. minElapsedTime not passed");
      }
    } else {
      debugPrint("Reward Ads not initialized. Construct UnityAds with videoPlacementId");
    }
  }

  static void dispose() {}
}
