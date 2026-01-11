import 'package:flutter/material.dart';

/// Shows the Cryptix help/how-to-play dialog
void showCryptixHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const CryptixHelpDialog(),
  );
}

class CryptixHelpDialog extends StatelessWidget {
  const CryptixHelpDialog({super.key});

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
                    Icons.quiz_outlined,
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
                      icon: Icons.extension,
                      title: 'Cryptic Crossword Rules',
                      content:
                          'Every cryptic clue has two parts: a straight definition '
                          '(like a normal crossword) and a cryptic wordplay section. '
                          'Both lead to the same answer.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.search,
                      title: 'The Definition',
                      content:
                          'The definition is usually at the very beginning or end '
                          'of the clue. It\'s a synonym or description of the answer.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.shuffle,
                      title: 'Wordplay Types',
                      content: '''
• Anagrams - letters rearranged (signalled by "mixed", "broken", "wild")
• Hidden words - answer hidden within the clue text
• Charades - parts combined to make the answer
• Reversals - words spelled backwards
• Double definitions - two meanings of the same word
• Homophones - words that sound alike''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.emoji_events,
                      title: 'Scoring (Out of 100)',
                      content: '''
Base Score: 100 points

Time Penalty:
• First 3 minutes: No penalty
• After 3 minutes: -5 points every 10 seconds

Other Penalties:
• Show definition hint: -15 points
• Reveal a letter: -5 points per letter
• Incorrect guess: -20 points''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: Icons.tips_and_updates,
                      title: 'Tips for Beginners',
                      content: '''
1. Start by identifying the definition - it's usually at the start or end of the clue.

2. Look for anagram indicators like "mixed", "strange", "broken", or "wild".

3. Count the letters. The number in brackets tells you the answer length.

4. Use "Show Definition" if stuck - it highlights which part is the definition.

5. Ignore punctuation - it's often used to mislead you!''',
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
