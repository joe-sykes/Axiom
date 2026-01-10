import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/core_providers.dart';
import '../models/puzzle.dart';
import '../providers/cryptix_providers.dart';
import '../widgets/clue_display.dart';
import '../widgets/crossword_input.dart';
import '../../core/widgets/app_footer.dart';

class ArchivePuzzleScreen extends ConsumerStatefulWidget {
  final CryptixPuzzle puzzle;
  final bool alreadySolved;

  const ArchivePuzzleScreen({
    super.key,
    required this.puzzle,
    this.alreadySolved = false,
  });

  @override
  ConsumerState<ArchivePuzzleScreen> createState() => _ArchivePuzzleScreenState();
}

class _ArchivePuzzleScreenState extends ConsumerState<ArchivePuzzleScreen> {
  bool _solved = false;
  bool _showIncorrectFeedback = false;

  @override
  void initState() {
    super.initState();
    _solved = widget.alreadySolved;
  }

  Future<void> _handleSubmit(String answer) async {
    final isCorrect =
        answer.toUpperCase().trim() == widget.puzzle.answer.toUpperCase();

    if (isCorrect) {
      // Mark as solved in storage (no score)
      await ref.read(cryptixGameProvider.notifier).markArchivePuzzleSolved(widget.puzzle.uid);
      setState(() {
        _solved = true;
      });
      if (mounted) {
        _showSuccessDialog();
      }
    } else {
      setState(() {
        _showIncorrectFeedback = true;
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _showIncorrectFeedback = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            const Text('Well Done!'),
          ],
        ),
        content: const Text(
          'You solved this archive puzzle!\n\nArchive puzzles don\'t affect your streak or score, but it\'s great practice!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Archive'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMMM yyyy');
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text('CRYPTIX'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Archive',
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
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Archive badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'ARCHIVE PUZZLE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Date heading
                          Text(
                            dateFormat.format(widget.puzzle.date),
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),

                          // No scoring notice
                          Text(
                            'Practice mode - no points or streak',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Clue display
                          ClueDisplay(
                            puzzle: widget.puzzle,
                            showHint: false,
                          ),
                          const SizedBox(height: 24),

                          // Crossword input
                          CrosswordInput(
                            length: widget.puzzle.length,
                            isLocked: _solved,
                            isCorrect: _solved,
                            correctAnswer: widget.puzzle.answer,
                            canRevealLetter: false,
                            onSubmit: _handleSubmit,
                          ),

                          // Incorrect feedback
                          if (_showIncorrectFeedback) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.colorScheme.error),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: theme.colorScheme.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Incorrect! Try again.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Already solved message
                          if (_solved && widget.alreadySolved) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'You\'ve already solved this puzzle!',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF4CAF50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
