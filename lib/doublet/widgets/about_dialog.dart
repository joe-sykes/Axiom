import 'package:flutter/material.dart';

/// Shows the about/how-to-play dialog
void showAboutGameDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AboutGameDialog(),
  );
}

class AboutGameDialog extends StatelessWidget {
  const AboutGameDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'How to Play',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
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
                      icon: Icons.flag,
                      title: 'The Goal',
                      content:
                          'Transform the starting word into the ending word by '
                          'changing one letter at a time. Each step must form a '
                          'valid English word from the Scrabble dictionary.',
                    ),
                    const SizedBox(height: 20),
                    _buildExample(context),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.rule,
                      title: 'Rules',
                      content: '''
• Each word must differ by exactly one letter from the previous word
• All words must be valid Scrabble dictionary words
• Words are validated as you type
• Submit your answer when all words are filled in

Note: A green tick means the word is valid in the dictionary, but it may not necessarily be the correct answer for the puzzle.''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.score,
                      title: 'Scoring (Out of 100)',
                      content: '''
Base Score: 100 points

Time Penalty:
• First 3 minutes: No penalty
• After 3 minutes: -5 points every 10 seconds

Accuracy Penalty:
• -5 points per incorrect submission

Minimum score: 0 points''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.today,
                      title: 'Daily Challenge',
                      content:
                          'A new puzzle is released every day at midnight UTC. '
                          'Complete the daily puzzle to build your streak! '
                          'Missing a day will reset your streak to zero.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.archive,
                      title: 'Archive',
                      content:
                          'Play any previous puzzle from the archive at any time. '
                          'Archive puzzles can be replayed for practice, but they '
                          'do not affect your daily streak.',
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
        SelectableText(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb,
                size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Example',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _ExampleWord(word: 'COLD', highlight: null, label: 'Start'),
              _ExampleWord(word: 'CORD', highlight: 2, label: 'Changed L→R'),
              _ExampleWord(word: 'CARD', highlight: 1, label: 'Changed O→A'),
              _ExampleWord(word: 'WARD', highlight: 0, label: 'Changed C→W'),
              _ExampleWord(word: 'WARM', highlight: 3, label: 'End'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExampleWord extends StatelessWidget {
  final String word;
  final int? highlight;
  final String label;

  const _ExampleWord({
    required this.word,
    this.highlight,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ...word.split('').asMap().entries.map((entry) {
            final isHighlighted = entry.key == highlight;
            return Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Center(
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isHighlighted
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
