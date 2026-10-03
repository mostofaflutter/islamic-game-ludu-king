import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();

  static final AdService instance = AdService._();

  // Test device ID for Realme C5s (hashed ID from Google Mobile Ads SDK logcat)
  static const String realmeTestDeviceId = 'EF5601B2E329A0F40EF7A43F667AC704';

  // Real AdMob Ad Unit IDs
  static const String androidBannerAdUnitId =
      'ca-app-pub-7197956130433969/7444174428';
  static const String androidInterstitialAdUnitId =
      'ca-app-pub-7197956130433969/5631650874';

  // Google official test ad unit IDs (for 100% guaranteed fill during development/testing)
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static String get bannerAdUnitId =>
      kDebugMode ? testBannerAdUnitId : androidBannerAdUnitId;

  static String get interstitialAdUnitId =>
      kDebugMode ? testInterstitialAdUnitId : androidInterstitialAdUnitId;

  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;

  bool get supportsAds =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialize() async {
    if (!supportsAds) return;

    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: [realmeTestDeviceId],
      ),
    );
    _loadInterstitial();
  }

  void _loadInterstitial() {
    if (!supportsAds || _isLoadingInterstitial || _interstitialAd != null) {
      return;
    }

    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (_) {
          _isLoadingInterstitial = false;
        },
      ),
    );
  }

  void showInterstitialThen(VoidCallback onComplete) {
    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitial();
      onComplete();
      return;
    }

    _interstitialAd = null;
    var completed = false;

    void finish() {
      if (completed) return;
      completed = true;
      ad.dispose();
      _loadInterstitial();
      onComplete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, __) => finish(),
    );
    ad.show();
  }
}
