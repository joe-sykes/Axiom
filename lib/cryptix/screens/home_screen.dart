import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/route_names.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/game_keyboard.dart';
import '../providers/cryptix_providers.dart';
import '../services/scoring_service.dart';
import '../widgets/clue_display.dart';
import '../widgets/crossword_input.dart';
import '../widgets/completion_dialog.dart';
import '../widgets/help_dialog.dart';
import '../widgets/stats_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showIncorrectFeedback = false;
  bool _showWrongLetters = false;
  List<String>? _userLetters;
  bool _helpChecked = false;
  final GlobalKey<CrosswordInputState> _crosswordKey = GlobalKey();

  /// Determines if we should show the custom on-screen keyboard.
  /// Shows on mobile platforms (phones/tablets) where physical keyboards are rare.
  bool get _useCustomKeyboard {
    // On native mobile platforms, always use custom keyboard
    if (!kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;
    }
    // On web, use custom keyboard for touch devices (phones/tablets)
    // We detect this by checking for mobile user agents via platform check
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndShowHelp();
    });
  }

  Future<void> _initializeAndShowHelp() async {
    // Initialize the game
    await ref.read(cryptixGameProvider.notifier).init();

    // Check if we should show help (first-time user)
    if (!_helpChecked && mounted) {
      _helpChecked = true;
      final storage = ref.read(cryptixStorageProvider);
      final hasSeenHelp = storage.hasSeenHelp();
      if (!hasSeenHelp) {
        showCryptixHelpDialog(context);
        await storage.markHelpAsSeen();
      }
    }
  }

  void _onLettersChanged(List<String> letters) {
    _userLetters = letters;
    // Reset wrong letters highlighting when user starts typing again
    if (_showWrongLetters) {
      setState(() {
        _showWrongLetters = false;
      });
    }
  }

  void _showCompletionDialog(CryptixGameState gameState) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CompletionDialog(
        score: gameState.todaysProgress?.score ?? 0,
        stats: gameState.stats,
        onArchive: () => Navigator.of(context).pushNamed(RouteNames.cryptixArchive),
        onClose: () {},
      ),
    );
  }

  Future<void> _handleSubmit(String answer) async {
    final isCorrect = await ref.read(cryptixGameProvider.notifier).submitGuess(answer);

    if (isCorrect) {
      if (mounted) {
        final gameState = ref.read(cryptixGameProvider);
        _showCompletionDialog(gameState);
      }
    } else {
      setState(() {
        _showIncorrectFeedback = true;
        _showWrongLetters = true;
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _showIncorrectFeedback = false;
        });
      }
    }
  }

  void _useHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Show Definition?'),
        content: const Text(
          'This will highlight the definition part of the clue and deduct 15 points from your score. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cryptixGameProvider.notifier).useHint();
              Navigator.of(context).pop();
            },
            child: const Text('Show Definition'),
          ),
        ],
      ),
    );
  }

  void _revealLetter() {
    ref.read(cryptixGameProvider.notifier).revealLetter();
  }

  Future<void> _shareScore(CryptixGameState gameState) async {
    final score = gameState.todaysProgress?.score ?? 0;
    final stats = gameState.stats;
    final emojis = ScoringService.getScoreEmojis(score);

    final message = '''
$emojis Cryptix $emojis

Score: $score/100
Streak: ${stats.currentStreak} day${stats.currentStreak == 1 ? '' : 's'}

Play the daily cryptic clue at https://axiom-puzzles.com
''';

    await Clipboard.setData(ClipboardData(text: message));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Score copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMMM yyyy');
    final gameState = ref.watch(cryptixGameProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            final isSolved = gameState.state == CryptixPuzzleState.solved;
            if (isSolved) {
              Navigator.pushNamed(context, RouteNames.cryptixArchive);
            }
            // If not solved, we're already on the home page
          },
          child: MouseRegion(
            cursor: gameState.state == CryptixPuzzleState.solved
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.quiz_outlined),
                SizedBox(width: 8),
                Text('CRYPTIX'),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showCryptixHelpDialog(context),
            tooltip: 'How to Play',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, RouteNames.cryptixArchive),
            tooltip: 'Archive',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBody(context, gameState, theme, dateFormat),
            ),
            // Show custom keyboard on mobile devices when puzzle is active
            if (_useCustomKeyboard && gameState.state == CryptixPuzzleState.ready)
              GameKeyboard(
                onKeyPressed: (letter) =>
                    _crosswordKey.currentState?.handleKeyboardLetter(letter),
                onBackspace: () =>
                    _crosswordKey.currentState?.handleKeyboardBackspace(),
                onEnter: () =>
                    _crosswordKey.currentState?.handleKeyboardEnter(),
                showEnter: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CryptixGameState gameState,
    ThemeData theme,
    DateFormat dateFormat,
  ) {
    switch (gameState.state) {
      case CryptixPuzzleState.loading:
        return _buildLoadingSkeleton(context, theme);

      case CryptixPuzzleState.error:
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
                  gameState.errorMessage ?? 'An error occurred',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.read(cryptixGameProvider.notifier).init(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );

      case CryptixPuzzleState.ready:
      case CryptixPuzzleState.solved:
        return _buildPuzzleContent(context, gameState, theme, dateFormat);
    }
  }

  Widget _buildPuzzleContent(
    BuildContext context,
    CryptixGameState gameState,
    ThemeData theme,
    DateFormat dateFormat,
  ) {
    final puzzle = gameState.todaysPuzzle!;
    final isSolved = gameState.state == CryptixPuzzleState.solved;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Date heading
                    Text(
                      dateFormat.format(puzzle.date),
                      style: theme.textTheme.headlineMedium,
                      semanticsLabel:
                          'Puzzle date: ${dateFormat.format(puzzle.date)}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daily Puzzle',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Clue display
                    ClueDisplay(
                      puzzle: puzzle,
                      showHint: gameState.hintUsed,
                    ),
                    const SizedBox(height: 24),

                    // Crossword input - key forces rebuild when revealed letters change
                    CrosswordInput(
                      key: _crosswordKey,
                      length: puzzle.length,
                      isLocked: isSolved,
                      isCorrect: isSolved,
                      correctAnswer: puzzle.answer,
                      revealedIndices: gameState.revealedLetters,
                      canRevealLetter: gameState.canRevealLetter,
                      onRevealLetter: isSolved ? null : () => _revealLetter(),
                      onSubmit: (answer) => _handleSubmit(answer),
                      initialLetters: _userLetters,
                      onLettersChanged: _onLettersChanged,
                      showWrongLetters: _showWrongLetters,
                      onShowDefinition: isSolved ? null : () => _useHint(),
                      hintUsed: gameState.hintUsed,
                      useCustomKeyboard: _useCustomKeyboard,
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
                              'Incorrect! Try again. (-20 points)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Actions and stats card when solved
                    if (isSolved) ...[
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _shareScore(gameState),
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Share'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _showCompletionDialog(gameState),
                            icon: const Icon(Icons.emoji_events, size: 18),
                            label: const Text('View Results'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, RouteNames.cryptixArchive),
                            icon: const Icon(Icons.history, size: 18),
                            label: const Text('View Archive'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StatsCard(stats: gameState.stats),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Date heading skeleton
                    _SkeletonBox(width: 180, height: 32),
                    const SizedBox(height: 8),
                    // "Daily Puzzle" skeleton
                    _SkeletonBox(width: 100, height: 20),
                    const SizedBox(height: 24),

                    // Clue display skeleton
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _SkeletonBox(width: double.infinity, height: 16),
                          const SizedBox(height: 12),
                          _SkeletonBox(width: 200, height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Crossword input skeleton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        7,
                        (index) => Container(
                          width: 44,
                          height: 44,
                          margin: EdgeInsets.only(left: index == 0 ? 0 : 2),
                          child: _SkeletonBox(
                            width: 44,
                            height: 44,
                            borderRadius: 4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SkeletonBox(width: 80, height: 14),
                    const SizedBox(height: 24),

                    // Buttons skeleton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SkeletonBox(width: 140, height: 36, borderRadius: 18),
                        const SizedBox(width: 12),
                        _SkeletonBox(width: 130, height: 36, borderRadius: 18),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SkeletonBox(width: 80, height: 36, borderRadius: 18),
                        const SizedBox(width: 12),
                        _SkeletonBox(width: 90, height: 36, borderRadius: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
