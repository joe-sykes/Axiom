import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/route_names.dart';
import '../../core/providers/core_providers.dart';
import '../../core/widgets/app_footer.dart';

class HelpScreen extends ConsumerWidget {
  final bool isFirstTime;

  const HelpScreen({
    super.key,
    this.isFirstTime = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text('CRYPTIX'),
        ),
        leading: isFirstTime
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
              ),
        actions: [
          if (!isFirstTime) ...[
            Builder(
              builder: (context) {
                final isDark = themeMode == ThemeMode.dark ||
                    (themeMode == ThemeMode.system &&
                        MediaQuery.platformBrightnessOf(context) == Brightness.dark);
                return IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                  tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              onPressed: () => Navigator.of(context).pushNamed(RouteNames.cryptixArchive),
              tooltip: 'Archive',
            ),
          ],
          if (isFirstTime)
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Got it!'),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFirstTime) ...[
                          Center(
                            child: Text(
                              'Welcome to CRYPTIX!',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'A new cryptic clue every day at midnight.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ] else ...[
                          Center(
                            child: Text(
                              'HOW TO PLAY',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // British Cryptic Crossword Rules
                        _SectionHeader(
                          icon: Icons.extension,
                          title: 'CRYPTIC CROSSWORD RULES',
                        ),
                        const SizedBox(height: 16),
                        _RuleCard(
                          title: 'Two Parts',
                          content:
                              'Every cryptic clue has two parts: a straight definition (like a normal crossword) and a cryptic wordplay section. Both lead to the same answer.',
                        ),
                        _RuleCard(
                          title: 'The Definition',
                          content:
                              'The definition is usually at the very beginning or end of the clue. It\'s a synonym or description of the answer.',
                        ),
                        _RuleCard(
                          title: 'Wordplay Types',
                          content: '''Common cryptic wordplay includes:
\u2022 Anagrams - letters rearranged (signalled by words like "mixed", "broken", "wild")
\u2022 Hidden words - answer hidden within the clue text
\u2022 Charades - parts combined to make the answer
\u2022 Reversals - words spelled backwards
\u2022 Double definitions - two meanings of the same word
\u2022 Homophones - words that sound alike''',
                        ),
                        _RuleCard(
                          title: 'Indicator Words',
                          content:
                              'Look for indicator words that signal what type of wordplay is being used. For example, "scrambled" might indicate an anagram, "sounds like" suggests a homophone.',
                        ),
                        _RuleCard(
                          title: 'Punctuation',
                          content:
                              'Ignore punctuation and capitalisation in the clue - they\'re often used to mislead you! Read the clue in different ways.',
                        ),

                        const SizedBox(height: 32),

                        // Scoring Rules
                        _SectionHeader(
                          icon: Icons.emoji_events,
                          title: 'SCORING RULES',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'The daily puzzle is scored. Archive puzzles are not scored but track whether you\'ve solved them.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ScoreItem(
                          icon: Icons.play_arrow,
                          label: 'Starting score',
                          value: '100 points',
                        ),
                        _ScoreItem(
                          icon: Icons.timer,
                          label: 'Grace period',
                          value: '3 minutes (no penalty)',
                        ),
                        _ScoreItem(
                          icon: Icons.trending_down,
                          label: 'After 3 minutes',
                          value: '-5 points every 10 seconds',
                        ),
                        _ScoreItem(
                          icon: Icons.lightbulb_outline,
                          label: 'Show definition hint',
                          value: '-15 points',
                          isNegative: true,
                        ),
                        _ScoreItem(
                          icon: Icons.visibility,
                          label: 'Reveal a letter',
                          value: '-5 points per letter',
                          isNegative: true,
                        ),
                        _ScoreItem(
                          icon: Icons.close,
                          label: 'Incorrect guess',
                          value: '-20 points',
                          isNegative: true,
                        ),

                        const SizedBox(height: 32),

                        // Tips
                        _SectionHeader(
                          icon: Icons.tips_and_updates,
                          title: 'TIPS FOR BEGINNERS',
                        ),
                        const SizedBox(height: 16),
                        _TipCard(
                          number: 1,
                          tip:
                              'Start by identifying the definition - it\'s usually at the start or end of the clue.',
                        ),
                        _TipCard(
                          number: 2,
                          tip:
                              'Look for anagram indicators like "mixed", "strange", "broken", or "wild".',
                        ),
                        _TipCard(
                          number: 3,
                          tip:
                              'Count the letters. The number in brackets tells you the answer length.',
                        ),
                        _TipCard(
                          number: 4,
                          tip:
                              'Use "Show Definition" if stuck - it highlights which part is the definition.',
                        ),
                        _TipCard(
                          number: 5,
                          tip:
                              'Use "Reveal Letter" to get individual letters if you\'re really stuck!',
                        ),
                        _TipCard(
                          number: 6,
                          tip:
                              'Practice makes perfect! The more cryptics you solve, the easier they become.',
                        ),

                        if (isFirstTime) ...[
                          const SizedBox(height: 32),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(true),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Playing'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Navigation links
                        if (!isFirstTime) ...[
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 16),
                          Center(
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  },
                                  icon: const Icon(Icons.home, size: 18),
                                  label: const Text('Home'),
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.of(context).pushNamed(RouteNames.cryptixArchive),
                                  icon: const Icon(Icons.archive_outlined, size: 18),
                                  label: const Text('Archive'),
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.quiz_outlined, size: 18),
                                  label: const Text('Cryptix'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 28, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  final String title;
  final String content;

  const _RuleCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isNegative;

  const _ScoreItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: isNegative
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isNegative ? theme.colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final int number;
  final String tip;

  const _TipCard({
    required this.number,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
