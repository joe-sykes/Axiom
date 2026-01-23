import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../../core/widgets/app_footer.dart';
import '../core/constants/ui_constants.dart';
import '../core/utils/date_utils.dart';
import '../providers/providers.dart';
import '../widgets/about_dialog.dart';
import '../widgets/doublet_app_bar.dart';
import '../widgets/stats_card.dart';

class DoubletHome extends ConsumerStatefulWidget {
  const DoubletHome({super.key});

  @override
  ConsumerState<DoubletHome> createState() => _DoubletHomeState();
}

class _DoubletHomeState extends ConsumerState<DoubletHome> {
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
    // First initialize services
    if (!_initialized) {
      try {
        await initializeDoubletServices(ref);
        _initialized = true;
      } catch (e) {
        debugPrint('Failed to initialize Doublet services: $e');
        // Allow retry on next screen visit
        _initialized = false;
      }
    }

    // Then check if we should show help (after services are ready)
    if (!_helpDialogShown && mounted) {
      final storage = ref.read(storageServiceProvider);
      final hasSeenHelp = storage.hasSeenHelp();
      if (!hasSeenHelp) {
        _helpDialogShown = true;
        showAboutGameDialog(context);
        await storage.markHelpAsSeen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzleAsync = ref.watch(todaysPuzzleProvider);
    final stats = ref.watch(userStatsProvider);
    final hasCompletedToday = ref.watch(hasCompletedTodayProvider);
    final todayFormatted = DateFormat('d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: const DoubletAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Stats card (only show if user has played at least once)
                        if (stats.totalGamesPlayed > 0) ...[
                          StatsCard(stats: stats),
                          const SizedBox(height: 24),
                        ],

                        // Today's puzzle card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  todayFormatted,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 16),
                                puzzleAsync.when(
                                  data: (puzzle) => Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _InfoChip(
                                            icon: Icons.text_fields,
                                            label: '${puzzle.wordLength} letters',
                                          ),
                                          const SizedBox(width: 12),
                                          _InfoChip(
                                            icon: Icons.linear_scale,
                                            label: '${puzzle.stepCount} words',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${puzzle.startWord}  \u2192  ${puzzle.endWord}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      if (hasCompletedToday)
                                        _buildCompletedState(context, puzzle.index, puzzle.ladder)
                                      else
                                        Semantics(
                                          button: true,
                                          label: 'Play today\'s puzzle',
                                          child: FilledButton.icon(
                                            onPressed: () => Navigator.pushNamed(
                                              context,
                                              RouteNames.doubletPlay,
                                            ),
                                            icon: const Icon(Icons.play_arrow),
                                            label: const Text('Play Today\'s Puzzle'),
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
                                        onPressed: () =>
                                            ref.invalidate(todaysPuzzleProvider),
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

  Widget _buildCompletedState(BuildContext context, int puzzleIndex, List<String> ladder) {
    final storage = ref.read(storageServiceProvider);
    final result = storage.getResultForPuzzle(puzzleIndex);
    final wasSuccessful = result?.wasSuccessful ?? false;
    final score = result?.score ?? 0;
    final stats = ref.read(userStatsProvider);

    return Column(
      children: [
        // Solution display - show the word ladder
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (wasSuccessful ? Colors.green : Colors.orange).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: wasSuccessful ? Colors.green : Colors.orange,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    wasSuccessful ? Icons.check_circle : Icons.cancel,
                    color: wasSuccessful ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    wasSuccessful ? 'Completed!' : 'You gave up',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: wasSuccessful ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Word ladder solution
              ...ladder.map((word) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  word.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Score display
        Text(
          'Score: $score/100',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Action buttons - matching Cryptix layout
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _shareResult(context, score, wasSuccessful),
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Share'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showResultsDialog(context, score, wasSuccessful, result, stats),
              icon: const Icon(Icons.emoji_events, size: 18),
              label: const Text('View Results'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                RouteNames.doubletArchive,
              ),
              icon: const Icon(Icons.history, size: 18),
              label: const Text('View Archive'),
            ),
          ],
        ),
      ],
    );
  }

  void _showResultsDialog(BuildContext context, int score, bool wasSuccessful, dynamic result, dynamic stats) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String message;
    if (!wasSuccessful) {
      message = 'Better luck next time!';
    } else if (score >= 90) {
      message = 'Amazing!';
    } else if (score >= 70) {
      message = 'Great Job!';
    } else if (score >= 50) {
      message = 'Good Work!';
    } else {
      message = 'Puzzle Complete!';
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Result icon
                Icon(
                  wasSuccessful ? Icons.celebration : Icons.sentiment_dissatisfied,
                  size: 64,
                  color: wasSuccessful ? Colors.amber : Colors.grey,
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  message,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: wasSuccessful
                        ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                        : Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Score display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (wasSuccessful ? Colors.green : Colors.orange)
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
                          color: wasSuccessful
                              ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                              : Colors.orange,
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
                    _ResultStatItem(
                      label: 'Current Streak',
                      value: '${stats.currentStreak}',
                      icon: Icons.local_fire_department,
                    ),
                    _ResultStatItem(
                      label: 'Best Streak',
                      value: '${stats.longestStreak}',
                      icon: Icons.emoji_events,
                    ),
                    _ResultStatItem(
                      label: 'Total Played',
                      value: '${stats.totalGamesPlayed}',
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Close button
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareResult(BuildContext context, int score, bool wasSuccessful) {
    final puzzleNumber = PuzzleDateUtils.getTodaysPuzzleNumber();

    final String scoreEmoji;
    final String message;
    if (!wasSuccessful) {
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

    final filledBlocks = (score / 10).round();
    final scoreBar = '\u{1F7E9}' * filledBlocks + '\u2B1C' * (10 - filledBlocks);

    final text = '''
Daily Doublet #$puzzleNumber $scoreEmoji

$message

$scoreBar $score/100

https://axiom-puzzles.com
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}

class _ResultStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ResultStatItem({
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
