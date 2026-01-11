import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/axiom_theme.dart';

class FeedbackOverlay extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final VoidCallback onContinue;

  const FeedbackOverlay({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    required this.onContinue,
  });

  static const _correctMessages = [
    'Nice pull.',
    'Fast fingers.',
    'Nailed it.',
    'Sharp.',
    'Clean.',
  ];

  static const _incorrectMessages = [
    'Tough one.',
    'That was sneaky.',
    'Tricky.',
    'Close call.',
    'Next time.',
  ];

  String get _message {
    final random = Random();
    if (isCorrect) {
      return _correctMessages[random.nextInt(_correctMessages.length)];
    }
    return _incorrectMessages[random.nextInt(_incorrectMessages.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = isCorrect
        ? (isDark ? AxiomColors.successDark : AxiomColors.success)
        : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _message,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'Answer: $correctAnswer',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
