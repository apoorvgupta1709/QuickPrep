import 'package:flutter/foundation.dart';
import '../models/monetization_config_model.dart';
import '../services/admin_storage_service.dart';

class AdminMonetizationProvider extends ChangeNotifier {
  MonetizationConfig _config = MonetizationConfig();
  bool _isSaving = false;

  MonetizationConfig get config => _config;
  bool get isSaving => _isSaving;

  AdminMonetizationProvider() {
    _init();
  }

  Future<void> _init() async {
    _config = await AdminStorageService.loadMonetizationConfig();
    notifyListeners();
  }

  Future<void> toggleAds(bool enabled) async {
    _config.adsEnabled = enabled;
    await _persist();
  }

  Future<void> updateAdUnits({
    required String bannerId,
    required String interstitialId,
    required String rewardedId,
    required int frequency,
  }) async {
    _config.bannerAdUnitId = bannerId;
    _config.interstitialAdUnitId = interstitialId;
    _config.rewardedAdUnitId = rewardedId;
    _config.interstitialFrequencyCount = frequency;
    await _persist();
  }

  Future<void> updateRazorpayConfig({
    required int priceInr,
    required String keyId,
    required String promoText,
  }) async {
    _config.razorpayProPriceInr = priceInr;
    _config.razorpayKeyId = keyId;
    _config.promoBannerText = promoText;
    await _persist();
  }

  Future<void> _persist() async {
    _isSaving = true;
    notifyListeners();
    await AdminStorageService.saveMonetizationConfig(_config);
    _isSaving = false;
    notifyListeners();
  }
}
