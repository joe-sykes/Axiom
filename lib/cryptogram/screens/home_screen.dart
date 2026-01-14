import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../../core/theme/axiom_theme.dart';
import '../../core/widgets/game_keyboard.dart';
import '../providers/cryptogram_providers.dart';
import '../widgets/completion_dialog.dart';

class CryptogramHomeScreen extends ConsumerStatefulWidget {
  const CryptogramHomeScreen({super.key});

  @override
  ConsumerState<CryptogramHomeScreen> createState() => _CryptogramHomeScreenState();
}

class _CryptogramHomeScreenState extends ConsumerState<CryptogramHomeScreen> {
  String? _selectedEncodedLetter;
  int _streak = 0;
  int _bestStreak = 0;
  int _totalSolved = 0;
  bool _dialogShown = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPuzzle() async {
    final puzzle = await ref.read(cryptogramDailyPuzzleProvider.future);
    if (puzzle != null) {
      ref.read(cryptogramGameProvider.notifier).initPuzzle(puzzle);
    }

    final streak = await ref.read(cryptogramStreakProvider.future);
    final bestStreak = await ref.read(cryptogramBestStreakProvider.future);
    final totalSolved = await ref.read(cryptogramTotalSolvedProvider.future);
    setState(() {
      _streak = streak;
      _bestStreak = bestStreak;
      _totalSolved = totalSolved;
    });
  }

  void _showCompletionDialog(int score) {
    if (_dialogShown) return;
    _dialogShown = true;

    // Reload stats after completion
    _reloadStats();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CryptogramCompletionDialog(
        score: score,
        currentStreak: _streak,
        bestStreak: _bestStreak,
        totalSolved: _totalSolved,
        onArchive: () => Navigator.pushNamed(context, RouteNames.cryptogramArchive),
        onClose: () {},
      ),
    );
  }

  Future<void> _reloadStats() async {
    // Invalidate and reload stats
    ref.invalidate(cryptogramStreakProvider);
    ref.invalidate(cryptogramBestStreakProvider);
    ref.invalidate(cryptogramTotalSolvedProvider);

    final streak = await ref.read(cryptogramStreakProvider.future);
    final bestStreak = await ref.read(cryptogramBestStreakProvider.future);
    final totalSolved = await ref.read(cryptogramTotalSolvedProvider.future);
    if (mounted) {
      setState(() {
        _streak = streak;
        _bestStreak = bestStreak;
        _totalSolved = totalSolved;
      });
    }
  }

  void _onLetterTap(String encodedLetter) {
    final upperLetter = encodedLetter.toUpperCase();
    final state = ref.read(cryptogramGameProvider);

    // Check if letter is already revealed
    if (state.revealedLetters.contains(upperLetter)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This letter has already been revealed'),
          backgroundColor: AxiomColors.pink,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      if (_selectedEncodedLetter == upperLetter) {
        _selectedEncodedLetter = null;
      } else {
        _selectedEncodedLetter = upperLetter;
      }
    });
  }

  void _onKeyboardKey(String key) {
    if (_selectedEncodedLetter != null) {
      final state = ref.read(cryptogramGameProvider);
      final upperKey = key.toUpperCase();

      // Check if this letter is already assigned to a revealed letter
      for (final revealed in state.revealedLetters) {
        if (state.userMapping[revealed] == upperKey) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$upperKey" is already used by a revealed letter'),
              backgroundColor: AxiomColors.pink,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          return;
        }
      }

      ref.read(cryptogramGameProvider.notifier).setLetter(_selectedEncodedLetter!, key);

      // Move to next unguessed letter
      final newState = ref.read(cryptogramGameProvider);
      final encoded = newState.encodedQuote;
      final currentIndex = encoded.toUpperCase().indexOf(_selectedEncodedLetter!);

      for (int i = currentIndex + 1; i < encoded.length; i++) {
        final char = encoded[i].toUpperCase();
        if (char.contains(RegExp(r'[A-Z]')) && !newState.userMapping.containsKey(char)) {
          setState(() => _selectedEncodedLetter = char);
          return;
        }
      }

      setState(() => _selectedEncodedLetter = null);
    }
  }

  void _onKeyboardBackspace() {
    if (_selectedEncodedLetter != null) {
      ref.read(cryptogramGameProvider.notifier).removeLetter(_selectedEncodedLetter!);
    }
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final gameState = ref.read(cryptogramGameProvider);
    if (gameState.isComplete) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Handle letter keys
    if (key.keyLabel.length == 1 && RegExp(r'[a-zA-Z]').hasMatch(key.keyLabel)) {
      _onKeyboardKey(key.keyLabel.toUpperCase());
      return KeyEventResult.handled;
    }

    // Handle backspace
    if (key == LogicalKeyboardKey.backspace) {
      _onKeyboardBackspace();
      return KeyEventResult.handled;
    }

    // Handle arrow keys
    if (key == LogicalKeyboardKey.arrowLeft) {
      _moveToPreviousLetter(gameState);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _moveToNextLetter(gameState);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _moveToPreviousLetter(CryptogramGameState state) {
    final encoded = state.encodedQuote;
    int startIndex = encoded.length;

    if (_selectedEncodedLetter != null) {
      // Find current position
      for (int i = 0; i < encoded.length; i++) {
        if (encoded[i].toUpperCase() == _selectedEncodedLetter) {
          startIndex = i;
          break;
        }
      }
    }

    // Find previous letter
    for (int i = startIndex - 1; i >= 0; i--) {
      final char = encoded[i].toUpperCase();
      if (char.contains(RegExp(r'[A-Z]')) && !state.revealedLetters.contains(char)) {
        setState(() => _selectedEncodedLetter = char);
        return;
      }
    }
  }

  void _moveToNextLetter(CryptogramGameState state) {
    final encoded = state.encodedQuote;
    int startIndex = -1;

    if (_selectedEncodedLetter != null) {
      // Find current position
      for (int i = 0; i < encoded.length; i++) {
        if (encoded[i].toUpperCase() == _selectedEncodedLetter) {
          startIndex = i;
          break;
        }
      }
    }

    // Find next letter
    for (int i = startIndex + 1; i < encoded.length; i++) {
      final char = encoded[i].toUpperCase();
      if (char.contains(RegExp(r'[A-Z]')) && !state.revealedLetters.contains(char)) {
        setState(() => _selectedEncodedLetter = char);
        return;
      }
    }
  }

  void _revealHint() {
    ref.read(cryptogramGameProvider.notifier).revealLetter();
  }

  void _shareScore(int score) {
    final streakText = _streak == 1 ? 'day' : 'days';
    final emojis = score >= 90 ? '🏆🔐✨' : score >= 70 ? '🎉🔓' : score >= 50 ? '👏🔑' : '💪📝';

    final shareText = '''
$emojis Cryptogram $emojis

Score: $score/100
Streak: $_streak $streakText

Play the daily cryptogram at https://axiompuzzles.web.app
'''.trim();

    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Score copied to clipboard!'),
        backgroundColor: AxiomColors.cyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(cryptogramGameProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final useCustomKeyboard = MediaQuery.of(context).size.width < 600;

    // Show completion dialog when puzzle is solved
    if (gameState.isComplete && !_dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompletionDialog(gameState.score);
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          ),
        ),
        title: GestureDetector(
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          ),
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline),
                SizedBox(width: 10),
                Text('CRYPTOGRAM'),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Archive',
            onPressed: () => Navigator.pushNamed(context, RouteNames.cryptogramArchive),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'How to play',
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) => _handleKeyEvent(event),
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: gameState.puzzle == null
              ? Center(child: CircularProgressIndicator(color: AxiomColors.cyan))
              : SafeArea(
                  child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Date heading
                              Center(
                                child: Text(
                                  DateFormat('d MMMM yyyy').format(DateTime.parse(gameState.puzzle!.date)),
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  'Daily Cryptogram',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Difficulty badge
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(gameState.puzzle!.difficultyLabel),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    gameState.puzzle!.difficultyLabel.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Cryptogram display
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: _buildCryptogram(gameState),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Author (revealed on completion)
                              if (gameState.isComplete)
                                Center(
                                  child: Text(
                                    '— ${gameState.puzzle!.author}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: AxiomColors.cyan,
                                    ),
                                  ),
                                ),

                              if (!gameState.isComplete) ...[
                                const SizedBox(height: 16),
                                // Hint button
                                Center(
                                  child: OutlinedButton.icon(
                                    onPressed: _revealHint,
                                    icon: const Icon(Icons.lightbulb_outline),
                                    label: Text('Reveal Letter (-10 pts) • Used: ${gameState.hintsUsed}'),
                                  ),
                                ),
                              ],

                              if (gameState.isComplete) ...[
                                const SizedBox(height: 24),
                                _buildCompletionCard(gameState),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Keyboard
                  if (useCustomKeyboard && !gameState.isComplete)
                    GameKeyboard(
                      onKeyPressed: _onKeyboardKey,
                      onBackspace: _onKeyboardBackspace,
                      onEnter: null,
                      showEnter: false,
                    ),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildCryptogram(CryptogramGameState state) {
    // Split quote into characters but preserve word boundaries for spacing
    final characters = <Widget>[];
    final quote = state.encodedQuote;
    int wordIndex = 0;

    for (int i = 0; i < quote.length; i++) {
      final char = quote[i];
      if (char == ' ') {
        // Add space between words
        characters.add(const SizedBox(width: 12));
        wordIndex++;
      } else {
        characters.add(_buildLetter(char, state, wordIndex));
      }
    }

    return Wrap(
      spacing: 0,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: characters,
    );
  }

  Widget _buildLetter(String encodedChar, CryptogramGameState state, int wordIndex) {
    final isLetter = encodedChar.toUpperCase().contains(RegExp(r'[A-Z]'));
    final isOddWord = wordIndex.isOdd;
    final wordTint = isOddWord
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
        : Colors.transparent;

    if (!isLetter) {
      // Punctuation - just display it with word tint
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        color: wordTint,
        child: Text(
          encodedChar,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    final upperChar = encodedChar.toUpperCase();
    final userGuess = state.userMapping[upperChar];
    final isSelected = _selectedEncodedLetter == upperChar;
    final isRevealed = state.revealedLetters.contains(upperChar);

    Color bgColor;
    if (isSelected) {
      bgColor = AxiomColors.cyan.withValues(alpha: 0.3);
    } else if (isRevealed) {
      bgColor = AxiomColors.success.withValues(alpha: 0.2);
    } else {
      bgColor = wordTint;
    }

    return GestureDetector(
      onTap: state.isComplete ? null : () => _onLetterTap(upperChar),
      child: Container(
        width: 28,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User's guess
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AxiomColors.cyan : Theme.of(context).dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                userGuess ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isRevealed ? AxiomColors.success : null,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Encoded letter
            Text(
              encodedChar,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(CryptogramGameState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AxiomColors.success, width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Solution quote
            Text(
              '"${state.puzzle!.quote}"',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '— ${state.puzzle!.author}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AxiomColors.cyan,
              ),
            ),
            const SizedBox(height: 24),

            // Score display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AxiomColors.successDark : AxiomColors.success)
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
                    '${state.score}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AxiomColors.successDark : AxiomColors.success,
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
                _buildStatItem(Icons.local_fire_department, '$_streak', 'Current\nStreak'),
                _buildStatItem(Icons.emoji_events, '$_bestStreak', 'Best\nStreak'),
                _buildStatItem(Icons.check_circle, '$_totalSolved', 'Total\nSolved'),
              ],
            ),
            const SizedBox(height: 24),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareScore(state.score),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Share Score'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _dialogShown = false;
                  _showCompletionDialog(state.score);
                },
                icon: const Icon(Icons.bar_chart, size: 18),
                label: const Text('View Results'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, RouteNames.cryptogramArchive),
                icon: const Icon(Icons.archive, size: 18),
                label: const Text('View Archive'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline),
            SizedBox(width: 10),
            Text('How to Play'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Decode the encrypted quote by substituting letters.'),
              SizedBox(height: 16),
              Text('1. Tap a letter to select it'),
              Text('2. Type or tap the letter you think it represents'),
              Text('3. Each letter in the cipher represents one letter'),
              Text('4. Use hints if you get stuck (-10 points each)'),
              SizedBox(height: 16),
              Text('The quote and author will be revealed when you solve it!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
