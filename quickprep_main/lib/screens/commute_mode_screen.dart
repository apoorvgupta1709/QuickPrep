import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_commute_provider.dart';
import '../widgets/branding_footer.dart';
import '../core/theme.dart';

class CommuteModeScreen extends StatelessWidget {
  const CommuteModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final commute = Provider.of<AudioCommuteProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentQ = commute.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Commute Mode 🎧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              commute.stop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              // Top Commute Status Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: commute.isPlaying
                      ? AppTheme.success.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: commute.isPlaying
                        ? AppTheme.success
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      commute.isPlaying
                          ? Icons.volume_up
                          : Icons.volume_off,
                      size: 16,
                      color: commute.isPlaying
                          ? AppTheme.success
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      !commute.isPlaying
                          ? 'Paused'
                          : commute.isSpeakingAnswer
                              ? 'Speaking: Answer'
                              : 'Speaking: Question',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: commute.isPlaying
                            ? AppTheme.success
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Playlist Progress Indicator
              if (commute.playlist.isNotEmpty)
                Text(
                  'Question ${commute.currentIndex + 1} of ${commute.playlist.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                ),

              const SizedBox(height: 16),

              // Card Text Display Box
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurface
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: currentQ == null
                      ? const Center(child: Text('No question loaded'))
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentQ.categoryName.toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.primaryLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                currentQ.question,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: !commute.isSpeakingAnswer &&
                                          commute.isPlaying
                                      ? AppTheme.primaryLight
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 12),
                              Text(
                                currentQ.answer,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: commute.isSpeakingAnswer &&
                                          commute.isPlaying
                                      ? (isDark
                                          ? Colors.white
                                          : Colors.black)
                                      : (isDark
                                          ? AppTheme.darkTextSecondary
                                          : AppTheme.lightTextSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Speed Control Slider
              Row(
                children: [
                  const Text('Speed: ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: commute.playbackRate,
                      min: 0.3,
                      max: 0.8,
                      divisions: 5,
                      label: '${(commute.playbackRate * 2).toStringAsFixed(1)}x',
                      onChanged: (val) => commute.setPlaybackRate(val),
                    ),
                  ),
                  Text(
                    '${(commute.playbackRate * 2).toStringAsFixed(1)}x',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Big Player Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: commute.currentIndex > 0
                        ? () => commute.previous()
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      iconSize: 48,
                      color: Colors.white,
                      icon: Icon(
                        commute.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      onPressed: () {
                        if (commute.isPlaying) {
                          commute.pause();
                        } else {
                          commute.resume();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: commute.currentIndex < commute.playlist.length - 1
                        ? () => commute.next()
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const BrandingFooter(isSubtle: true),
            ],
          ),
        ),
      ),
    );
  }
}
