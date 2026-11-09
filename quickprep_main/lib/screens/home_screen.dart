import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/question_provider.dart';
import '../providers/user_gamification_provider.dart';
import '../providers/leitner_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/xp_streak_badge.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import 'flashcards_screen.dart';
import 'mock_test_screen.dart';
import 'commute_mode_screen.dart';
import 'cheat_sheet_screen.dart';
import 'leitner_screen.dart';
import 'settings_about_screen.dart';
import 'onboarding_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final gamification = Provider.of<UserGamificationProvider>(context);
    final leitner = Provider.of<LeitnerProvider>(context);
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allCategories = questionProvider.categories;
    final displayedCategories =
        profileProvider.filterCategories(allCategories);
    final displayedQuestions =
        profileProvider.filterQuestions(questionProvider.filteredQuestions);
    final filteredCount = displayedQuestions.length;
    final dueCount =
        leitner.getDueQuestions(questionProvider.allQuestions).length;

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
            const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ],
        ),
        actions: [
          const XpStreakBadge(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings & Career Track',
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Personalized Career Track Card
                _buildCareerTrackCard(context, profileProvider, isDark),

                const SizedBox(height: 14),

                // 2. Daily Streak & Leitner Reminder Banner
                _buildHeroStreakBanner(
                  context,
                  streak: gamification.currentStreak,
                  freezeCount: gamification.streakFreezeCount,
                  dueCardsCount: dueCount,
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // 3. Search Bar
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

                // 4. Personalized Filter Segmented Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prep Topics',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Row(
                      children: [
                        ChoiceChip(
                          avatar: const Icon(Icons.filter_list, size: 14),
                          label: Text(
                            profileProvider.filterByTrackOnly
                                ? '${profileProvider.profile.profession} (Filtered)'
                                : 'All Topics',
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: profileProvider.filterByTrackOnly,
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: profileProvider.filterByTrackOnly
                                ? Colors.white
                                : null,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            profileProvider.toggleFilterByTrack(val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Company-Specific Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildCompanyFilterChip(context, 'All', questionProvider),
                      _buildCompanyFilterChip(
                          context, 'FAANG', questionProvider),
                      _buildCompanyFilterChip(context, 'MNC', questionProvider),
                      _buildCompanyFilterChip(
                          context, 'FinTech', questionProvider),
                      _buildCompanyFilterChip(
                          context, 'Startup', questionProvider),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Prep Modes Grid
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
                      subtitle: 'Active Recall & Spaced Review',
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
                      subtitle: 'Hands-Free Audio Player',
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
                      title: 'Revision Sheet',
                      subtitle: 'Printable Summaries',
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

                const SizedBox(height: 24),

                // Topics Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      profileProvider.filterByTrackOnly
                          ? 'Recommended for ${profileProvider.profile.profession}'
                          : 'All Interview Topics',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (questionProvider.selectedCategoryId != null)
                      TextButton(
                        onPressed: () =>
                            questionProvider.selectCategory(null),
                        child: const Text('Show All',
                            style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final cat = displayedCategories[index];
                    final isSelected =
                        questionProvider.selectedCategoryId == cat.id;

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark ? Colors.white12 : Colors.black12),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppTheme.primary.withAlpha(35),
                          child: Icon(
                            _getCategoryIcon(cat.icon),
                            color: AppTheme.primaryLight,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          cat.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppTheme.primaryLight : null,
                          ),
                        ),
                        subtitle: Text(
                          cat.description,
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${cat.questionCount} Qs',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                        onTap: () {
                          questionProvider.selectCategory(
                            isSelected ? null : cat.id,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const FlashcardsScreen(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCareerTrackCard(
    BuildContext context,
    UserProfileProvider profileProvider,
    bool isDark,
  ) {
    final profile = profileProvider.profile;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withAlpha(60),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: AppTheme.primaryLight, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.profession,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.experienceLevel} • ${profile.targetCompanyTier}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: AppTheme.primaryLight,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const OnboardingProfileScreen(isEditingFromSettings: true),
                ),
              );
            },
            child: const Text('Change',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE0E7FF),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department,
                    color: Colors.deepOrange, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streak Day Practice Streak! 🔥',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      freezeCount > 0
                          ? '$freezeCount streak freeze active • Streak protected'
                          : 'Review today to keep your streak alive',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.style, color: Colors.amber),
                tooltip: 'Spaced Repetition Deck',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LeitnerScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          if (dueCardsCount > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm, size: 14, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    '$dueCardsCount cards due for spaced review today',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LeitnerScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Review Now →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyFilterChip(
      BuildContext context, String company, QuestionProvider provider) {
    final isSelected = provider.selectedCompanyFilter == company;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(company),
        selected: isSelected,
        onSelected: (_) => provider.setCompanyFilter(company),
        selectedColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
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

    return Material(
      color: isDark ? AppTheme.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'code':
        return Icons.code;
      case 'terminal':
        return Icons.terminal;
      case 'dns':
        return Icons.dns;
      case 'storage':
        return Icons.storage;
      case 'coffee':
        return Icons.coffee;
      case 'smartphone':
        return Icons.phone_android;
      default:
        return Icons.menu_book;
    }
  }
}
