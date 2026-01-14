import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

Play the daily cryptogram at https://axiompuzzles.web.app
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

  Widget _buildScoreIcons(int score) {
    if (score >= 90) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 48, color: Colors.amber),
          SizedBox(width: 8),
          Icon(Icons.star, size: 48, color: Colors.amber),
          SizedBox(width: 8),
          Icon(Icons.auto_awesome, size: 48, color: Colors.amber),
        ],
      );
    }
    if (score >= 75) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.celebration, size: 48, color: Colors.purple),
          SizedBox(width: 8),
          Icon(Icons.celebration, size: 48, color: Colors.purple),
        ],
      );
    }
    if (score >= 60) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.thumb_up, size: 48, color: Colors.blue),
          SizedBox(width: 8),
          Icon(Icons.thumb_up, size: 48, color: Colors.blue),
        ],
      );
    }
    if (score >= 40) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center, size: 48, color: Colors.orange),
          SizedBox(width: 8),
          Icon(Icons.sentiment_satisfied, size: 48, color: Colors.orange),
        ],
      );
    }
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.psychology, size: 48, color: Colors.grey),
        SizedBox(width: 8),
        Icon(Icons.menu_book, size: 48, color: Colors.grey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final message = _getScoreMessage(score);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icons
                _buildScoreIcons(score),
                const SizedBox(height: 16),

                // Congratulations message
                Text(
                  message,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AxiomColors.successDark : AxiomColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Score display
                Container(
                  padding: const EdgeInsets.all(16),
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
                        style: theme.textTheme.displayMedium?.copyWith(
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
                const SizedBox(height: 16),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      label: 'Current Streak',
                      value: '$currentStreak',
                      icon: Icons.local_fire_department,
                    ),
                    _StatItem(
                      label: 'Best Streak',
                      value: '$bestStreak',
                      icon: Icons.emoji_events,
                    ),
                    _StatItem(
                      label: 'Total Solved',
                      value: '$totalSolved',
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

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
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
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
