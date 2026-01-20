import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/route_names.dart';
import '../../core/providers/core_providers.dart';
import '../models/puzzle.dart';
import '../models/puzzle_progress.dart';
import '../providers/cryptix_providers.dart';
import '../../core/widgets/app_footer.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  List<CryptixPuzzle>? _puzzles;
  Map<int, PuzzleProgress>? _progress;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final notifier = ref.read(cryptixGameProvider.notifier);
      final puzzles = await notifier.getArchivePuzzles();
      final progress = await notifier.getAllProgress();

      if (mounted) {
        setState(() {
          _puzzles = puzzles;
          _progress = progress;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _openPuzzle(CryptixPuzzle puzzle, bool isSolved) {
    Navigator.pushNamed(
      context,
      RouteNames.cryptixArchivePuzzle,
      arguments: {
        'puzzle': puzzle,
        'alreadySolved': isSolved,
      },
    ).then((_) => _loadData()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Go back to home (which will show solved state if completed)
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.quiz_outlined),
                SizedBox(width: 8),
                Text('CRYPTIX'),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        actions: [
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
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.of(context).pushNamed('/help'),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'ARCHIVE',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: _buildContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _loadData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_puzzles == null || _puzzles!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.archive_outlined,
                size: 64,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No archived puzzles yet',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Come back tomorrow to see today\'s puzzle in the archive!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _puzzles!.length,
          itemBuilder: (context, index) {
            final puzzle = _puzzles![index];
            final progress = _progress?[puzzle.uid];
            final isSolved = progress?.solved ?? false;
            return _ArchiveItem(
              puzzle: puzzle,
              isSolved: isSolved,
              onTap: () => _openPuzzle(puzzle, isSolved),
            );
          },
        ),
      ),
    );
  }
}

class _ArchiveItem extends StatelessWidget {
  final CryptixPuzzle puzzle;
  final bool isSolved;
  final VoidCallback onTap;

  const _ArchiveItem({
    required this.puzzle,
    required this.isSolved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMMM yyyy');
    final isDark = theme.brightness == Brightness.dark;
    final successColor = isDark ? const Color(0xFF69F0AE) : const Color(0xFF4CAF50);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(puzzle.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      puzzle.clue,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (isSolved) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: successColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            puzzle.answer.toUpperCase(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: successColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        '${puzzle.length} letters',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isSolved)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: successColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 24,
                    color: successColor,
                  ),
                )
              else
                Icon(
                  Icons.play_circle_outline,
                  size: 32,
                  color: theme.colorScheme.tertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
