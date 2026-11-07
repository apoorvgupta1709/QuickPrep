import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_gamification_provider.dart';
import '../providers/monetization_provider.dart';
import '../services/razorpay_service.dart';
import '../services/admob_service.dart';
import '../widgets/branding_footer.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class SettingsAboutScreen extends StatelessWidget {
  const SettingsAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = Provider.of<UserGamificationProvider>(context);
    final monetization = Provider.of<MonetizationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & About'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pro Lifetime Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF9333EA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium,
                            color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          gamification.isPro
                              ? 'QuickPrep Pro (Active)'
                              : 'Upgrade to QuickPrep Pro',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gamification.isPro
                          ? 'You have lifetime ad-free access, unlimited PDF downloads, and full company packs.'
                          : monetization.promoBannerText,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    if (!gamification.isPro)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6366F1),
                        ),
                        onPressed: () {
                          RazorpayService(context, gamification).openCheckout(
                            amountInr: monetization.proPriceInr,
                            razorpayKeyId: monetization.config.razorpayKeyId,
                          );
                        },
                        child: Text(
                          'Unlock for ₹${monetization.proPriceInr} (Lifetime)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Restore Purchases Button
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final restored = await RazorpayService.restorePurchases(gamification);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            restored
                                ? 'QuickPrep Pro License restored successfully! 🎉'
                                : 'No prior Pro purchases found on this device.',
                          ),
                          backgroundColor:
                              restored ? AppTheme.success : Colors.blueGrey,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.restore, size: 16),
                  label: const Text('Restore Purchases'),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Gamification & Streaks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.local_fire_department,
                          color: Colors.deepOrangeAccent),
                      title: const Text('Current Daily Streak'),
                      trailing: Text(
                        '${gamification.currentStreak} Days',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.ac_unit, color: Colors.cyan),
                      title: const Text('Streak Freezes Available'),
                      subtitle: const Text('Protects streak if you miss a day'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${gamification.streakFreezeCount}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.cyan, size: 20),
                            tooltip: 'Replenish Streak Freeze (Watch Ad)',
                            onPressed: () {
                              AdMobService.showRewardedAd(
                                isPro: gamification.isPro,
                                config: monetization.config,
                                onUserEarnedReward: (reward) {
                                  gamification.addStreakFreeze(1);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('❄️ +1 Streak Freeze Added! Your streak is protected.'),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
                                },
                                onFailedOrUnavailable: () {
                                  gamification.addStreakFreeze(1);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.bolt, color: Colors.amber),
                      title: const Text('Total XP Earned'),
                      trailing: Text(
                        '${gamification.xpScore} XP',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'About the Developer',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.primary.withAlpha(45),
                        child: const Icon(Icons.person,
                            size: 36, color: AppTheme.primaryLight),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Apoorv Gupta',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Software Architect & App Creator',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          AppConstants.authorAttribution,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Built with Flutter 3, Firebase, and high performance spaced repetition to help developers crack technical coding interviews with confidence.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Permanent Signature Attribution
              const BrandingFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
