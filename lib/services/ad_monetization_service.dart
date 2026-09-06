import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Central place for SwipeBuy ad configuration and lifecycle helpers.
/// Production ad unit IDs should be injected from remote config or a secure
/// deployment configuration rather than hard-coded in business logic.
class AdMonetizationService {
  static const bool useTestAds = true;

  static const String androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd createBanner({required AdSize size, required void Function() onLoaded, required void Function(LoadAdError error) onFailed}) {
    final ad = BannerAd(
      adUnitId: androidTestBannerId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed(error);
        },
      ),
    );
    ad.load();
    return ad;
  }

  static InterstitialAd? _interstitial;

  static void preloadInterstitial() {
    InterstitialAd.load(
      adUnitId: androidTestInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  static Future<void> showInterstitialIfReady() async {
    final ad = _interstitial;
    _interstitial = null;
    if (ad == null) return;
    await ad.show();
    preloadInterstitial();
  }
}
