import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../../core/widgets/app_footer.dart';
import '../models/triverse_puzzle.dart';
import '../providers/triverse_providers.dart';
import '../widgets/help_dialog.dart';

class TriverseArchiveScreen extends ConsumerWidget {
  const TriverseArchiveScreen({super.key});

  static String _getTodayDate() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivePuzzlesAsync = ref.watch(triverseArchivePuzzlesProvider);
    final completedDataAsync = ref.watch(triverseCompletedPuzzlesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            // Check if already played today
            final completed = completedDataAsync.valueOrNull;
            final alreadyPlayed = completed != null &&
                (completed['completed'] as Set<String>).contains(_getTodayDate());
            if (alreadyPlayed) {
              // Already on archive, do nothing
            } else {
              Navigator.pop(context); // Go back to home
            }
          },
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
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
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Archive',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                child: archivePuzzlesAsync.when(
                  data: (puzzles) {
                    if (puzzles.isEmpty) {
                      return const Center(
                        child: Text('No archive puzzles available yet'),
                      );
                    }

                    return completedDataAsync.when(
                      data: (completedData) {
                        final completed =
                            completedData['completed'] as Set<String>;
                        final scores =
                            completedData['scores'] as Map<String, int>;

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: puzzles.length,
                          itemBuilder: (context, index) {
                            final puzzle = puzzles[index];
                            final isCompleted = completed.contains(puzzle.date);
                            final score = scores[puzzle.date];

                            return _ArchiveItem(
                              puzzle: puzzle,
                              isCompleted: isCompleted,
                              score: score,
                              onTap: isCompleted
                                  ? null
                                  : () {
                                      // Load the archive puzzle and start the game
                                      ref
                                          .read(triverseGameProvider.notifier)
                                          .loadArchivePuzzle(puzzle);
                                      ref
                                          .read(triverseGameProvider.notifier)
                                          .startGame();
                                      Navigator.pushNamed(
                                        context,
                                        RouteNames.triversePlay,
                                      );
                                    },
                            );
                          },
                        );
                      },
                      loading: () => ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: puzzles.length,
                        itemBuilder: (context, index) {
                          final puzzle = puzzles[index];
                          return _ArchiveItem(
                            puzzle: puzzle,
                            isCompleted: false,
                            score: null,
                            onTap: () {
                              ref
                                  .read(triverseGameProvider.notifier)
                                  .loadArchivePuzzle(puzzle);
                              ref
                                  .read(triverseGameProvider.notifier)
                                  .startGame();
                              Navigator.pushNamed(
                                context,
                                RouteNames.triversePlay,
                              );
                            },
                          );
                        },
                      ),
                      error: (_, __) => ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: puzzles.length,
                        itemBuilder: (context, index) {
                          final puzzle = puzzles[index];
                          return _ArchiveItem(
                            puzzle: puzzle,
                            isCompleted: false,
                            score: null,
                            onTap: () {
                              ref
                                  .read(triverseGameProvider.notifier)
                                  .loadArchivePuzzle(puzzle);
                              ref
                                  .read(triverseGameProvider.notifier)
                                  .startGame();
                              Navigator.pushNamed(
                                context,
                                RouteNames.triversePlay,
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 48),
                        const SizedBox(height: 8),
                        const Text('Unable to load archive'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(triverseArchivePuzzlesProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveItem extends StatelessWidget {
  final TriverseDaily puzzle;
  final bool isCompleted;
  final int? score;
  final VoidCallback? onTap;

  const _ArchiveItem({
    required this.puzzle,
    required this.isCompleted,
    this.score,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Parse date for display
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(puzzle.date);
    } catch (_) {}

    final displayDate = parsedDate != null
        ? DateFormat('d MMMM yyyy').format(parsedDate)
        : puzzle.date;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green : theme.colorScheme.primaryContainer,
          child: Icon(
            isCompleted ? Icons.check : Icons.play_arrow,
            color: isCompleted ? Colors.white : theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          displayDate,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          isCompleted ? 'Completed' : '${puzzle.categories.join(", ")}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isCompleted && score != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(score!).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score/100',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(score!),
                  ),
                ),
              )
            : Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary,
              ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.grey;
  }
}
