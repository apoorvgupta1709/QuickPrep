import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../providers/question_provider.dart';
import '../providers/user_gamification_provider.dart';
import '../providers/monetization_provider.dart';
import '../services/admob_service.dart';
import '../widgets/branding_footer.dart';
import '../widgets/admob_banner_widget.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class MockTestScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const MockTestScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<MockTestScreen> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  List<Question> _quizQuestions = [];
  int _currentIndex = 0;
  int _selectedOption = -1;
  bool _hasAnsweredCurrent = false;

  int _score = 0;
  int _secondsRemaining = 45; // 45s countdown per question
  Timer? _countdownTimer;
  int _totalTimeElapsed = 0;

  final List<QuizQuestionReview> _reviews = [];
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  void _initQuiz() {
    final qp = Provider.of<QuestionProvider>(context, listen: false);
    List<Question> pool;
    if (widget.categoryId != null) {
      pool = qp.getQuestionsByCategory(widget.categoryId!);
    } else {
      pool = qp.filteredQuestions;
    }

    // Shuffle and pick up to 10 questions for a quick timed mock test
    _quizQuestions = List.from(pool)..shuffle();
    if (_quizQuestions.length > 10) {
      _quizQuestions = _quizQuestions.sublist(0, 10);
    }

    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _secondsRemaining = 45;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _totalTimeElapsed++;
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          // Time expired for this question, auto submit as incorrect
          _submitAnswer(-1);
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _submitAnswer(int optionIndex) {
    if (_hasAnsweredCurrent) return;

    _countdownTimer?.cancel();
    _selectedOption = optionIndex;
    _hasAnsweredCurrent = true;

    final currentQ = _quizQuestions[_currentIndex];
    final isCorrect = optionIndex == currentQ.correctOptionIndex;

    if (isCorrect) {
      _score++;
    }

    final userAnsText = optionIndex >= 0 && optionIndex < currentQ.quizOptions.length
        ? currentQ.quizOptions[optionIndex]
        : 'Time Out (No Answer)';

    final correctAnsText = currentQ.correctOptionIndex < currentQ.quizOptions.length
        ? currentQ.quizOptions[currentQ.correctOptionIndex]
        : currentQ.answer;

    _reviews.add(
      QuizQuestionReview(
        question: currentQ.question,
        userAnswer: userAnsText,
        correctAnswer: correctAnsText,
        isCorrect: isCorrect,
        codeSnippet: currentQ.codeSnippet,
        explanation: currentQ.deepDiveExplanation.isNotEmpty
            ? currentQ.deepDiveExplanation
            : currentQ.answer,
      ),
    );

    setState(() {});
  }

  void _nextQuestion() {
    if (_currentIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = -1;
        _hasAnsweredCurrent = false;
      });
      _startQuestionTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _countdownTimer?.cancel();
    final gamification =
        Provider.of<UserGamificationProvider>(context, listen: false);

    // Calculate XP: 15 XP per correct + 100 XP completion bonus
    final earnedXp = (_score * AppConstants.xpPerQuizCorrect) +
        AppConstants.xpQuizComplete;
    gamification.addXp(earnedXp);

    final monetization =
        Provider.of<MonetizationProvider>(context, listen: false);

    if (monetization.shouldShowInterstitial()) {
      AdMobService.showInterstitial(
        isPro: gamification.isPro,
        config: monetization.config,
      );
    }

    setState(() {
      _quizCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.categoryName ?? 'Timed Mock Test';

    if (_quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Text('Not enough questions available for this quiz.'),
        ),
      );
    }

    if (_quizCompleted) {
      return _buildResultsScreen(context);
    }

    final currentQ = _quizQuestions[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              'Question ${_currentIndex + 1} of ${_quizQuestions.length}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          // Timer Widget
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 18,
                  color: _secondsRemaining <= 10
                      ? AppTheme.error
                      : AppTheme.primaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_secondsRemaining}s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _secondsRemaining <= 10
                        ? AppTheme.error
                        : AppTheme.primaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer progress bar
            LinearProgressIndicator(
              value: _secondsRemaining / 45,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                _secondsRemaining <= 10 ? AppTheme.error : AppTheme.primary,
              ),
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Text(
                      currentQ.question,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 20),

                    // Options list
                    ...List.generate(currentQ.quizOptions.length, (idx) {
                      final optionText = currentQ.quizOptions[idx];
                      final isSelected = _selectedOption == idx;
                      final isCorrect = idx == currentQ.correctOptionIndex;

                      Color borderColor = isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0);
                      Color bgColor = Colors.transparent;

                      if (_hasAnsweredCurrent) {
                        if (isCorrect) {
                          borderColor = AppTheme.success;
                          bgColor = AppTheme.success.withOpacity(0.12);
                        } else if (isSelected) {
                          borderColor = AppTheme.error;
                          bgColor = AppTheme.error.withOpacity(0.12);
                        }
                      } else if (isSelected) {
                        borderColor = AppTheme.primary;
                        bgColor = AppTheme.primary.withOpacity(0.1);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: _hasAnsweredCurrent
                              ? null
                              : () => _submitAnswer(idx),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: borderColor.withOpacity(0.2),
                                  child: Text(
                                    String.fromCharCode(65 + idx), // A, B, C, D
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (_hasAnsweredCurrent && isCorrect)
                                  const Icon(Icons.check_circle,
                                      color: AppTheme.success, size: 20)
                                else if (_hasAnsweredCurrent && isSelected)
                                  const Icon(Icons.cancel,
                                      color: AppTheme.error, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    if (_hasAnsweredCurrent) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSurfaceElevated
                              : Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Explanation: ${currentQ.answer}',
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_hasAnsweredCurrent)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(
                      _currentIndex < _quizQuestions.length - 1
                          ? 'Next Question'
                          : 'View Test Results',
                    ),
                  ),
                ),
              ),

            const AdMobBannerWidget(),
            const BrandingFooter(isSubtle: true),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accuracy = (_score / _quizQuestions.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analysis'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Score Circle Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryDark,
                      AppTheme.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      '${accuracy.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_score out of ${_quizQuestions.length} Correct',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _metricBadge(
                          icon: Icons.bolt,
                          label:
                              '+${(_score * AppConstants.xpPerQuizCorrect) + AppConstants.xpQuizComplete} XP',
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 12),
                        _metricBadge(
                          icon: Icons.schedule,
                          label: '${_totalTimeElapsed}s Spent',
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detailed Question Review',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              // Breakdown of each question
              ..._reviews.map((r) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              r.isCorrect ? Icons.check_circle : Icons.cancel,
                              color: r.isCorrect
                                  ? AppTheme.success
                                  : AppTheme.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                r.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Answer: ${r.userAnswer}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: r.isCorrect ? AppTheme.success : AppTheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!r.isCorrect) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Correct Answer: ${r.correctAnswer}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (r.explanation != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Why: ${r.explanation}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Dashboard'),
                ),
              ),

              const BrandingFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
