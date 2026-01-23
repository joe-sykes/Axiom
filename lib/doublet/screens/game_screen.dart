import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/game_keyboard.dart';
import '../core/constants/ui_constants.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/scoring_utils.dart';
import '../models/puzzle.dart';
import '../providers/providers.dart';
import '../widgets/about_dialog.dart';
import '../widgets/doublet_app_bar.dart';
import '../widgets/word_input_tile.dart';

class DoubletGameScreen extends ConsumerStatefulWidget {
  final bool isDaily;
  final int? puzzleIndex;

  const DoubletGameScreen({
    super.key,
    required this.isDaily,
    this.puzzleIndex,
  });

  @override
  ConsumerState<DoubletGameScreen> createState() => _DoubletGameScreenState();
}

class _DoubletGameScreenState extends ConsumerState<DoubletGameScreen> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  bool _isSubmitting = false;
  bool _helpDialogShown = false;
  String? _errorMessage;
  int _focusedControllerIndex = 0;

  bool get _useCustomKeyboard {
    if (!kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  int get _effectiveIndex =>
      widget.puzzleIndex ?? ref.read(todaysPuzzleIndexProvider);

  @override
  void initState() {
    super.initState();
    // Load puzzle and start game after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  Future<void> _initializeGame() async {
    // Ensure dictionary is loaded (in case user navigated directly to game)
    final dictionary = ref.read(dictionaryServiceProvider);
    if (!dictionary.isLoaded) {
      await dictionary.ensureLoaded();
    }

    // Check if user has already completed today's puzzle (daily mode only)
    if (widget.isDaily && mounted) {
      final hasCompleted = ref.read(hasCompletedTodayProvider);
      if (hasCompleted) {
        // Redirect to results screen instead of just popping
        Navigator.of(context).pushReplacementNamed(RouteNames.doubletResults);
        return;
      }
    }

    // Check if we should show help (first-time user)
    if (!_helpDialogShown && mounted) {
      final storage = ref.read(storageServiceProvider);
      final hasSeenHelp = storage.hasSeenHelp();
      if (!hasSeenHelp) {
        _helpDialogShown = true;
        showAboutGameDialog(context);
        await storage.markHelpAsSeen();
      }
    }

    final puzzleAsync = await ref.read(puzzleProvider(_effectiveIndex).future);
    _setupControllers(puzzleAsync.inputCount);

    ref.read(gameStateProvider.notifier).startGame(
          puzzleAsync,
          widget.isDaily,
        );
  }

  void _setupControllers(int count) {
    // Clear existing
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();

    // Create new
    for (int i = 0; i < count; i++) {
      _controllers.add(TextEditingController());
      final focusNode = FocusNode();
      // Track which controller is focused
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          setState(() => _focusedControllerIndex = i);
        }
      });
      _focusNodes.add(focusNode);
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onWordChanged(int index, String value, Puzzle puzzle) {
    ref.read(gameStateProvider.notifier).setWord(index, value);

    // Auto-advance to next field when word is complete
    if (value.length == puzzle.wordLength && index < _controllers.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _submitSolution(Puzzle puzzle) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final gameNotifier = ref.read(gameStateProvider.notifier);
    final result = await gameNotifier.submitSolution(puzzle);

    setState(() => _isSubmitting = false);

    if (result.isCorrect) {
      if (mounted) {
        final gameState = ref.read(gameStateProvider);
        await _showCompletionDialog(gameState, puzzle);
      }
    } else {
      setState(() => _errorMessage = result.reason);

      // Haptic feedback for error
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _giveUp(Puzzle puzzle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Give up?'),
        content: const Text(
          'You will see the solution but your streak will not increase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Give Up'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(gameStateProvider.notifier).giveUp(puzzle);
      if (mounted) {
        final gameState = ref.read(gameStateProvider);
        await _showCompletionDialog(gameState, puzzle);
      }
    }
  }

  Future<void> _showCompletionDialog(dynamic gameState, Puzzle puzzle) async {
    if (gameState == null) return;

    final stats = ref.read(userStatsProvider);
    final wasSuccessful = gameState.wasSuccessful;
    final score = gameState.finalScore ?? 0;
    final breakdown = ScoringUtils.getBreakdown(
      timeTaken: gameState.elapsedTime,
      incorrectSubmissions: gameState.incorrectSubmissions,
    );

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

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final isDark = theme.brightness == Brightness.dark;
        final screenHeight = MediaQuery.of(dialogContext).size.height;
        final isCompact = screenHeight < 700;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400, maxHeight: screenHeight * 0.85),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isCompact ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Result icon
                    Icon(
                      wasSuccessful ? Icons.celebration : Icons.sentiment_dissatisfied,
                      size: isCompact ? 48 : 64,
                      color: wasSuccessful ? Colors.amber : Colors.grey,
                    ),
                    SizedBox(height: isCompact ? 12 : 16),

                    // Message
                    Text(
                      message,
                      style: (isCompact ? theme.textTheme.titleLarge : theme.textTheme.headlineMedium)?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: wasSuccessful
                            ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                            : Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isCompact ? 16 : 24),

                    // Score display
                    Container(
                      padding: EdgeInsets.all(isCompact ? 12 : 16),
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
                            style: (isCompact ? theme.textTheme.displaySmall : theme.textTheme.displayMedium)?.copyWith(
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
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        // Breakdown
                        _BreakdownRow(
                          label: 'Base score',
                          value: '+${breakdown.baseScore}',
                          color: Colors.green,
                        ),
                        if (breakdown.timePenalty > 0)
                          _BreakdownRow(
                            label: 'Time penalty',
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
                  const SizedBox(height: 16),

                  // Solution (if gave up)
                  if (!wasSuccessful) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Solution',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          ...puzzle.ladder.map((word) => Text(
                                word.toUpperCase(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stats row
                  if (widget.isDaily)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          label: 'Streak',
                          value: '${stats.currentStreak}',
                          icon: Icons.local_fire_department,
                        ),
                        _StatItem(
                          label: 'Best',
                          value: '${stats.longestStreak}',
                          icon: Icons.emoji_events,
                        ),
                        _StatItem(
                          label: 'Played',
                          value: '${stats.totalGamesPlayed}',
                          icon: Icons.check_circle,
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _shareResult(score, wasSuccessful),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _goHome();
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Home'),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _shareResult(int score, bool wasSuccessful) {
    final puzzleNumber = widget.isDaily
        ? PuzzleDateUtils.getTodaysPuzzleNumber()
        : _effectiveIndex + 1;

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

https://axiompuzzles.web.app
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  void _goHome() {
    ref.read(gameStateProvider.notifier).clearGame();
    // Invalidate providers to refresh the home screen
    ref.invalidate(hasCompletedTodayProvider);
    ref.invalidate(userStatsProvider);
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.doublet,
      (route) => route.settings.name == RouteNames.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final puzzleAsync = ref.watch(puzzleProvider(_effectiveIndex));
    final gameState = ref.watch(gameStateProvider);

    // Get puzzle date
    final puzzleDate = widget.isDaily
        ? DateTime.now()
        : PuzzleDateUtils.getFirstReleaseDateForPuzzle(_effectiveIndex);
    final dateStr = DateFormat('d MMMM yyyy').format(puzzleDate);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: DoubletAppBar(
          leading: Semantics(
            button: true,
            label: 'Close game and return home',
            child: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              onPressed: () {
                ref.read(gameStateProvider.notifier).clearGame();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.doublet,
                  (route) => route.settings.name == RouteNames.home,
                );
              },
            ),
          ),
        ),
        body: puzzleAsync.when(
          data: (puzzle) => _buildGameContent(puzzle, gameState, dateStr),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64),
                const SizedBox(height: 16),
                const Text('Failed to load puzzle'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(puzzleProvider(_effectiveIndex)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent(Puzzle puzzle, gameState, String dateStr) {
    if (_controllers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final validator = ref.read(gameValidatorProvider);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Puzzle date header
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Start word (fixed)
                      _WordDisplay(
                        word: puzzle.startWord,
                        isFixed: true,
                        label: 'Start',
                      ),
                      const SizedBox(height: 6),

                      // Input fields
                      ...List.generate(puzzle.inputCount, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: WordInputTile(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            wordLength: puzzle.wordLength,
                            onChanged: (value) =>
                                _onWordChanged(index, value, puzzle),
                            onSubmitted: () {
                              if (index < _controllers.length - 1) {
                                _focusNodes[index + 1].requestFocus();
                              } else {
                                _submitSolution(puzzle);
                              }
                            },
                            validator: validator,
                            stepNumber: index + 2,
                            useCustomKeyboard: _useCustomKeyboard,
                          ),
                        );
                      }),

                      const SizedBox(height: 6),

                      // End word (fixed)
                      _WordDisplay(
                        word: puzzle.endWord,
                        isFixed: true,
                        label: 'End',
                      ),

                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color:
                                      Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Action buttons
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Semantics(
                            button: true,
                            label: 'Give up and see the solution',
                            child: TextButton(
                              onPressed: () => _giveUp(puzzle),
                              child: const Text('Give Up'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Semantics(
                            button: true,
                            label: _isSubmitting ? 'Submitting answer' : 'Submit your answer',
                            child: FilledButton.icon(
                              onPressed: _isSubmitting ? null : () => _submitSolution(puzzle),
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.check),
                              label: const Text('Submit'),
                            ),
                          ),
                        ],
                      ),

                      // Extra padding at bottom to ensure content is visible above keyboard
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Show custom keyboard on mobile devices
              if (_useCustomKeyboard && _controllers.isNotEmpty)
                GameKeyboard(
                  onKeyPressed: (letter) {
                    if (_focusedControllerIndex < _controllers.length) {
                      final controller = _controllers[_focusedControllerIndex];
                      if (controller.text.length < puzzle.wordLength) {
                        controller.text = controller.text + letter;
                        controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.text.length),
                        );
                      }
                    }
                  },
                  onBackspace: () {
                    if (_focusedControllerIndex < _controllers.length) {
                      final controller = _controllers[_focusedControllerIndex];
                      if (controller.text.isNotEmpty) {
                        controller.text = controller.text.substring(0, controller.text.length - 1);
                        controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.text.length),
                        );
                      }
                    }
                  },
                  onEnter: () => _submitSolution(puzzle),
                  showEnter: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordDisplay extends StatelessWidget {
  final String word;
  final bool isFixed;
  final String label;

  const _WordDisplay({
    required this.word,
    required this.isFixed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Text(
            word,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the label
        ],
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
