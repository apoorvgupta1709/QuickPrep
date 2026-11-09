import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/question_provider.dart';
import '../providers/leitner_provider.dart';
import '../widgets/branding_footer.dart';
import '../core/theme.dart';
import 'flashcards_screen.dart';

class LeitnerScreen extends StatelessWidget {
  const LeitnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final leitner = Provider.of<LeitnerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allQuestions = questionProvider.allQuestions;
    final dueQuestions = leitner.getDueQuestions(allQuestions);
    final bookmarkedQuestions = questionProvider.bookmarkedQuestions;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spaced Repetition & Bookmarks 🧠'),
          bottom: const TabBar(
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(text: 'Leitner Boxes'),
              Tab(text: 'Bookmarks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Leitner Spaced Repetition Boxes
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Due Cards Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            dueQuestions.isNotEmpty
                                ? AppTheme.primaryDark
                                : AppTheme.success,
                            dueQuestions.isNotEmpty
                                ? AppTheme.primary
                                : Colors.teal,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.alarm,
                                  color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                '${dueQuestions.length} Cards Due for Review',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Reviewing cards at the optimal forgetting curve strengthens neural pathways.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryDark,
                            ),
                            onPressed: dueQuestions.isEmpty
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => FlashcardsScreen(
                                          initialQuestions: dueQuestions,
                                          title: 'Due Leitner Review',
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              dueQuestions.isEmpty
                                  ? 'All Caught Up! 🎉'
                                  : 'Start Due Review',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Leitner Box Progression',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Boxes 1 through 5
                    _buildBoxTile(
                      context,
                      boxNum: 1,
                      title: 'Box 1: Daily Reinforcement',
                      interval: 'Reviewed every 1 day',
                      count: leitner.getCardCountInBox(1, allQuestions),
                      color: Colors.redAccent,
                      isDark: isDark,
                    ),
                    _buildBoxTile(
                      context,
                      boxNum: 2,
                      title: 'Box 2: Emerging Memory',
                      interval: 'Reviewed every 2 days',
                      count: leitner.getCardCountInBox(2, allQuestions),
                      color: Colors.orangeAccent,
                      isDark: isDark,
                    ),
                    _buildBoxTile(
                      context,
                      boxNum: 3,
                      title: 'Box 3: Familiar Concepts',
                      interval: 'Reviewed every 4 days',
                      count: leitner.getCardCountInBox(3, allQuestions),
                      color: Colors.amber,
                      isDark: isDark,
                    ),
                    _buildBoxTile(
                      context,
                      boxNum: 4,
                      title: 'Box 4: Strong Retention',
                      interval: 'Reviewed every 7 days',
                      count: leitner.getCardCountInBox(4, allQuestions),
                      color: Colors.blueAccent,
                      isDark: isDark,
                    ),
                    _buildBoxTile(
                      context,
                      boxNum: 5,
                      title: 'Box 5: Mastered Long-Term',
                      interval: 'Reviewed every 14 days',
                      count: leitner.getCardCountInBox(5, allQuestions),
                      color: AppTheme.success,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // Tab 2: Bookmarked Questions
            bookmarkedQuestions.isEmpty
                ? const Center(
                    child: Text('No bookmarked questions yet.\nTap the bookmark icon on any flashcard to save it here.',
                        textAlign: TextAlign.center),
                  )
                : SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => FlashcardsScreen(
                                      initialQuestions: bookmarkedQuestions,
                                      title: 'Bookmarked Review',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: Text(
                                  'Study All ${bookmarkedQuestions.length} Bookmarks'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: bookmarkedQuestions.length,
                            itemBuilder: (context, idx) {
                              final q = bookmarkedQuestions[idx];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(q.question,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5)),
                                  subtitle: Text(
                                    q.categoryName,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.primaryLight),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.bookmark,
                                        color: Colors.amber),
                                    onPressed: () {
                                      questionProvider.toggleBookmark(q.id);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxTile(
    BuildContext context, {
    required int boxNum,
    required String title,
    required String interval,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.18),
              child: Text(
                '$boxNum',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
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
                    interval,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurfaceElevated : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count cards',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
