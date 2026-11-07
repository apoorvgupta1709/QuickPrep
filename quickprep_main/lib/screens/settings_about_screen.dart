import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_gamification_provider.dart';
import '../widgets/branding_footer.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class SettingsAboutScreen extends StatelessWidget {
  const SettingsAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = Provider.of<UserGamificationProvider>(context);
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
                          : 'Unlock 100% Ad-Free experience, unlimited PDF revision cheat sheets, and full company interview packs.',
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
                          _showProUpgradeDialog(context);
                        },
                        child: const Text('Unlock for ₹199 (Lifetime)'),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
                      trailing: Text(
                        '${gamification.streakFreezeCount}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
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
                        backgroundColor: AppTheme.primary.withOpacity(0.18),
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
                          color: Colors.red.withOpacity(0.1),
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

  void _showProUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text('QuickPrep Pro'),
          ],
        ),
        content: const Text(
          'In Phase 4, the Razorpay integration will process live checkout for ₹199.\n\nWould you like to activate Pro mode for testing now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<UserGamificationProvider>(context, listen: false)
                  .setProStatus(true);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('QuickPrep Pro Lifetime Activated! 🎉'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text('Activate Pro Mode'),
          ),
        ],
      ),
    );
  }
}
