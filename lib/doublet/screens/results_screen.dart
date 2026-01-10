import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/route_names.dart';
import '../core/constants/ui_constants.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/scoring_utils.dart';
import '../providers/providers.dart';
import '../widgets/stat_item.dart';

class DoubletResultsScreen extends ConsumerWidget {
  const DoubletResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final stats = ref.watch(userStatsProvider);

    if (gameState == null) {
      // No game state, redirect to home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.doublet,
          (route) => route.settings.name == RouteNames.home,
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final puzzleAsync = ref.watch(puzzleProvider(gameState.puzzleIndex));
    final wasSuccessful = gameState.wasSuccessful;
    final score = gameState.finalScore ?? 0;
    final breakdown = ScoringUtils.getBreakdown(
      timeTaken: gameState.elapsedTime,
      incorrectSubmissions: gameState.incorrectSubmissions,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('RESULTS'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                children: [
                  // Result icon
                  Icon(
                    wasSuccessful ? Icons.celebration : Icons.sentiment_dissatisfied,
                    size: 80,
                    color: wasSuccessful ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(height: 16),

                  // Result text
                  Text(
                    wasSuccessful ? 'Congratulations!' : 'Better luck next time!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),

                  // Score card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Score',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$score',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(score),
                                ),
                          ),
                          Text(
                            'out of 100',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Breakdown
                          _BreakdownRow(
                            label: 'Base score',
                            value: '+${breakdown.baseScore}',
                            color: Colors.green,
                          ),
                          if (breakdown.timePenalty > 0)
                            _BreakdownRow(
                              label: 'Time penalty (${breakdown.formattedTime})',
                              value: '-${breakdown.timePenalty}',
                              color: Colors.red,
                            ),
                          if (breakdown.accuracyPenalty > 0)
                            _BreakdownRow(
                              label: 'Mistakes (${breakdown.incorrectSubmissions})',
                              value: '-${breakdown.accuracyPenalty}',
                              color: Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Streak card (only for daily)
                  if (gameState.isDailyPuzzle)
                    Semantics(
                      label: 'Streak statistics',
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StatItem(
                                icon: Icons.local_fire_department,
                                value: '${stats.currentStreak}',
                                label: 'Current Streak',
                                color: Colors.orange,
                                iconSize: 28,
                                valueStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Theme.of(context).dividerColor,
                              ),
                              StatItem(
                                icon: Icons.emoji_events,
                                value: '${stats.longestStreak}',
                                label: 'Best Streak',
                                color: Colors.amber,
                                iconSize: 28,
                                valueStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Solution reveal (if failed)
                  if (!wasSuccessful)
                    puzzleAsync.when(
                      data: (puzzle) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Solution',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              ...puzzle.ladder.map((word) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      word,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            letterSpacing: 4,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  const SizedBox(height: 24),

                  // Share button
                  Semantics(
                    button: true,
                    label: 'Share your result',
                    child: OutlinedButton.icon(
                      onPressed: () => _shareResult(context, gameState, score),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Home button
                  Semantics(
                    button: true,
                    label: 'Go back to home screen',
                    child: FilledButton.icon(
                      onPressed: () {
                        ref.read(gameStateProvider.notifier).clearGame();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteNames.doublet,
                          (route) => route.settings.name == RouteNames.home,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Home'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.amber;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  void _shareResult(BuildContext context, gameState, int score) {
    final puzzleNumber = gameState.isDailyPuzzle
        ? PuzzleDateUtils.getTodaysPuzzleNumber()
        : gameState.puzzleIndex + 1;

    // Dynamic emoji based on score
    final String scoreEmoji;
    final String message;
    if (!gameState.wasSuccessful) {
      scoreEmoji = '\u{1F622}';
      message = 'I gave up...';
    } else if (score == 100) {
      scoreEmoji = '\u{1F3C6}\u2728';
      message = 'PERFECT SCORE!';
    } else if (score >= 90) {
      scoreEmoji = '\u{1F525}\u{1F525}\u{1F525}';
      message = 'On fire!';
    } else if (score >= 80) {
      scoreEmoji = '\u2B50\u2B50';
      message = 'Great job!';
    } else if (score >= 60) {
      scoreEmoji = '\u{1F44D}';
      message = 'Not bad!';
    } else if (score >= 40) {
      scoreEmoji = '\u{1F605}';
      message = 'Room for improvement';
    } else {
      scoreEmoji = '\u{1F422}';
      message = 'Slow and steady...';
    }

    // Create score bar visualization
    final filledBlocks = (score / 10).round();
    final scoreBar = '\u{1F7E9}' * filledBlocks + '\u2B1C' * (10 - filledBlocks);

    final text = '''
Daily Doublet #$puzzleNumber $scoreEmoji

$message

$scoreBar $score/100

https://axiompuzzles.web.app
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
