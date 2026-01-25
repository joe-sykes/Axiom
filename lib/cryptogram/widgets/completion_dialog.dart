import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../core/services/analytics_service.dart';
import '../../core/theme/axiom_theme.dart';

class CryptogramCompletionDialog extends StatelessWidget {
  final int score;
  final int currentStreak;
  final int bestStreak;
  final int totalSolved;
  final VoidCallback onArchive;
  final VoidCallback onClose;

  const CryptogramCompletionDialog({
    super.key,
    required this.score,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalSolved,
    required this.onArchive,
    required this.onClose,
  });

  String get _shareMessage {
    final emojis = score >= 90 ? '🏆🔐✨' : score >= 70 ? '🎉🔓' : score >= 50 ? '👏🔑' : '💪📝';
    return '''
$emojis Cryptogram $emojis

Score: $score/100
Streak: $currentStreak day${currentStreak == 1 ? '' : 's'}

Play the daily cryptogram at https://axiom-puzzles.com
''';
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return 'Brilliant!';
    if (score >= 75) return 'Excellent!';
    if (score >= 60) return 'Well Done!';
    if (score >= 40) return 'Good Job!';
    return 'Solved!';
  }

  Future<void> _shareScore(BuildContext context) async {
    // Track share event
    AnalyticsService.trackShare(GameNames.cryptogram);

    await Clipboard.setData(ClipboardData(text: _shareMessage));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Score copied to clipboard!'),
          backgroundColor: AxiomColors.cyan,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildScoreIcons(int score, bool isCompact) {
    final iconSize = isCompact ? 36.0 : 48.0;
    final spacing = isCompact ? 6.0 : 8.0;

    if (score >= 90) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: iconSize, color: Colors.amber),
          SizedBox(width: spacing),
          Icon(Icons.star, size: iconSize, color: Colors.amber),
          SizedBox(width: spacing),
          Icon(Icons.auto_awesome, size: iconSize, color: Colors.amber),
        ],
      );
    }
    if (score >= 75) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.celebration, size: iconSize, color: Colors.purple),
          SizedBox(width: spacing),
          Icon(Icons.celebration, size: iconSize, color: Colors.purple),
        ],
      );
    }
    if (score >= 60) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.thumb_up, size: iconSize, color: Colors.blue),
          SizedBox(width: spacing),
          Icon(Icons.thumb_up, size: iconSize, color: Colors.blue),
        ],
      );
    }
    if (score >= 40) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center, size: iconSize, color: Colors.orange),
          SizedBox(width: spacing),
          Icon(Icons.sentiment_satisfied, size: iconSize, color: Colors.orange),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.psychology, size: iconSize, color: Colors.grey),
        SizedBox(width: spacing),
        Icon(Icons.menu_book, size: iconSize, color: Colors.grey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final message = _getScoreMessage(score);
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 700;
    final showConfetti = score >= 60;

    return Stack(
      children: [
        Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400, maxHeight: screenHeight * 0.85),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icons
                _buildScoreIcons(score, isCompact),
                SizedBox(height: isCompact ? 12 : 16),

                // Congratulations message
                Text(
                  message,
                  style: (isCompact ? theme.textTheme.titleLarge : theme.textTheme.headlineMedium)?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AxiomColors.successDark : AxiomColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isCompact ? 16 : 24),

                // Score display
                Container(
                  padding: EdgeInsets.all(isCompact ? 12 : 16),
                  decoration: BoxDecoration(
                    color: (isDark ? AxiomColors.successDark : AxiomColors.success)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Score',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$score',
                        style: (isCompact ? theme.textTheme.displaySmall : theme.textTheme.displayMedium)?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AxiomColors.successDark : AxiomColors.success,
                        ),
                      ),
                      Text(
                        'out of 100',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isCompact ? 12 : 16),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      label: 'Streak',
                      value: '$currentStreak',
                      icon: Icons.local_fire_department,
                      isCompact: isCompact,
                    ),
                    _StatItem(
                      label: 'Best',
                      value: '$bestStreak',
                      icon: Icons.emoji_events,
                      isCompact: isCompact,
                    ),
                    _StatItem(
                      label: 'Solved',
                      value: '$totalSolved',
                      icon: Icons.check_circle,
                      isCompact: isCompact,
                    ),
                  ],
                ),
                SizedBox(height: isCompact ? 16 : 24),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareScore(context),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy Score'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onArchive();
                    },
                    icon: const Icon(Icons.archive, size: 18),
                    label: const Text('View Archive'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onClose();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
        ),
        if (showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/confetti_success.json',
                repeat: false,
                fit: BoxFit.cover,
                frameRate: const FrameRate(60),
                renderCache: RenderCache.raster,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isCompact;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: isCompact ? 20 : 24,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: isCompact ? 2 : 4),
        Text(
          value,
          style: (isCompact ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
