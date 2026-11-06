class AppConstants {
  static const String appName = 'QuickPrep';
  static const String appTagline = 'Master Tech & Coding Interviews';
  static const String appVersion = '1.0.0';
  static const String authorAttribution = 'Made with ❤️ by Apoorv';
  static const String brandingFooter = 'v$appVersion • $authorAttribution';

  // AdMob Official Google Test IDs (Used in debug/development mode)
  static const String testBannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedIdAndroid = 'ca-app-pub-3940256099942544/5224354917';

  static const String testBannerIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String testInterstitialIdIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String testRewardedIdIOS = 'ca-app-pub-3940256099942544/1712485313';

  // Razorpay Defaults (Configurable dynamically from Firestore / Admin)
  static const int defaultProPriceINR = 199;
  static const String defaultRazorpayKeyId = 'rzp_test_placeholder'; // Replaced dynamically or via admin

  // Gamification & Leitner Constants
  static const int xpPerFlashcardReview = 5;
  static const int xpPerQuizCorrect = 15;
  static const int xpDailyStreakBonus = 50;
  static const int xpQuizComplete = 100;

  static const int maxLeitnerBox = 5;
}
