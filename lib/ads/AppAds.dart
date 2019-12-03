//import 'package:firebase_admob/firebase_admob.dart';

class AppAds {
  /*
  static String _appId;
  static String _bannerUnitId;
  static String _screenUnitId;
  static String _rewardUnitId;

  static bool _bannerInitialized = false;
  static bool _rewardInitialized = false;

  static BannerAd myBanner;
  static InterstitialAd myInterstitial;

  static MobileAdTargetingInfo targetingInfo;
  static bool interstitialShown = false;

  /*
  Example MobileTargetingInfo

  MobileAdTargetingInfo(
    keywords: <String>['flutter', 'kağıt', 'yazboz', 'çetele', 'card'],
    contentUrl: 'https://flutter.io',
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );
  */

  static void init(String appId, {String bannerUnitId, String screenUnitId, String rewardUnitId, List<String> keywords }){
    _appId = appId;
    _bannerUnitId = bannerUnitId;
    _screenUnitId = screenUnitId;
    _rewardUnitId = rewardUnitId;

    targetingInfo = MobileAdTargetingInfo(
      keywords: keywords??['flutter'],
      contentUrl: 'http://www.sentora.com.tr',
      childDirected: false,
      testDevices: <String>[], // Android emulators are considered test devices
    );

    FirebaseAdMob.instance.initialize(appId: _appId);

    if(_bannerUnitId != null) {
      myBanner = BannerAd(
        //adUnitId: BannerAd.testAdUnitId,
        adUnitId: _bannerUnitId,
        size: AdSize.smartBanner,
        targetingInfo: targetingInfo,
      );
      _bannerInitialized = true;
    }

    if(_rewardUnitId != null) {
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
      myBanner = BannerAd(
        //adUnitId: BannerAd.testAdUnitId,
        adUnitId: _bannerUnitId,
        size: AdSize.smartBanner,
        targetingInfo: targetingInfo,
      );

      myBanner..load()..show(
        // Positions the banner ad 60 pixels from the bottom of the screen
        anchorOffset: 60.0,
        // Positions the banner ad 10 pixels from the center of the screen to the right
        horizontalCenterOffset: 10.0,
        // Banner Position
        anchorType: AnchorType.bottom,
      );
    } else {
      print("Banner Ads not initialized. Construct AppAds with bannerUnitId");
    }
  }

  static void showScreen() {
    if(_screenUnitId != null && interstitialShown == false) {
      myInterstitial = new InterstitialAd(
        adUnitId: _screenUnitId,
        listener: (MobileAdEvent e) {
          if(e == MobileAdEvent.failedToLoad){
            myInterstitial.dispose();
            myInterstitial = null;
            interstitialShown = false;
            showScreen();
          } else if(e == MobileAdEvent.loaded){
            myInterstitial.show().then((_){
              interstitialShown = true;
            });
          } else if(e == MobileAdEvent.closed){
            myInterstitial.dispose();
            myInterstitial = null;
            showScreen();
            interstitialShown = false;
          } else if(e == MobileAdEvent.leftApplication){
            myInterstitial.dispose();
            myInterstitial = null;
            interstitialShown = false;
          }
        });
      myInterstitial.load();
    } else {
      print("Interstatial Ads not initialized. Construct AppAds with screenUnitId");
    }
  }

  static void showVideo() {
    if(_rewardInitialized) {
      RewardedVideoAd.instance.load(adUnitId: _rewardUnitId, targetingInfo: targetingInfo);
    } else {
      print("Reward Ads not initialized. Construct AppAds with rewardUnitId");
    }
  }

  /// Remember to call this in the State object's dispose() function.
  static void dispose(){
    if(_bannerInitialized) {
      myBanner.dispose();
    }
    if(_screenUnitId != null && myInterstitial != null) {
      myInterstitial.dispose();
    }
  }*/
}