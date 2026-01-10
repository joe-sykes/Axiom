import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_stats.dart';
import '../services/scoring_service.dart';
import '../../core/theme/axiom_theme.dart';

class CompletionDialog extends StatelessWidget {
  final int score;
  final CryptixUserStats stats;
  final VoidCallback onArchive;
  final VoidCallback onClose;

  const CompletionDialog({
    super.key,
    required this.score,
    required this.stats,
    required this.onArchive,
    required this.onClose,
  });

  bool get _isDesktop {
    // On web, check if it's a desktop browser (not mobile)
    if (kIsWeb) {
      // Web Share API works well on mobile, but not desktop browsers
      // So we use clipboard on web (desktop browsers)
      return true; // Always use clipboard on web for consistency
    }
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  String get _shareMessage {
    final emojis = ScoringService.getScoreEmojis(score);
    return '''
$emojis Cryptix $emojis

Score: $score/100
Streak: ${stats.currentStreak} day${stats.currentStreak == 1 ? '' : 's'}

Play the daily cryptic clue at https://axiompuzzles.web.app
''';
  }

  Future<void> _shareScore(BuildContext context) async {
    final message = _shareMessage;

    // Always copy to clipboard on web
    if (kIsWeb) {
      await Clipboard.setData(ClipboardData(text: message));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // On native mobile apps, use share
    if (_isDesktop) {
      await Clipboard.setData(ClipboardData(text: message));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      await Share.share(message, subject: 'My Cryptix Score');
    }
  }

  Widget _buildScoreIcons(int score) {
    if (score >= 90) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.emoji_events, size: 48, color: Colors.amber),
          SizedBox(width: 8),
          Icon(Icons.star, size: 48, color: Colors.amber),
          SizedBox(width: 8),
          Icon(Icons.auto_awesome, size: 48, color: Colors.amber),
        ],
      );
    }
    if (score >= 75) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.celebration, size: 48, color: Colors.purple),
          SizedBox(width: 8),
          Icon(Icons.celebration, size: 48, color: Colors.purple),
        ],
      );
    }
    if (score >= 60) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.thumb_up, size: 48, color: Colors.blue),
          SizedBox(width: 8),
          Icon(Icons.thumb_up, size: 48, color: Colors.blue),
        ],
      );
    }
    if (score >= 40) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.fitness_center, size: 48, color: Colors.orange),
          SizedBox(width: 8),
          Icon(Icons.sentiment_satisfied, size: 48, color: Colors.orange),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
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
    final message = ScoringService.getScoreMessage(score);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
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
                  value: '${stats.currentStreak}',
                  icon: Icons.local_fire_department,
                ),
                _StatItem(
                  label: 'Best Streak',
                  value: '${stats.bestStreak}',
                  icon: Icons.emoji_events,
                ),
                _StatItem(
                  label: 'Total Solved',
                  value: '${stats.totalSolved}',
                  icon: Icons.check_circle,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action buttons - stacked vertically for mobile
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareScore(context),
                icon: Icon(_isDesktop ? Icons.copy : Icons.share, size: 18),
                label: Text(_isDesktop ? 'Copy Score' : 'Share Score'),
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
