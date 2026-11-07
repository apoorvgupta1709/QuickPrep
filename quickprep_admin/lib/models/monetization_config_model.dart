class MonetizationConfig {
  bool adsEnabled; // AdMob Kill-Switch
  String bannerAdUnitId;
  String interstitialAdUnitId;
  String rewardedAdUnitId;
  int interstitialFrequencyCount; // Show interstitial every X actions
  int razorpayProPriceInr; // Configurable lifetime price
  String razorpayKeyId;
  String promoBannerText;
  DateTime updatedAt;

  MonetizationConfig({
    this.adsEnabled = true,
    this.bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111',
    this.interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712',
    this.rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917',
    this.interstitialFrequencyCount = 3,
    this.razorpayProPriceInr = 199,
    this.razorpayKeyId = 'rzp_test_5678abcdef',
    this.promoBannerText = '🚀 Special Launch Deal: Lifetime Pro at ₹199!',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory MonetizationConfig.fromJson(Map<String, dynamic> json) {
    return MonetizationConfig(
      adsEnabled: json['ads_enabled'] as bool? ?? true,
      bannerAdUnitId: json['banner_ad_unit_id'] as String? ??
          'ca-app-pub-3940256099942544/6300978111',
      interstitialAdUnitId: json['interstitial_ad_unit_id'] as String? ??
          'ca-app-pub-3940256099942544/1033173712',
      rewardedAdUnitId: json['rewarded_ad_unit_id'] as String? ??
          'ca-app-pub-3940256099942544/5224354917',
      interstitialFrequencyCount:
          json['interstitial_frequency_count'] as int? ?? 3,
      razorpayProPriceInr: json['razorpay_pro_price_inr'] as int? ?? 199,
      razorpayKeyId: json['razorpay_key_id'] as String? ?? 'rzp_test_5678abcdef',
      promoBannerText: json['promo_banner_text'] as String? ??
          '🚀 Special Launch Deal: Lifetime Pro at ₹199!',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ads_enabled': adsEnabled,
      'banner_ad_unit_id': bannerAdUnitId,
      'interstitial_ad_unit_id': interstitialAdUnitId,
      'rewarded_ad_unit_id': rewardedAdUnitId,
      'interstitial_frequency_count': interstitialFrequencyCount,
      'razorpay_pro_price_inr': razorpayProPriceInr,
      'razorpay_key_id': razorpayKeyId,
      'promo_banner_text': promoBannerText,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
