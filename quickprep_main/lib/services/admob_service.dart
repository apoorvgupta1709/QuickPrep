import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants.dart';
import '../providers/monetization_provider.dart';

class AdMobService {
  static bool _initialized = false;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static bool _isPreloadingInterstitial = false;
  static bool _isPreloadingRewarded = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await MobileAds.instance.initialize();
        _initialized = true;
      }
    } catch (e) {
      debugPrint('AdMob initialization notice: $e');
    }
  }

  static String getBannerAdUnitId(ClientMonetizationConfig config) {
    if (kDebugMode) {
      return Platform.isIOS
          ? AppConstants.testBannerIdIOS
          : AppConstants.testBannerIdAndroid;
    }
    return config.bannerId;
  }

  static String getInterstitialAdUnitId(ClientMonetizationConfig config) {
    if (kDebugMode) {
      return Platform.isIOS
          ? AppConstants.testInterstitialIdIOS
          : AppConstants.testInterstitialIdAndroid;
    }
    return config.interstitialId;
  }

  static String getRewardedAdUnitId(ClientMonetizationConfig config) {
    if (kDebugMode) {
      return Platform.isIOS
          ? AppConstants.testRewardedIdIOS
          : AppConstants.testRewardedIdAndroid;
    }
    return config.rewardedId;
  }

  // Preload Interstitial Ad
  static void preloadInterstitial({
    required bool isPro,
    required ClientMonetizationConfig config,
  }) {
    if (isPro || !config.adsEnabled || _isPreloadingInterstitial || _interstitialAd != null) {
      return;
    }
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    _isPreloadingInterstitial = true;
    final adUnitId = getInterstitialAdUnitId(config);

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isPreloadingInterstitial = false;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              // Preload next
              preloadInterstitial(isPro: isPro, config: config);
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _interstitialAd = null;
            },
          );
        },
        onAdFailedToLoad: (err) {
          _isPreloadingInterstitial = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  // Show Interstitial Ad (Natural pause after mock test or reviews)
  static void showInterstitial({
    required bool isPro,
    required ClientMonetizationConfig config,
    VoidCallback? onDismissed,
  }) {
    if (isPro || !config.adsEnabled) {
      onDismissed?.call();
      return;
    }

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          onDismissed?.call();
          preloadInterstitial(isPro: isPro, config: config);
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _interstitialAd = null;
          onDismissed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      // Not ready yet, bypass gracefully
      onDismissed?.call();
      preloadInterstitial(isPro: isPro, config: config);
    }
  }

  // Preload Rewarded Ad
  static void preloadRewarded({
    required bool isPro,
    required ClientMonetizationConfig config,
  }) {
    if (isPro || !config.adsEnabled || _isPreloadingRewarded || _rewardedAd != null) {
      return;
    }
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    _isPreloadingRewarded = true;
    final adUnitId = getRewardedAdUnitId(config);

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isPreloadingRewarded = false;
        },
        onAdFailedToLoad: (err) {
          _isPreloadingRewarded = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  // Show Rewarded Ad (Unlocks PDF cheat sheet, streak restore, or deep-dive)
  static void showRewardedAd({
    required bool isPro,
    required ClientMonetizationConfig config,
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onFailedOrUnavailable,
  }) {
    if (isPro || !config.adsEnabled) {
      // Pro users get the reward directly without viewing ads
      onUserEarnedReward(RewardItem(1, 'Pro Access'));
      return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          preloadRewarded(isPro: isPro, config: config);
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _rewardedAd = null;
          onFailedOrUnavailable?.call();
        },
      );

      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward);
      });
    } else {
      // If ad was not preloaded, trigger reward or graceful fallback in dev/test
      if (kDebugMode) {
        onUserEarnedReward(RewardItem(1, 'Dev Reward'));
      } else {
        onFailedOrUnavailable?.call();
      }
      preloadRewarded(isPro: isPro, config: config);
    }
  }
}
