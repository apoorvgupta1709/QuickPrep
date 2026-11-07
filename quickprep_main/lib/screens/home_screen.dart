import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/question_provider.dart';
import '../providers/user_gamification_provider.dart';
import '../providers/leitner_provider.dart';
import '../widgets/xp_streak_badge.dart';
import '../widgets/branding_footer.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import 'flashcards_screen.dart';
import 'mock_test_screen.dart';
import 'commute_mode_screen.dart';
import 'cheat_sheet_screen.dart';
import 'leitner_screen.dart';
import 'settings_about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final gamification = Provider.of<UserGamificationProvider>(context);
    final leitner = Provider.of<LeitnerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = questionProvider.categories;
    final filteredCount = questionProvider.filteredQuestions.length;
    final dueCount = leitner.getDueQuestions(questionProvider.allQuestions).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.electric_bolt_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppConstants.appName,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ],
        ),
        actions: [
          const XpStreakBadge(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsAboutScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Hot refresh data
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily Streak & Leitner Reminder Banner
                _buildHeroStreakBanner(
                  context,
                  streak: gamification.currentStreak,
                  freezeCount: gamification.streakFreezeCount,
                  dueCardsCount: dueCount,
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  onChanged: (val) => questionProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search questions, algorithms, concepts...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: isDark
                        ? AppTheme.darkSurface
                        : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Company-Specific Filter Chips
                Text(
                  'Company-Specific Interview Packs',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 8),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildCompanyFilterChip(context, 'All', questionProvider),
                      _buildCompanyFilterChip(context, 'FAANG', questionProvider),
                      _buildCompanyFilterChip(context, 'MNC', questionProvider),
                      _buildCompanyFilterChip(context, 'FinTech', questionProvider),
                      _buildCompanyFilterChip(context, 'Startup', questionProvider),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Fast Study Launchpad (Grid of 4 Key Actions)
                Text(
                  'Prep Modes ($filteredCount Questions Available)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    _buildModeCard(
                      context,
                      title: 'Flashcards',
                      subtitle: 'Flip & Spaced Repetition',
                      icon: Icons.style_outlined,
                      color: AppTheme.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FlashcardsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModeCard(
                      context,
                      title: 'Timed Mock Test',
                      subtitle: 'Topic Quizzes & Scoring',
                      icon: Icons.timer_outlined,
                      color: Colors.deepOrange,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MockTestScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModeCard(
                      context,
                      title: 'Commute Audio',
                      subtitle: 'Hands-Free TTS Player',
                      icon: Icons.headphones_outlined,
                      color: Colors.teal,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CommuteModeScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModeCard(
                      context,
                      title: 'Revision PDF',
                      subtitle: '1-Page Cheat Sheets',
                      icon: Icons.picture_as_pdf_outlined,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CheatSheetScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Topics & Categories List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Browse by Topic',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LeitnerScreen(),
                          ),
                        );
                      },
                      child: const Text('Leitner Review 🧠'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                ...categories.map((cat) {
                  final catQuestions =
                      questionProvider.getQuestionsByCategory(cat.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary.withAlpha(30),
                        child: Icon(
                          _getCategoryIcon(cat.icon),
                          color: AppTheme.primaryLight,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        cat.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                      subtitle: Text(
                        cat.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkSurfaceElevated
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${catQuestions.length} Qs',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 20),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FlashcardsScreen(
                              initialQuestions: catQuestions,
                              title: cat.name,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // Signature Branding Footer
                const BrandingFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStreakBanner(
    BuildContext context, {
    required int streak,
    required int freezeCount,
    required int dueCardsCount,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDark,
            AppTheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
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
              const Icon(Icons.local_fire_department,
                  color: Colors.amberAccent, size: 26),
              const SizedBox(width: 8),
              Text(
                '$streak-Day Streak Active!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (freezeCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.ac_unit, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '$freezeCount Freeze',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dueCardsCount > 0
                ? 'You have $dueCardsCount cards waiting in your spaced repetition queue.'
                : 'All caught up on reviews! Practice a timed quiz to earn bonus XP.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyFilterChip(
    BuildContext context,
    String tag,
    QuestionProvider provider,
  ) {
    final isSelected = provider.selectedCompanyFilter == tag;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(
          tag == 'All'
              ? 'All Companies'
              : tag == 'MNC'
                  ? 'MNCs (TCS/Infy)'
                  : tag,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => provider.setCompanyFilter(tag),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 20, color: color),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'account_tree':
        return Icons.account_tree_outlined;
      case 'flutter_dash':
        return Icons.flutter_dash_outlined;
      case 'terminal':
        return Icons.terminal_outlined;
      case 'dns':
        return Icons.dns_outlined;
      case 'storage':
        return Icons.storage_outlined;
      case 'coffee':
        return Icons.coffee_outlined;
      default:
        return Icons.code_outlined;
    }
  }
}
