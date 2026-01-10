import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../core/constants/ui_constants.dart';
import '../core/utils/date_utils.dart';
import '../providers/providers.dart';
import '../widgets/doublet_app_bar.dart';

class DoubletArchiveScreen extends ConsumerWidget {
  const DoubletArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releasedIndices = PuzzleDateUtils.getReleasedPuzzleIndices();
    final storage = ref.watch(storageServiceProvider);
    final todayIndex = ref.watch(todaysPuzzleIndexProvider);

    return Scaffold(
      appBar: const DoubletAppBar(showBackButton: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: releasedIndices.isEmpty
              ? const Center(
                  child: Text('No puzzles available yet'),
                )
              : Column(
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
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: releasedIndices.length,
                        itemBuilder: (context, index) {
                          // Show most recent first
                          final puzzleIndex =
                              releasedIndices[releasedIndices.length - 1 - index];
                          final releaseDate =
                              PuzzleDateUtils.getFirstReleaseDateForPuzzle(puzzleIndex);
                          final puzzleNumber = puzzleIndex + 1;
                          final isToday = puzzleIndex == todayIndex;

                          // Check if played
                          final result = storage.getResultForPuzzle(puzzleIndex);
                          final wasPlayed = result != null;
                          final wasSuccessful = result?.wasSuccessful ?? false;

                          final statusLabel = isToday
                              ? 'Today\'s puzzle'
                              : wasSuccessful
                                  ? 'Completed successfully'
                                  : wasPlayed
                                      ? 'Attempted'
                                      : 'Not played';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Semantics(
                              button: true,
                              label: 'Puzzle $puzzleNumber, $statusLabel${wasPlayed ? ', Score ${result.score} out of 100' : ''}',
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isToday
                                      ? Theme.of(context).colorScheme.primary
                                      : wasSuccessful
                                          ? Colors.green
                                          : wasPlayed
                                              ? Colors.orange
                                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: isToday
                                      ? Icon(
                                          Icons.today,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                          semanticLabel: 'Today',
                                        )
                                      : wasPlayed
                                          ? Icon(
                                              wasSuccessful ? Icons.check : Icons.close,
                                              color: Colors.white,
                                              semanticLabel: wasSuccessful ? 'Completed' : 'Failed',
                                            )
                                          : Text(
                                              '$puzzleNumber',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                ),
                                title: Text(
                                  'Puzzle #$puzzleNumber',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  isToday
                                      ? 'Today'
                                      : DateFormat('MMMM d, yyyy').format(releaseDate),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (wasPlayed)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${result.score}/100',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, semanticLabel: 'Open'),
                                  ],
                                ),
                                onTap: () {
                                  if (isToday) {
                                    Navigator.pushNamed(context, RouteNames.doubletPlay);
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      RouteNames.doubletPlay,
                                      arguments: {'puzzleIndex': puzzleIndex},
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
