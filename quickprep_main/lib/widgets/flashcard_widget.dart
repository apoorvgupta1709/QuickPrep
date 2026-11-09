import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../providers/question_provider.dart';
import '../providers/audio_commute_provider.dart';
import '../providers/leitner_provider.dart';
import '../providers/user_gamification_provider.dart';
import '../providers/monetization_provider.dart';
import '../services/admob_service.dart';
import '../core/theme.dart';
import 'report_issue_dialog.dart';

class FlashcardWidget extends StatefulWidget {
  final Question question;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const FlashcardWidget({
    super.key,
    required this.question,
    this.onNext,
    this.onPrevious,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _isFront = true;
  bool _isDeepDiveRevealed = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _isFront = true;
      _isDeepDiveRevealed = false;
      _showHint = false;
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
    _isFront = !_isFront;
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard! 📋'),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryDark,
      ),
    );
  }

  Color _getDifficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'easy':
        return const Color(0xFF10B981); // Emerald
      case 'medium':
        return const Color(0xFFF59E0B); // Amber
      case 'hard':
        return const Color(0xFFEF4444); // Red
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final leitnerProvider = Provider.of<LeitnerProvider>(context);
    final commuteProvider = Provider.of<AudioCommuteProvider>(context);
    final gamification = Provider.of<UserGamificationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBookmarked = questionProvider.isBookmarked(widget.question.id);
    final boxNum = leitnerProvider.getBoxForQuestion(widget.question.id);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final isFrontSide = angle <= (pi / 2);

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // 3D Perspective
            ..rotateY(angle),
          alignment: Alignment.center,
          child: isFrontSide
              ? _buildCardFront(
                  context,
                  isDark: isDark,
                  isBookmarked: isBookmarked,
                  boxNumber: boxNum,
                  onBookmark: () =>
                      questionProvider.toggleBookmark(widget.question.id),
                  onListen: () {
                    commuteProvider.startPlaylist([widget.question]);
                  },
                )
              : Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: _buildCardBack(
                    context,
                    isDark: isDark,
                    boxNumber: boxNum,
                    gamification: gamification,
                    leitnerProvider: leitnerProvider,
                    onReportIssue: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            ReportIssueDialog(question: widget.question),
                      );
                    },
                    onListen: () {
                      commuteProvider.startPlaylist([widget.question]);
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCardFront(
    BuildContext context, {
    required bool isDark,
    required bool isBookmarked,
    required int boxNumber,
    required VoidCallback onBookmark,
    required VoidCallback onListen,
  }) {
    final diffColor = _getDifficultyColor(widget.question.difficulty);

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: _flipCard,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Category Pill + Difficulty Pill + Leitner Box + Action Buttons
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.question.categoryName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: diffColor.withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.question.difficulty.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: diffColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Box $boxNumber',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    tooltip: 'Copy Question',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _copyToClipboard(
                        context, widget.question.question, 'Question'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_outlined, size: 19),
                    tooltip: 'Listen Audio',
                    visualDensity: VisualDensity.compact,
                    onPressed: onListen,
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 20,
                      color: isBookmarked ? Colors.amber : null,
                    ),
                    tooltip: 'Bookmark',
                    visualDensity: VisualDensity.compact,
                    onPressed: onBookmark,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Question Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.question.question,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.35,
                            ),
                      ),
                      const SizedBox(height: 14),

                      // Code Snippet Preview (if available)
                      if (widget.question.codeSnippet != null &&
                          widget.question.codeSnippet!.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Code Reference (${widget.question.language ?? "code"}):',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 14),
                              tooltip: 'Copy Code',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _copyToClipboard(
                                context,
                                widget.question.codeSnippet!,
                                'Code Snippet',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: HighlightView(
                            widget.question.codeSnippet!,
                            language: widget.question.language ?? 'dart',
                            theme: isDark ? atomOneDarkTheme : githubTheme,
                            padding: const EdgeInsets.all(12),
                            textStyle: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Company Tags
                      if (widget.question.companyTags.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: widget.question.companyTags.map((tag) {
                            return Chip(
                              avatar: const Icon(Icons.business, size: 12),
                              label: Text(tag,
                                  style: const TextStyle(fontSize: 10.5)),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: isDark
                                  ? AppTheme.darkSurfaceElevated
                                  : Colors.grey.shade200,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Hint / Clue Expander
                      if (widget.question.deepDiveExplanation.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () {
                            setState(() => _showHint = !_showHint);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.amber.withAlpha(60)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb_outline,
                                    size: 16, color: Colors.amber),
                                const SizedBox(width: 6),
                                Text(
                                  _showHint
                                      ? 'Hide Interview Hint'
                                      : '💡 Need a Hint? (Tap here)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_showHint) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkSurfaceElevated
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Focus on core trade-offs, time complexity, and internal memory/thread mechanics.',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Flip Prompt
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 16,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap card to reveal answer & explanation',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(
    BuildContext context, {
    required bool isDark,
    required int boxNumber,
    required UserGamificationProvider gamification,
    required LeitnerProvider leitnerProvider,
    required VoidCallback onReportIssue,
    required VoidCallback onListen,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(
          color: AppTheme.primary,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: _flipCard,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ANSWER EXPLANATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    tooltip: 'Copy Answer',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _copyToClipboard(
                        context, widget.question.answer, 'Answer'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_outlined, size: 19),
                    tooltip: 'Listen Explanation',
                    visualDensity: VisualDensity.compact,
                    onPressed: onListen,
                  ),
                  IconButton(
                    icon: const Icon(Icons.flag_outlined,
                        size: 19, color: AppTheme.error),
                    tooltip: 'Report Typo/Issue',
                    visualDensity: VisualDensity.compact,
                    onPressed: onReportIssue,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Answer Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.question.answer,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 16),

                      if (widget.question.deepDiveExplanation.isNotEmpty) ...[
                        Builder(
                          builder: (ctx) {
                            final monetization =
                                Provider.of<MonetizationProvider>(ctx);
                            final canView =
                                gamification.isPro || _isDeepDiveRevealed;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkSurfaceElevated
                                    : Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isDark ? Colors.white10 : Colors.black12,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.lightbulb_outline,
                                          size: 16, color: Colors.amber),
                                      const SizedBox(width: 6),
                                      Text(
                                        canView
                                            ? 'Interviewer Deep-Dive Notes'
                                            : 'Interviewer Deep-Dive (Locked)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (canView)
                                    Text(
                                      widget.question.deepDiveExplanation,
                                      style: const TextStyle(
                                          fontSize: 12.5, height: 1.35),
                                    )
                                  else ...[
                                    const Text(
                                      'Unlock advanced interview edge cases and system design trade-offs by watching a sponsored video or getting Pro.',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        backgroundColor: Colors.amber.shade700,
                                      ),
                                      onPressed: () {
                                        AdMobService.showRewardedAd(
                                          isPro: gamification.isPro,
                                          config: monetization.config,
                                          onUserEarnedReward: (reward) {
                                            setState(() =>
                                                _isDeepDiveRevealed = true);
                                          },
                                          onFailedOrUnavailable: () {
                                            setState(() =>
                                                _isDeepDiveRevealed = true);
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.lock_open,
                                          size: 14),
                                      label: const Text(
                                          'Watch Ad to Reveal Notes',
                                          style: TextStyle(fontSize: 11)),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Active Recall Rating Bar: Spaced Repetition Feedback
              Text(
                'How well did you know this? (Spaced Repetition)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        leitnerProvider.rateCard(widget.question.id, false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Card reset to Box 1 for rapid review. 🔄'),
                            duration: Duration(milliseconds: 1200),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        if (widget.onNext != null) widget.onNext!();
                      },
                      child: const Text('🔴 Again',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        leitnerProvider.rateCard(widget.question.id, true);
                        gamification.addXp(10);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Mastered! +10 XP • Moved to next Leitner Box 🎉'),
                            backgroundColor: AppTheme.success,
                            duration: Duration(milliseconds: 1200),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        if (widget.onNext != null) widget.onNext!();
                      },
                      child: const Text('🟢 Mastered (+10 XP)',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
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
}
