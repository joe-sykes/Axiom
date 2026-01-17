import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LetterBox extends StatelessWidget {
  final int index;
  final String? letter;
  final bool isFocused;
  final bool isCorrect;
  final bool isLocked;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback onBackspace;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const LetterBox({
    super.key,
    required this.index,
    this.letter,
    this.isFocused = false,
    this.isCorrect = false,
    this.isLocked = false,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color borderColor;
    Color fillColor;

    if (isCorrect) {
      borderColor = isDark ? const Color(0xFF69F0AE) : const Color(0xFF4CAF50);
      fillColor = (isDark ? const Color(0xFF69F0AE) : const Color(0xFF4CAF50))
          .withValues(alpha: 0.2);
    } else if (isFocused) {
      borderColor = theme.colorScheme.primary;
      fillColor = theme.colorScheme.primary.withValues(alpha: 0.1);
    } else {
      borderColor = theme.colorScheme.secondary;
      fillColor = theme.colorScheme.surface;
    }

    return Semantics(
      label: 'Letter ${index + 1}${letter != null && letter!.isNotEmpty ? ', $letter' : ', empty'}',
      textField: true,
      child: Container(
        width: 48,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(
            color: borderColor,
            width: isFocused ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLocked
            ? Center(
                child: Text(
                  letter?.toUpperCase() ?? '',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCorrect
                        ? (isDark ? const Color(0xFF69F0AE) : const Color(0xFF4CAF50))
                        : theme.colorScheme.onSurface,
                  ),
                ),
              )
            : _LetterTextField(
                focusNode: focusNode,
                letter: letter,
                onChanged: onChanged,
                onBackspace: onBackspace,
                onNext: onNext,
                onPrevious: onPrevious,
              ),
      ),
    );
  }
}

class _LetterTextField extends StatefulWidget {
  final FocusNode focusNode;
  final String? letter;
  final Function(String) onChanged;
  final VoidCallback onBackspace;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _LetterTextField({
    required this.focusNode,
    required this.letter,
    required this.onChanged,
    required this.onBackspace,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<_LetterTextField> createState() => _LetterTextFieldState();
}

class _LetterTextFieldState extends State<_LetterTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.letter?.toUpperCase() ?? '');
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_LetterTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.letter != oldWidget.letter) {
      _controller.text = widget.letter?.toUpperCase() ?? '';
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // No action needed here - onTap handles clearing for overtype behavior
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            if (widget.letter == null || widget.letter!.isEmpty) {
              widget.onPrevious();
            }
            widget.onBackspace();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            widget.onPrevious();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            widget.onNext();
          }
        }
      },
      child: TextField(
        focusNode: widget.focusNode,
        controller: _controller,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        maxLength: 2, // Allow 2 so formatter can replace; formatter keeps only last char
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          filled: false,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
          UpperCaseTextFormatter(),
        ],
        onTap: () {
          // Clear existing text on tap so user can type fresh (overtype behavior)
          if (_controller.text.isNotEmpty) {
            _controller.clear();
            widget.onChanged('');
          }
        },
        onChanged: (value) {
          widget.onChanged(value);
          if (value.isNotEmpty) {
            widget.onNext();
          }
        },
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
    // If user is typing a new character when there's already one, replace it
    String text = newValue.text.toUpperCase();
    if (text.length > 1) {
      // Take only the last character (the newly typed one)
      text = text.substring(text.length - 1);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
