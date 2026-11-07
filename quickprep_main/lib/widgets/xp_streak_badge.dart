import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_gamification_provider.dart';
import '../core/theme.dart';

class XpStreakBadge extends StatelessWidget {
  const XpStreakBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = Provider.of<UserGamificationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Daily Streak Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 16,
                color: Colors.deepOrangeAccent,
              ),
              const SizedBox(width: 4),
              Text(
                '${gamification.currentStreak}d',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // XP Score Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.bolt,
                size: 16,
                color: AppTheme.primaryLight,
              ),
              const SizedBox(width: 4),
              Text(
                '${gamification.xpScore} XP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.primaryLight : AppTheme.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
