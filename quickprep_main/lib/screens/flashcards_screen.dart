import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../providers/question_provider.dart';
import '../providers/leitner_provider.dart';
import '../providers/user_gamification_provider.dart';
import '../providers/audio_commute_provider.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/branding_footer.dart';
import '../widgets/admob_banner_widget.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import 'commute_mode_screen.dart';

class FlashcardsScreen extends StatefulWidget {
  final List<Question>? initialQuestions;
  final String? title;

  const FlashcardsScreen({
    super.key,
    this.initialQuestions,
    this.title,
  });

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<Question> _sessionQuestions = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sessionQuestions.isEmpty) {
      if (widget.initialQuestions != null &&
          widget.initialQuestions!.isNotEmpty) {
        _sessionQuestions = List.from(widget.initialQuestions!);
      } else {
        final qp = Provider.of<QuestionProvider>(context, listen: false);
        _sessionQuestions = List.from(qp.filteredQuestions);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onAnswerRated(bool remembered) {
    if (_sessionQuestions.isEmpty) return;

    final currentQ = _sessionQuestions[_currentIndex];
    final leitner = Provider.of<LeitnerProvider>(context, listen: false);
    final gamification =
        Provider.of<UserGamificationProvider>(context, listen: false);

    leitner.rateCard(currentQ.id, remembered);

    if (remembered) {
      gamification.addXp(AppConstants.xpPerFlashcardReview);
    }

    if (_currentIndex < _sessionQuestions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.military_tech, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Deck Completed!'),
          ],
        ),
        content: Text(
          'Great job! You reviewed all ${_sessionQuestions.length} cards in this session. Spaced repetition intervals have been recalculated.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'Flashcards';

    if (_sessionQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Text('No flashcards found for current filter.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              'Card ${_currentIndex + 1} of ${_sessionQuestions.length}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.headphones_outlined),
            tooltip: 'Audio Commute Mode',
            onPressed: () {
              final commute =
                  Provider.of<AudioCommuteProvider>(context, listen: false);
              commute.startPlaylist(_sessionQuestions, startIndex: _currentIndex);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CommuteModeScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _sessionQuestions.length,
              backgroundColor: Colors.transparent,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 3,
            ),

            const SizedBox(height: 8),

            // Flip Card PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _sessionQuestions.length,
                onPageChanged: (idx) {
                  setState(() => _currentIndex = idx);
                },
                itemBuilder: (context, index) {
                  return FlashcardWidget(
                    question: _sessionQuestions[index],
                  );
                },
              ),
            ),

            // Leitner Action Controls
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  // Need Review button (Red)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _onAnswerRated(false),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text(
                        'Need Review',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Mastered button (Emerald)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _onAnswerRated(true),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        'Mastered (+5 XP)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const AdMobBannerWidget(),
            const BrandingFooter(isSubtle: true),
          ],
        ),
      ),
    );
  }
}
