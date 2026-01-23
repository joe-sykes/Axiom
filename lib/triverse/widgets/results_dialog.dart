import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/axiom_theme.dart';

class TriverseResultsDialog extends StatelessWidget {
  final int score;
  final int correctCount;
  final int totalQuestions;
  final int streak;
  final double averageTimeSeconds;
  final VoidCallback onClose;

  const TriverseResultsDialog({
    super.key,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.streak,
    required this.averageTimeSeconds,
    required this.onClose,
  });

  bool get _isDesktop {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  String get _shareMessage {
    final emoji = _getScoreEmoji(score);
    final taunt = _getTaunt(score);
    return '''
$emoji TRIVERSE $emoji

Score: $score/100
$correctCount/$totalQuestions correct
${streak > 1 ? '\u{1F525} $streak day streak!' : ''}

$taunt

\u{1F3AE} https://axiom-puzzles.com/triverse
''';
  }

  String _getScoreEmoji(int score) {
    if (score >= 90) return '\u{1F3C6}'; // Trophy
    if (score >= 75) return '\u{2B50}'; // Star
    if (score >= 50) return '\u{1F4A1}'; // Light bulb
    return '\u{1F9E0}'; // Brain
  }

  String _getTaunt(int score) {
    if (score >= 90) return 'Think you can beat that? \u{1F60F}';
    if (score >= 75) return 'Pretty good... but can you do better? \u{1F914}';
    if (score >= 50) return 'Not bad! Think you can beat me? \u{1F4AA}';
    return 'I dare you to try! \u{1F525}';
  }

  Future<void> _shareScore(BuildContext context) async {
    final message = _shareMessage;

    if (kIsWeb || _isDesktop) {
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
      await Share.share(message, subject: 'My Triverse Score');
    }
  }

  String get _speedFeedback {
    if (averageTimeSeconds <= 3) return 'Lightning fast!';
    if (averageTimeSeconds <= 5) return 'Quick reflexes';
    if (averageTimeSeconds <= 7) return 'Steady pace';
    return 'Taking your time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              // Score icons
              Icon(
                score >= 70 ? Icons.emoji_events : Icons.celebration,
                size: 56,
                color: score >= 70 ? Colors.amber : theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                _getScoreMessage(score),
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
                        color:
                            isDark ? AxiomColors.successDark : AxiomColors.success,
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
                    label: 'Accuracy',
                    value: '$correctCount/$totalQuestions',
                    icon: Icons.gps_fixed,
                  ),
                  _StatItem(
                    label: 'Streak',
                    value: '$streak',
                    icon: Icons.local_fire_department,
                  ),
                  _StatItem(
                    label: 'Speed',
                    value: '${averageTimeSeconds.toStringAsFixed(1)}s',
                    icon: Icons.speed,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _speedFeedback,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _shareScore(context),
                  icon: Icon(_isDesktop ? Icons.copy : Icons.share, size: 18),
                  label: Text(_isDesktop ? 'Copy Score' : 'Share Score'),
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

  String _getScoreMessage(int score) {
    if (score >= 90) return 'Incredible!';
    if (score >= 75) return 'Well done!';
    if (score >= 50) return 'Good effort!';
    if (score >= 25) return 'Keep practicing!';
    return 'Better luck tomorrow!';
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
