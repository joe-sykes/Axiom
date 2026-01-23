import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../../core/widgets/app_footer.dart';
import '../providers/triverse_providers.dart';
import '../widgets/help_dialog.dart';
import '../widgets/results_dialog.dart';

class TriverseHome extends ConsumerStatefulWidget {
  const TriverseHome({super.key});

  @override
  ConsumerState<TriverseHome> createState() => _TriverseHomeState();
}

class _TriverseHomeState extends ConsumerState<TriverseHome> {
  bool _helpDialogShown = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndShowHelp();
    });
  }

  Future<void> _initializeAndShowHelp() async {
    if (!_initialized) {
      _initialized = true;
      await ref.read(triverseGameProvider.notifier).loadPuzzle();
    }

    if (!_helpDialogShown && mounted) {
      final storage = ref.read(triverseStorageProvider);
      final hasSeenHelp = await storage.hasSeenHelp();
      if (!hasSeenHelp && mounted) {
        _helpDialogShown = true;
        showTriverseHelpDialog(context);
        await storage.markHelpAsSeen();
      }
    }
  }

  void _shareScore(int score, int streak) {
    final emojis = score >= 90
        ? '\u{1F3C6}'
        : score >= 75
            ? '\u{2B50}'
            : score >= 50
                ? '\u{1F44D}'
                : '\u{1F4AA}';

    final message = '''
$emojis Triverse $emojis

Score: $score/100
Streak: $streak day${streak == 1 ? '' : 's'}

Play the daily trivia at https://axiom-puzzles.com
''';

    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Score copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showResultsDialog(int score, int streak) {
    showDialog(
      context: context,
      builder: (context) => TriverseResultsDialog(
        score: score,
        correctCount: (score / 14.29).round().clamp(0, 7),
        totalQuestions: 7,
        streak: streak,
        averageTimeSeconds: 0,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final puzzleAsync = ref.watch(triverseTodaysPuzzleProvider);
    final alreadyPlayed = ref.watch(triverseAlreadyPlayedTodayProvider);
    final todaysScore = ref.watch(triverseTodaysScoreProvider);
    final streak = ref.watch(triverseStreakProvider);
    final completedCount = ref.watch(triverseCompletedCountProvider);
    final todayFormatted = DateFormat('d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          ),
          tooltip: 'Back to Axiom',
        ),
        title: GestureDetector(
          onTap: () {
            // Check if already played today
            final played = ref.read(triverseAlreadyPlayedTodayProvider).valueOrNull ?? false;
            if (played) {
              Navigator.pushNamed(context, RouteNames.triverseArchive);
            }
            // If not played, we're already on the home page
          },
          child: MouseRegion(
            cursor: alreadyPlayed.valueOrNull == true
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt),
                SizedBox(width: 8),
                Text('TRIVERSE'),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showTriverseHelpDialog(context),
            tooltip: 'How to play',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.triverseArchive),
            tooltip: 'Archive',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Stats card
                        _StatsCard(
                          streak: streak.valueOrNull ?? 0,
                          played: completedCount.valueOrNull ?? 0,
                        ),
                        const SizedBox(height: 24),

                        // Today's puzzle card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  todayFormatted,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 16),
                                puzzleAsync.when(
                                  data: (puzzle) {
                                    if (puzzle == null) {
                                      return _buildNoPuzzle(context);
                                    }
                                    return Column(
                                      children: [
                                        // Today's Mix categories
                                        Text(
                                          "Today's Mix",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          alignment: WrapAlignment.center,
                                          children: puzzle.categories
                                              .map((cat) =>
                                                  _CategoryChip(category: cat))
                                              .toList(),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '7 questions',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                              ),
                                        ),
                                        const SizedBox(height: 24),
                                        alreadyPlayed.when(
                                          data: (played) {
                                            if (played) {
                                              return _buildCompletedState(
                                                context,
                                                todaysScore.valueOrNull ?? 0,
                                                streak.valueOrNull ?? 0,
                                              );
                                            }
                                            return FilledButton.icon(
                                              onPressed: () {
                                                ref
                                                    .read(triverseGameProvider
                                                        .notifier)
                                                    .startGame();
                                                Navigator.pushNamed(
                                                  context,
                                                  RouteNames.triversePlay,
                                                );
                                              },
                                              icon: const Icon(Icons.play_arrow),
                                              label: const Text('Start'),
                                              style: FilledButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 32,
                                                  vertical: 16,
                                                ),
                                              ),
                                            );
                                          },
                                          loading: () =>
                                              const CircularProgressIndicator(),
                                          error: (e, st) => const Text('Error'),
                                        ),
                                      ],
                                    );
                                  },
                                  loading: () => const Padding(
                                    padding: EdgeInsets.all(32),
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (error, _) => Column(
                                    children: [
                                      const Icon(Icons.cloud_off, size: 48),
                                      const SizedBox(height: 8),
                                      const Text('Unable to load puzzle'),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () => ref
                                            .invalidate(triverseTodaysPuzzleProvider),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPuzzle(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.event_busy,
          size: 48,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 8),
        Text(
          'No puzzle available today',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Check back tomorrow!',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }

  Widget _buildCompletedState(BuildContext context, int score, int streak) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Completed!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Score: $score/100',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (streak > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak day streak',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action buttons
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _shareScore(score, streak),
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Share'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showResultsDialog(score, streak),
              icon: const Icon(Icons.emoji_events, size: 18),
              label: const Text('View Results'),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteNames.triverseArchive),
              icon: const Icon(Icons.history, size: 18),
              label: const Text('View Archive'),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Text(
          'Come back tomorrow for a new challenge!',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int streak;
  final int played;

  const _StatsCard({required this.streak, required this.played});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              icon: Icons.local_fire_department,
              value: '$streak',
              label: 'Streak',
              color: Colors.orange,
            ),
            _StatItem(
              icon: Icons.check_circle,
              value: '$played',
              label: 'Played',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
      ),
    );
  }
}
