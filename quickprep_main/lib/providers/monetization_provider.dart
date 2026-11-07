import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class ClientMonetizationConfig {
  bool adsEnabled;
  String bannerId;
  String interstitialId;
  String rewardedId;
  int interstitialFrequency;
  int proPriceInr;
  String promoBannerText;
  String razorpayKeyId;

  ClientMonetizationConfig({
    this.adsEnabled = true,
    this.bannerId = AppConstants.testBannerIdAndroid,
    this.interstitialId = AppConstants.testInterstitialIdAndroid,
    this.rewardedId = AppConstants.testRewardedIdAndroid,
    this.interstitialFrequency = 2,
    this.proPriceInr = AppConstants.defaultProPriceINR,
    this.promoBannerText = '🚀 Special Launch Deal: Lifetime Pro at ₹199!',
    this.razorpayKeyId = AppConstants.defaultRazorpayKeyId,
  });

  factory ClientMonetizationConfig.fromJson(Map<String, dynamic> json) {
    return ClientMonetizationConfig(
      adsEnabled: json['ads_enabled'] as bool? ?? true,
      bannerId: json['banner_ad_unit_id'] as String? ?? AppConstants.testBannerIdAndroid,
      interstitialId: json['interstitial_ad_unit_id'] as String? ?? AppConstants.testInterstitialIdAndroid,
      rewardedId: json['rewarded_ad_unit_id'] as String? ?? AppConstants.testRewardedIdAndroid,
      interstitialFrequency: json['interstitial_frequency_count'] as int? ?? 2,
      proPriceInr: json['razorpay_pro_price_inr'] as int? ?? AppConstants.defaultProPriceINR,
      promoBannerText: json['promo_banner_text'] as String? ?? '🚀 Special Launch Deal: Lifetime Pro at ₹199!',
      razorpayKeyId: json['razorpay_key_id'] as String? ?? AppConstants.defaultRazorpayKeyId,
    );
  }

  Map<String, dynamic> toJson() => {
        'ads_enabled': adsEnabled,
        'banner_ad_unit_id': bannerId,
        'interstitial_ad_unit_id': interstitialId,
        'rewarded_ad_unit_id': rewardedId,
        'interstitial_frequency_count': interstitialFrequency,
        'razorpay_pro_price_inr': proPriceInr,
        'promo_banner_text': promoBannerText,
        'razorpay_key_id': razorpayKeyId,
      };
}

class MonetizationProvider extends ChangeNotifier {
  ClientMonetizationConfig _config = ClientMonetizationConfig();
  int _actionCounter = 0;

  ClientMonetizationConfig get config => _config;
  bool get adsEnabled => _config.adsEnabled;
  int get proPriceInr => _config.proPriceInr;
  String get promoBannerText => _config.promoBannerText;

  MonetizationProvider() {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if synced from admin or local cache
    final adminJsonStr = prefs.getString('quickprep_admin_monetization');
    if (adminJsonStr != null) {
      try {
        _config = ClientMonetizationConfig.fromJson(jsonDecode(adminJsonStr));
        notifyListeners();
        return;
      } catch (_) {}
    }

    final localJsonStr = prefs.getString('quickprep_client_monetization');
    if (localJsonStr != null) {
      try {
        _config = ClientMonetizationConfig.fromJson(jsonDecode(localJsonStr));
      } catch (_) {}
    }
    notifyListeners();
  }

  bool shouldShowInterstitial() {
    if (!_config.adsEnabled) return false;
    _actionCounter++;
    if (_actionCounter >= _config.interstitialFrequency) {
      _actionCounter = 0;
      return true;
    }
    return false;
  }

  Future<void> syncConfig(ClientMonetizationConfig newConfig) async {
    _config = newConfig;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quickprep_client_monetization', jsonEncode(newConfig.toJson()));
    notifyListeners();
  }
}
