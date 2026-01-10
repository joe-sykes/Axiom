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
            : KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.backspace) {
                      if (letter == null || letter!.isEmpty) {
                        onPrevious();
                      }
                      onBackspace();
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                      onPrevious();
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      onNext();
                    }
                  }
                },
                child: TextField(
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 1,
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
                  controller: TextEditingController(text: letter?.toUpperCase()),
                  onChanged: (value) {
                    onChanged(value);
                    if (value.isNotEmpty) {
                      onNext();
                    }
                  },
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
