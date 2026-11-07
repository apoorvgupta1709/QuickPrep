import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../providers/question_provider.dart';
import '../providers/audio_commute_provider.dart';
import '../providers/leitner_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      // Reset flip state when question changes
      _isFront = true;
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

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final leitnerProvider = Provider.of<LeitnerProvider>(context);
    final commuteProvider = Provider.of<AudioCommuteProvider>(context);
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
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: _flipCard,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Category Pill + Leitner Box + Action Icons
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
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
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Box $boxNumber',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.volume_up_outlined, size: 20),
                    tooltip: 'Listen Audio',
                    onPressed: onListen,
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 20,
                      color: isBookmarked ? Colors.amber : null,
                    ),
                    tooltip: 'Bookmark',
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
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.black.withOpacity(0.08),
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
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: widget.question.companyTags.map((tag) {
                          return Chip(
                            label: Text(tag,
                                style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: isDark
                                ? AppTheme.darkSurfaceElevated
                                : Colors.grey.shade200,
                          );
                        }).toList(),
                      ),
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
    required VoidCallback onReportIssue,
    required VoidCallback onListen,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppTheme.primary,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: _flipCard,
        borderRadius: BorderRadius.circular(20),
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
                      color: AppTheme.success.withOpacity(0.15),
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
                    icon: const Icon(Icons.volume_up_outlined, size: 20),
                    tooltip: 'Listen Explanation',
                    onPressed: onListen,
                  ),
                  IconButton(
                    icon: const Icon(Icons.flag_outlined,
                        size: 20, color: AppTheme.error),
                    tooltip: 'Report Typo/Issue',
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkSurfaceElevated
                                : Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.black.withOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.lightbulb_outline,
                                      size: 16, color: Colors.amber),
                                  SizedBox(width: 6),
                                  Text(
                                    'Interviewer Deep-Dive Notes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.question.deepDiveExplanation,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'Tap to flip back to question',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
