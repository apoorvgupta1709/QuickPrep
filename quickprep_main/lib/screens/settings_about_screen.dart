import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_gamification_provider.dart';
import '../providers/monetization_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/razorpay_service.dart';
import '../services/admob_service.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import 'onboarding_profile_screen.dart';

class SettingsAboutScreen extends StatelessWidget {
  const SettingsAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = Provider.of<UserGamificationProvider>(context);
    final monetization = Provider.of<MonetizationProvider>(context);
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final profile = profileProvider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Pro Lifetime Banner
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
                          ? 'You have lifetime ad-free access, unlimited revision downloads, and full company packs.'
                          : monetization.promoBannerText,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
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
                    final restored =
                        await RazorpayService.restorePurchases(gamification);
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

              // 2. Career Track & Personalization
              Text(
                'Personalized Career Track',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withAlpha(35),
                          child: const Icon(Icons.school,
                              color: AppTheme.primaryLight, size: 22),
                        ),
                        title: Text(
                          profile.profession,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${profile.experienceLevel} • ${profile.targetCompanyTier}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const OnboardingProfileScreen(
                                  isEditingFromSettings: true,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Customize Career Track & Goals'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Gamification & Streaks
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
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.cyan, size: 20),
                            tooltip: 'Replenish Streak Freeze (Watch Ad)',
                            onPressed: () {
                              AdMobService.showRewardedAd(
                                isPro: gamification.isPro,
                                config: monetization.config,
                                onUserEarnedReward: (reward) {
                                  gamification.addStreakFreeze(1);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          '❄️ +1 Streak Freeze Added! Your streak is protected.'),
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

              // 4. About QuickPrep (Tech-agnostic)
              Text(
                'About QuickPrep',
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
                        radius: 30,
                        backgroundColor: AppTheme.primary.withAlpha(35),
                        child: const Icon(Icons.electric_bolt_rounded,
                            size: 32, color: AppTheme.primaryLight),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.appTagline,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Engineered with high performance active recall and spaced repetition algorithms to empower candidates to crack technical coding and architectural interviews.',
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

              const SizedBox(height: 36),

              // 5. Signature Attribution: Solely and exclusively on the settings page bottom
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurfaceElevated
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite,
                              color: Colors.redAccent, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            AppConstants.brandingFooter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All Rights Reserved • QuickPrep Suite',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppTheme.darkTextSecondary.withAlpha(120)
                            : AppTheme.lightTextSecondary.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
