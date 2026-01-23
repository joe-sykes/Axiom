import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../../core/theme/axiom_theme.dart';
import '../../core/widgets/game_keyboard.dart';
import '../models/puzzle.dart';
import '../providers/cryptogram_providers.dart';
import '../services/storage_service.dart';

class CryptogramArchivePuzzleScreen extends ConsumerStatefulWidget {
  final CryptogramPuzzle puzzle;

  const CryptogramArchivePuzzleScreen({super.key, required this.puzzle});

  @override
  ConsumerState<CryptogramArchivePuzzleScreen> createState() => _CryptogramArchivePuzzleScreenState();
}

class _CryptogramArchivePuzzleScreenState extends ConsumerState<CryptogramArchivePuzzleScreen> {
  String? _selectedEncodedLetter;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _hiddenInputFocusNode = FocusNode();
  final TextEditingController _hiddenInputController = TextEditingController();

  bool get _useCustomKeyboard {
    if (!kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  // Local game state for archive puzzles
  final CryptogramStorageService _storageService = CryptogramStorageService();
  late Map<String, String> _cipher;
  late String _encodedQuote;
  Map<String, String> _userMapping = {};
  Set<String> _revealedLetters = {};
  int _hintsUsed = 0;
  bool _isComplete = false;
  bool _alreadySolved = false;

  @override
  void initState() {
    super.initState();
    _initPuzzle();
    _checkIfAlreadySolved();
  }

  Future<void> _checkIfAlreadySolved() async {
    final solved = await _storageService.isAnyPuzzleCompleted(widget.puzzle.date);
    if (mounted && solved) {
      setState(() {
        _alreadySolved = true;
        _isComplete = true;
        // Show the solution
        _userMapping = Map.fromEntries(
          _cipher.entries.map((e) => MapEntry(e.key, e.value)),
        );
      });
    }
  }

  void _initPuzzle() {
    _cipher = widget.puzzle.generateCipher();
    _encodedQuote = widget.puzzle.encodeQuote(_cipher);
    _userMapping = {};
    _revealedLetters = {};
    _hintsUsed = 0;
    _isComplete = false;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _hiddenInputFocusNode.dispose();
    _hiddenInputController.dispose();
    super.dispose();
  }

  void _onLetterTap(String encodedLetter) {
    final upperLetter = encodedLetter.toUpperCase();

    if (_revealedLetters.contains(upperLetter)) {
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
        // Focus the hidden input to trigger mobile keyboard (only if not using custom keyboard)
        if (!_useCustomKeyboard) {
          _hiddenInputController.clear();
          _hiddenInputFocusNode.requestFocus();
        }
      }
    });
  }

  void _onHiddenInputChanged(String value) {
    if (value.isNotEmpty && _selectedEncodedLetter != null) {
      final letter = value[value.length - 1];
      if (RegExp(r'[a-zA-Z]').hasMatch(letter)) {
        _onKeyboardKey(letter);
      }
      // Clear the hidden input for next character
      _hiddenInputController.clear();
    }
  }

  void _onKeyboardKey(String key) {
    if (_selectedEncodedLetter != null && !_isComplete) {
      final upperKey = key.toUpperCase();

      // Check if this letter is already assigned to a revealed letter
      for (final revealed in _revealedLetters) {
        if (_userMapping[revealed] == upperKey) {
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

      setState(() {
        // Remove any existing mapping to this letter (but not revealed ones)
        _userMapping.removeWhere((k, v) =>
            v.toUpperCase() == upperKey && !_revealedLetters.contains(k));
        _userMapping[_selectedEncodedLetter!] = upperKey;
      });

      _checkCompletion();

      // Move to next unguessed letter
      final currentIndex = _encodedQuote.toUpperCase().indexOf(_selectedEncodedLetter!);
      for (int i = currentIndex + 1; i < _encodedQuote.length; i++) {
        final char = _encodedQuote[i].toUpperCase();
        if (char.contains(RegExp(r'[A-Z]')) && !_userMapping.containsKey(char) && !_revealedLetters.contains(char)) {
          setState(() => _selectedEncodedLetter = char);
          return;
        }
      }
      setState(() => _selectedEncodedLetter = null);
    }
  }

  void _onKeyboardBackspace() {
    if (_isComplete) return;

    // If current letter has a mapping, remove it
    if (_selectedEncodedLetter != null &&
        _userMapping.containsKey(_selectedEncodedLetter) &&
        !_revealedLetters.contains(_selectedEncodedLetter)) {
      setState(() {
        _userMapping.remove(_selectedEncodedLetter);
      });
      return;
    }

    // Otherwise, find the previous letter with a mapping and remove it
    int startIndex = _encodedQuote.length;

    if (_selectedEncodedLetter != null) {
      for (int i = 0; i < _encodedQuote.length; i++) {
        if (_encodedQuote[i].toUpperCase() == _selectedEncodedLetter) {
          startIndex = i;
          break;
        }
      }
    }

    // Search backwards for a letter with a mapping that isn't revealed
    for (int i = startIndex - 1; i >= 0; i--) {
      final char = _encodedQuote[i].toUpperCase();
      if (char.contains(RegExp(r'[A-Z]')) &&
          _userMapping.containsKey(char) &&
          !_revealedLetters.contains(char)) {
        setState(() {
          _userMapping.remove(char);
          _selectedEncodedLetter = char;
        });
        return;
      }
    }
  }

  void _checkCompletion() async {
    if (_alreadySolved) return; // Don't check if already solved before

    final decoded = _encodedQuote.split('').map((char) {
      final upper = char.toUpperCase();
      if (_userMapping.containsKey(upper)) {
        return char == upper ? _userMapping[upper]! : _userMapping[upper]!.toLowerCase();
      }
      return char;
    }).join('');

    if (decoded.toUpperCase() == widget.puzzle.quote.toUpperCase()) {
      // Save to archive storage (does NOT affect streak)
      await _storageService.markArchivePuzzleCompleted(widget.puzzle.date);
      // Refresh completed count so homepage updates
      ref.invalidate(cryptogramTotalSolvedProvider);
      setState(() => _isComplete = true);
    }
  }

  void _revealHint() {
    if (_isComplete) return;

    // Get unique letters that actually appear in the encoded quote
    final lettersInQuote = _encodedQuote
        .toUpperCase()
        .split('')
        .where((c) => RegExp(r'[A-Z]').hasMatch(c))
        .toSet();

    // Build reverse cipher for decoding
    final reverseCipher = <String, String>{};
    _cipher.forEach((k, v) => reverseCipher[v] = k);

    // Find letters that haven't been revealed or correctly guessed
    final availableLetters = <String>[];
    for (final encoded in lettersInQuote) {
      final decoded = reverseCipher[encoded];
      if (decoded != null &&
          !_revealedLetters.contains(encoded) &&
          _userMapping[encoded] != decoded) {
        availableLetters.add(encoded);
      }
    }

    if (availableLetters.isEmpty) return;

    // Use deterministic random based on puzzle date and hints used
    final seed = widget.puzzle.date.hashCode + _hintsUsed;
    final random = Random(seed);
    final encoded = availableLetters[random.nextInt(availableLetters.length)];
    final decoded = reverseCipher[encoded]!;

    setState(() {
      _userMapping[encoded] = decoded;
      _revealedLetters.add(encoded);
      _hintsUsed++;
    });
    _checkCompletion();
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_isComplete) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key.keyLabel.length == 1 && RegExp(r'[a-zA-Z]').hasMatch(key.keyLabel)) {
      _onKeyboardKey(key.keyLabel.toUpperCase());
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.backspace) {
      _onKeyboardBackspace();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      _moveToPreviousLetter();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _moveToNextLetter();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _moveToPreviousLetter() {
    int startIndex = _encodedQuote.length;
    if (_selectedEncodedLetter != null) {
      for (int i = 0; i < _encodedQuote.length; i++) {
        if (_encodedQuote[i].toUpperCase() == _selectedEncodedLetter) {
          startIndex = i;
          break;
        }
      }
    }

    for (int i = startIndex - 1; i >= 0; i--) {
      final char = _encodedQuote[i].toUpperCase();
      if (char.contains(RegExp(r'[A-Z]')) && !_revealedLetters.contains(char)) {
        setState(() => _selectedEncodedLetter = char);
        return;
      }
    }
  }

  void _moveToNextLetter() {
    int startIndex = -1;
    if (_selectedEncodedLetter != null) {
      for (int i = 0; i < _encodedQuote.length; i++) {
        if (_encodedQuote[i].toUpperCase() == _selectedEncodedLetter) {
          startIndex = i;
          break;
        }
      }
    }

    for (int i = startIndex + 1; i < _encodedQuote.length; i++) {
      final char = _encodedQuote[i].toUpperCase();
      if (char.contains(RegExp(r'[A-Z]')) && !_revealedLetters.contains(char)) {
        setState(() => _selectedEncodedLetter = char);
        return;
      }
    }
  }

  int get _score => (100 - _hintsUsed * 10).clamp(0, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.cryptogram,
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
            onPressed: () => Navigator.pop(context),
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
          child: SafeArea(
            child: Stack(
              children: [
                // Hidden TextField to capture mobile keyboard input
                Positioned(
                  left: -1000,
                  child: SizedBox(
                    width: 1,
                    height: 1,
                    child: TextField(
                      controller: _hiddenInputController,
                      focusNode: _hiddenInputFocusNode,
                      onChanged: _onHiddenInputChanged,
                      autofocus: false,
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Column(
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
                                DateFormat('d MMMM yyyy').format(DateTime.parse(widget.puzzle.date)),
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                'Archive Puzzle',
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
                                  color: _getDifficultyColor(widget.puzzle.difficultyLabel),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.puzzle.difficultyLabel.toUpperCase(),
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
                                child: _buildCryptogram(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Available letters tracker
                            if (!_isComplete)
                              _buildAvailableLetters(),
                            if (!_isComplete)
                              const SizedBox(height: 16),

                            // Author (revealed on completion)
                            if (_isComplete)
                              Center(
                                child: Text(
                                  '— ${widget.puzzle.author}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AxiomColors.cyan,
                                  ),
                                ),
                              ),

                            if (!_isComplete) ...[
                              const SizedBox(height: 16),
                              Center(
                                child: OutlinedButton.icon(
                                  onPressed: _revealHint,
                                  icon: const Icon(Icons.lightbulb_outline),
                                  label: Text('Reveal Letter (-10 pts) • Used: $_hintsUsed'),
                                ),
                              ),
                            ],

                            if (_isComplete) ...[
                              const SizedBox(height: 24),
                              _buildCompletionCard(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Show custom keyboard on mobile devices when puzzle is not complete
                if (_useCustomKeyboard && !_isComplete)
                  GameKeyboard(
                    onKeyPressed: _onKeyboardKey,
                    onBackspace: _onKeyboardBackspace,
                    showEnter: false,
                    usedLetters: _userMapping.values.toSet(),
                    revealedLetters: _revealedLetters
                        .map((encoded) => _userMapping[encoded])
                        .whereType<String>()
                        .toSet(),
                  ),
              ],
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCryptogram() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Tighter spacing on smaller screens
    final runSpacing = screenWidth < 400 ? 8.0 : 12.0;
    // Calculate max characters per chunk based on actual screen width
    // Each letter cell is 28px + 2px margin = 30px, plus some padding for container
    final contentWidth = screenWidth - 32; // Account for screen padding
    final letterWidth = 30.0;
    final maxChunkSize = ((contentWidth - 20) / letterWidth).floor().clamp(8, 20);

    final words = <Widget>[];
    final wordStrings = _encodedQuote.split(' ');

    for (int wordIndex = 0; wordIndex < wordStrings.length; wordIndex++) {
      final word = wordStrings[wordIndex];

      // Split long words into chunks with continuation hyphens
      if (word.length > maxChunkSize) {
        final chunks = <List<String>>[];
        for (int i = 0; i < word.length; i += maxChunkSize) {
          final end = (i + maxChunkSize < word.length) ? i + maxChunkSize : word.length;
          chunks.add(word.substring(i, end).split(''));
        }

        for (int chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) {
          final chunk = chunks[chunkIndex];
          final letterWidgets = <Widget>[];

          for (int i = 0; i < chunk.length; i++) {
            letterWidgets.add(_buildLetter(chunk[i], wordIndex));
          }

          // Add continuation hyphen at end of chunk (except last chunk)
          if (chunkIndex < chunks.length - 1) {
            letterWidgets.add(_buildContinuationHyphen());
          }

          words.add(Row(
            mainAxisSize: MainAxisSize.min,
            children: letterWidgets,
          ));
        }
      } else {
        // Short words stay together
        final letterWidgets = <Widget>[];
        for (int i = 0; i < word.length; i++) {
          letterWidgets.add(_buildLetter(word[i], wordIndex));
        }

        words.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: letterWidgets,
        ));
      }
    }

    return Wrap(
      spacing: 12, // Space between words
      runSpacing: runSpacing,
      alignment: WrapAlignment.center,
      children: words,
    );
  }

  Widget _buildContinuationHyphen() {
    return Container(
      padding: const EdgeInsets.only(left: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 32,
            alignment: Alignment.bottomCenter,
            child: Text(
              '—', // Em dash to distinguish from actual hyphens
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AxiomColors.cyan,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLetter(String encodedChar, int wordIndex) {
    final isLetter = encodedChar.toUpperCase().contains(RegExp(r'[A-Z]'));
    final isOddWord = wordIndex.isOdd;
    final wordTint = isOddWord
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
        : Colors.transparent;

    if (!isLetter) {
      // Punctuation - match letter height structure for alignment, no word tint
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 32,
              alignment: Alignment.bottomCenter,
              child: Text(
                encodedChar,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    final upperChar = encodedChar.toUpperCase();
    final userGuess = _userMapping[upperChar];
    final isSelected = _selectedEncodedLetter == upperChar;
    final isRevealed = _revealedLetters.contains(upperChar);

    Color bgColor;
    if (isSelected) {
      bgColor = AxiomColors.cyan.withValues(alpha: 0.3);
    } else if (isRevealed) {
      bgColor = AxiomColors.success.withValues(alpha: 0.2);
    } else {
      bgColor = wordTint;
    }

    return GestureDetector(
      onTap: _isComplete ? null : () => _onLetterTap(upperChar),
      child: Container(
        width: 28,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

  Widget _buildCompletionCard() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AxiomColors.success, width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: AxiomColors.success, size: 48),
            const SizedBox(height: 12),
            Text(
              'Puzzle Solved!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AxiomColors.success,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score/100',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_hintsUsed > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$_hintsUsed hints used (-${_hintsUsed * 10} points)',
                style: TextStyle(color: AxiomColors.pink),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Archive'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableLetters() {
    final theme = Theme.of(context);
    final usedLetters = _userMapping.values.map((e) => e.toUpperCase()).toSet();
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    return Column(
      children: [
        Text(
          'Available Letters',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: alphabet.split('').map((letter) {
            final isUsed = usedLetters.contains(letter);
            return Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isUsed
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isUsed
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : theme.colorScheme.primary,
                  decoration: isUsed ? TextDecoration.lineThrough : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange.shade700;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
