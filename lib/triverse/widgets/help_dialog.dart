import 'package:flutter/material.dart';

void showTriverseHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const TriverseHelpDialog(),
  );
}

class TriverseHelpDialog extends StatelessWidget {
  const TriverseHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bolt,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'How to Play',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      icon: Icons.quiz,
                      title: 'Daily Trivia Challenge',
                      content:
                          'Answer 7 multiple-choice questions across 3 categories. '
                          'Everyone gets the same questions each day. One attempt per day.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.timer,
                      title: 'Beat the Clock',
                      content:
                          'Time limits vary by difficulty:\n'
                          '- Quick Fire: 12 seconds\n'
                          '- Think Twice: 15 seconds\n'
                          '- Brain Buster: 20 seconds\n\n'
                          'Answer quickly for bonus points. '
                          'If time runs out, the question is marked wrong.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.looks_two,
                      title: '50/50 Lifeline',
                      content:
                          'Use your one 50/50 lifeline to remove two wrong answers. '
                          'This lifeline is shared across all 7 questions, so use it wisely.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.emoji_events,
                      title: 'Scoring',
                      content: '''
Max score: 100 points

Each question is worth up to ~14 points.

Faster correct answers earn more points.
Slower correct answers earn partial credit.
Wrong answers or timeouts earn 0 points.''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.local_fire_department,
                      title: 'Streaks',
                      content:
                          'Play every day to build your streak. '
                          'Missing a day resets your streak to zero.',
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
