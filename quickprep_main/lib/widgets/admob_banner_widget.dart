import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/user_gamification_provider.dart';
import '../providers/monetization_provider.dart';
import '../services/admob_service.dart';

class AdMobBannerWidget extends StatefulWidget {
  const AdMobBannerWidget({super.key});

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBanner();
  }

  void _loadBanner() {
    final gamification = Provider.of<UserGamificationProvider>(context);
    final monetization = Provider.of<MonetizationProvider>(context);

    // Suppress immediately for Pro users or if ads are disabled
    if (gamification.isPro || !monetization.adsEnabled) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
      return;
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    if (_bannerAd != null) return;

    final adUnitId = AdMobService.getBannerAdUnitId(monetization.config);

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _bannerAd = null;
          if (mounted) setState(() => _isLoaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gamification = Provider.of<UserGamificationProvider>(context);
    final monetization = Provider.of<MonetizationProvider>(context);

    if (gamification.isPro || !monetization.adsEnabled) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _bannerAd == null) {
      // Subtle placeholder during development / loading
      return Container(
        height: 50,
        width: double.infinity,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          kDebugMode ? '• AdMob Banner Active (Test Mode) •' : '',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      );
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
