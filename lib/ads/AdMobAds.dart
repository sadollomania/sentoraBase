import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

class AdMobAds {
  static String _appId;
  static String _bannerUnitId;
  static String _screenUnitId;
  static String _rewardUnitId;

  static bool _bannerInitialized = false;
  static bool _screenInitialized = false;
  static bool _rewardInitialized = false;

  static BannerAd _myBanner;
  static InterstitialAd _myInterstitial;

  static MobileAdTargetingInfo _targetingInfo;
  static bool _interstitialLoaded = false;

  static void init(String appId, {String bannerUnitId, String screenUnitId, String rewardUnitId, List<String> keywords }){
    _appId = appId;
    _bannerUnitId = bannerUnitId;
    _screenUnitId = screenUnitId;
    _rewardUnitId = rewardUnitId;

    _targetingInfo = MobileAdTargetingInfo(
      keywords: keywords??['flutter'],
      contentUrl: 'http://www.sentora.com.tr',
      childDirected: false,
      testDevices: <String>[], // Android emulators are considered test devices
    );

    FirebaseAdMob.instance.initialize(appId: _appId);

    if(_bannerUnitId != null && _bannerUnitId.isNotEmpty && !ConstantsBase.isEmulator) {
      _myBanner = BannerAd(
        //adUnitId: BannerAd.testAdUnitId,
        adUnitId: _bannerUnitId,
        size: AdSize.smartBanner,
        targetingInfo: _targetingInfo,
      );
      _bannerInitialized = true;
    }

    if(_screenUnitId != null && _screenUnitId.isNotEmpty && !ConstantsBase.isEmulator) {
      _screenInitialized = true;
      _loadInterstatialAd();
    }

    if(_rewardUnitId != null && _rewardUnitId.isNotEmpty && !ConstantsBase.isEmulator) {
      RewardedVideoAd.instance.listener =
          (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
        if (event == RewardedVideoAdEvent.loaded) {
          RewardedVideoAd.instance.show();
        }
      };
      _rewardInitialized = true;
    }
  }

  static void showBanner() {
    if(_bannerInitialized) {
      _myBanner = BannerAd(
        //adUnitId: BannerAd.testAdUnitId,
        adUnitId: _bannerUnitId,
        size: AdSize.smartBanner,
        targetingInfo: _targetingInfo,
      );

      _myBanner..load()..show(
        // Positions the banner ad 60 pixels from the bottom of the screen
        anchorOffset: 60.0,
        // Positions the banner ad 10 pixels from the center of the screen to the right
        horizontalCenterOffset: 10.0,
        // Banner Position
        anchorType: AnchorType.bottom,
      );
    } else if(!ConstantsBase.isEmulator) {
      print("Banner Ads not initialized. Construct AdMobAds with bannerUnitId");
    }
  }

  static void _loadInterstatialAd() {
    _myInterstitial = new InterstitialAd(
        adUnitId: _screenUnitId,
        listener: (MobileAdEvent e) {
          if(e == MobileAdEvent.failedToLoad || e == MobileAdEvent.closed || e == MobileAdEvent.leftApplication){
            if(_myInterstitial != null) {
              _myInterstitial.dispose();
              _myInterstitial = null;
            }
            _interstitialLoaded = false;
            _loadInterstatialAd();
          } else if(e == MobileAdEvent.loaded){
            _interstitialLoaded = true;
          }
        });
    _myInterstitial.load();
  }

  static void showScreen() {
    if(_screenInitialized) {
      if(_interstitialLoaded) {
        _myInterstitial.show();
      } else {
        debugPrint("Interstitial Ad Not Loaded Yet. Delaying 200 ms.");
        //Future.delayed(Duration(milliseconds: 200), showScreen);
      }
    } else if(!ConstantsBase.isEmulator) {
      print("Interstatial Ads not initialized. Construct AdMobAds with screenUnitId");
    }
  }

  static void showVideo() {
    if(_rewardInitialized) {
      RewardedVideoAd.instance.load(adUnitId: _rewardUnitId, targetingInfo: _targetingInfo).catchError((_){
        showVideo();
      });
    } else if(!ConstantsBase.isEmulator) {
      print("Reward Ads not initialized. Construct AdMobAds with rewardUnitId");
    }
  }

  /// Remember to call this in the State object's dispose() function.
  static void dispose(){
    if(_bannerInitialized) {
      _myBanner.dispose();
    }
    if(_screenUnitId != null && _screenUnitId.isNotEmpty && _myInterstitial != null) {
      _myInterstitial.dispose();
    }
  }
}