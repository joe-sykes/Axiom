import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CrosswordInput extends StatefulWidget {
  final int length;
  final bool isLocked;
  final bool isCorrect;
  final Function(String) onSubmit;
  final String? correctAnswer;
  final List<int> revealedIndices;
  final VoidCallback? onRevealLetter;
  final bool canRevealLetter;
  final List<String>? initialLetters;
  final Function(List<String>)? onLettersChanged;
  final bool showWrongLetters;
  final VoidCallback? onShowDefinition;
  final bool hintUsed;
  final bool useCustomKeyboard;

  const CrosswordInput({
    super.key,
    required this.length,
    this.isLocked = false,
    this.isCorrect = false,
    required this.onSubmit,
    this.correctAnswer,
    this.revealedIndices = const [],
    this.onRevealLetter,
    this.canRevealLetter = true,
    this.initialLetters,
    this.onLettersChanged,
    this.showWrongLetters = false,
    this.onShowDefinition,
    this.hintUsed = false,
    this.useCustomKeyboard = false,
  });

  @override
  State<CrosswordInput> createState() => CrosswordInputState();
}

class CrosswordInputState extends State<CrosswordInput> {
  late List<String> _letters;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeState();
    // Auto-focus first box after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isLocked && _focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _initializeState() {
    if (widget.isCorrect && widget.correctAnswer != null) {
      _letters = widget.correctAnswer!.toUpperCase().split('');
    } else {
      // Start with initial letters if provided, otherwise empty
      if (widget.initialLetters != null && widget.initialLetters!.length == widget.length) {
        _letters = List<String>.from(widget.initialLetters!);
      } else {
        _letters = List.filled(widget.length, '');
      }
      // Fill in revealed letters (overwrite any user input at those positions)
      if (widget.correctAnswer != null) {
        for (final index in widget.revealedIndices) {
          if (index < widget.length) {
            _letters[index] = widget.correctAnswer![index].toUpperCase();
          }
        }
      }
    }
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _controllers = List.generate(
      widget.length,
      (i) => TextEditingController(text: _letters[i]),
    );
  }

  @override
  void didUpdateWidget(CrosswordInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length ||
        oldWidget.isCorrect != widget.isCorrect) {
      _disposeControllers();
      _initializeState();
    } else if (!listEquals(oldWidget.revealedIndices, widget.revealedIndices)) {
      // Update revealed letters without disposing everything
      _updateRevealedLetters();
    }
  }

  void _updateRevealedLetters() {
    if (widget.correctAnswer != null) {
      for (final index in widget.revealedIndices) {
        if (index < widget.length) {
          final letter = widget.correctAnswer![index].toUpperCase();
          _letters[index] = letter;
          _controllers[index].text = letter;
        }
      }
      setState(() {});
    }
  }

  /// Call this method to reveal a letter at a specific index
  void revealLetterAt(int index) {
    if (widget.correctAnswer != null && index < widget.length) {
      final letter = widget.correctAnswer![index].toUpperCase();
      _letters[index] = letter;
      _controllers[index].text = letter;
      setState(() {});
    }
  }

  void _disposeControllers() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  String get currentAnswer => _letters.join();

  bool get isAnswerComplete => _letters.every((letter) => letter.isNotEmpty);

  bool _isRevealed(int index) => widget.revealedIndices.contains(index);

  // Public methods for custom keyboard input
  void handleKeyboardLetter(String letter) {
    if (widget.isLocked) return;

    // Find the focused index or first empty non-revealed cell
    int targetIndex = _focusedIndex;
    if (_isRevealed(targetIndex) || _letters[targetIndex].isNotEmpty) {
      // Find next empty non-revealed cell
      for (int i = 0; i < widget.length; i++) {
        if (!_isRevealed(i) && _letters[i].isEmpty) {
          targetIndex = i;
          break;
        }
      }
    }

    if (_isRevealed(targetIndex)) return;

    setState(() {
      _letters[targetIndex] = letter.toUpperCase();
      _controllers[targetIndex].text = letter.toUpperCase();
      _focusedIndex = targetIndex;
    });

    widget.onLettersChanged?.call(List<String>.from(_letters));
    _focusNext(targetIndex);
  }

  void handleKeyboardBackspace() {
    if (widget.isLocked) return;

    int targetIndex = _focusedIndex;

    // If current cell is empty, go to previous non-revealed cell
    if (_letters[targetIndex].isEmpty || _isRevealed(targetIndex)) {
      for (int i = targetIndex - 1; i >= 0; i--) {
        if (!_isRevealed(i)) {
          targetIndex = i;
          break;
        }
      }
    }

    if (_isRevealed(targetIndex)) return;

    setState(() {
      _letters[targetIndex] = '';
      _controllers[targetIndex].clear();
      _focusedIndex = targetIndex;
    });

    widget.onLettersChanged?.call(List<String>.from(_letters));
  }

  void handleKeyboardEnter() {
    _handleSubmit();
  }

  bool _isWrongLetter(int index) {
    if (!widget.showWrongLetters || widget.correctAnswer == null) return false;
    if (_letters[index].isEmpty) return false;
    return _letters[index].toUpperCase() != widget.correctAnswer![index].toUpperCase();
  }

  void _onLetterChanged(int index, String value) {
    if (_isRevealed(index)) return;

    setState(() {
      _letters[index] = value.toUpperCase();
    });

    // Notify parent of letter changes
    widget.onLettersChanged?.call(List<String>.from(_letters));

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNext(index);
    }
  }

  void _focusNext(int currentIndex) {
    // Find next non-revealed index
    for (int i = currentIndex + 1; i < widget.length; i++) {
      if (!_isRevealed(i)) {
        setState(() => _focusedIndex = i);
        _focusNodes[i].requestFocus();
        return;
      }
    }
  }

  void _focusPrevious(int currentIndex) {
    // Find previous non-revealed index
    for (int i = currentIndex - 1; i >= 0; i--) {
      if (!_isRevealed(i)) {
        setState(() => _focusedIndex = i);
        _focusNodes[i].requestFocus();
        return;
      }
    }
  }

  void _handleKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_letters[index].isEmpty) {
        _focusPrevious(index);
      } else {
        setState(() {
          _letters[index] = '';
          _controllers[index].clear();
        });
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _focusPrevious(index);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _focusNext(index);
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _handleSubmit();
    }
  }

  void _handleSubmit() {
    if (isAnswerComplete) {
      widget.onSubmit(currentAnswer);
    }
  }

  void _clearAll() {
    setState(() {
      for (int i = 0; i < widget.length; i++) {
        if (!_isRevealed(i)) {
          _letters[i] = '';
          _controllers[i].clear();
        }
      }
      _focusedIndex = 0;
    });
    // Notify parent of letter changes
    widget.onLettersChanged?.call(List<String>.from(_letters));
    // Find first non-revealed index
    for (int i = 0; i < widget.length; i++) {
      if (!_isRevealed(i)) {
        _focusNodes[i].requestFocus();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crossword grid - responsive sizing
        Semantics(
          label: 'Answer input, ${widget.length} letters',
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate cell size based on available width
              // Leave some padding (32px total) and account for borders
              final availableWidth = constraints.maxWidth - 32;
              final maxCellSize = 48.0;
              final minCellSize = 36.0;
              final calculatedSize = availableWidth / widget.length;
              final cellSize = calculatedSize.clamp(minCellSize, maxCellSize);

              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.length, (index) {
                    return _buildCell(context, index, isDark, cellSize);
                  }),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Letter count indicator
        Text(
          '(${widget.length} letters)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
          semanticsLabel: '${widget.length} letters',
        ),

        const SizedBox(height: 24),

        // Hint buttons row
        if (!widget.isLocked)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              if (!widget.hintUsed && widget.onShowDefinition != null)
                OutlinedButton.icon(
                  onPressed: widget.onShowDefinition,
                  icon: const Icon(Icons.lightbulb_outline, size: 18),
                  label: const Text('Show Definition (-15)'),
                ),
              if (widget.canRevealLetter && widget.onRevealLetter != null)
                OutlinedButton.icon(
                  onPressed: widget.onRevealLetter,
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Reveal Letter (-5)'),
                ),
            ],
          ),

        // Crossword Companion link
        if (!widget.isLocked)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton.icon(
              onPressed: () async {
                final uri = Uri.parse('https://crossword-companion.net/');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Crossword Companion'),
            ),
          ),

        const SizedBox(height: 16),

        // Action buttons
        if (!widget.isLocked)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
              ),
              ElevatedButton.icon(
                onPressed: isAnswerComplete ? _handleSubmit : null,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Submit'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(BuildContext context, int index, bool isDark, double cellSize) {
    final theme = Theme.of(context);
    final isRevealed = _isRevealed(index);
    final isWrong = _isWrongLetter(index);
    final isFocused = _focusedIndex == index && !widget.isLocked && !isRevealed;
    final hasLetter = _letters[index].isNotEmpty;

    Color bgColor;
    Color borderColor;
    Color? textColor;

    if (widget.isCorrect) {
      bgColor = (isDark ? const Color(0xFF69F0AE) : const Color(0xFF4CAF50))
          .withValues(alpha: 0.2);
      borderColor = isDark ? const Color(0xFF69F0AE) : const Color(0xFF4CAF50);
    } else if (isWrong) {
      bgColor = theme.colorScheme.error.withValues(alpha: 0.15);
      borderColor = theme.colorScheme.error;
      textColor = theme.colorScheme.error;
    } else if (isRevealed) {
      bgColor = theme.colorScheme.tertiary.withValues(alpha: 0.2);
      borderColor = theme.colorScheme.tertiary;
    } else if (isFocused) {
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.15);
      borderColor = theme.colorScheme.primary;
    } else {
      bgColor = theme.colorScheme.surface;
      borderColor = theme.colorScheme.secondary.withValues(alpha: 0.5);
    }

    return GestureDetector(
      onTap: widget.isLocked || isRevealed
          ? null
          : () {
              setState(() => _focusedIndex = index);
              _focusNodes[index].requestFocus();
            },
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(color: borderColor, width: isFocused ? 2 : 1),
            bottom: BorderSide(color: borderColor, width: isFocused ? 2 : 1),
            left: BorderSide(color: borderColor, width: index == 0 ? (isFocused ? 2 : 1) : 0.5),
            right: BorderSide(color: borderColor, width: index == widget.length - 1 ? (isFocused ? 2 : 1) : 0.5),
          ),
        ),
        child: widget.isLocked || isRevealed
            ? Center(
                child: Text(
                  _letters[index].toUpperCase(),
                  style: TextStyle(
                    fontSize: cellSize * 0.45,
                    fontWeight: FontWeight.bold,
                    color: widget.isCorrect
                        ? (isDark
                            ? const Color(0xFF69F0AE)
                            : const Color(0xFF4CAF50))
                        : isRevealed
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.onSurface,
                  ),
                ),
              )
            : KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) => _handleKeyEvent(index, event),
                child: Stack(
                  children: [
                    // Visible centered letter
                    Center(
                      child: Text(
                        _letters[index].toUpperCase(),
                        style: TextStyle(
                          fontSize: cellSize * 0.45,
                          fontWeight: FontWeight.bold,
                          color: textColor ?? theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Invisible TextField for input
                    Opacity(
                      opacity: 0,
                      child: TextField(
                        focusNode: _focusNodes[index],
                        controller: _controllers[index],
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 1,
                        readOnly: widget.useCustomKeyboard,
                        showCursor: false,
                        keyboardType: widget.useCustomKeyboard ? TextInputType.none : null,
                        style: TextStyle(
                          fontSize: cellSize * 0.45,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                          UpperCaseTextFormatter(),
                        ],
                        onChanged: widget.useCustomKeyboard ? null : (value) => _onLetterChanged(index, value),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
