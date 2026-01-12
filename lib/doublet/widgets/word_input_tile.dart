import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/game_validator.dart';

class WordInputTile extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int wordLength;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final GameValidator validator;
  final int stepNumber;
  final bool useCustomKeyboard;

  const WordInputTile({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.wordLength,
    required this.onChanged,
    required this.onSubmitted,
    required this.validator,
    required this.stepNumber,
    this.useCustomKeyboard = false,
  });

  @override
  State<WordInputTile> createState() => _WordInputTileState();
}

class _WordInputTileState extends State<WordInputTile> {
  WordValidationResult? _validationResult;
  bool _hasBeenEdited = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    _hasBeenEdited = text.isNotEmpty;

    // Validate if we have a complete word
    if (text.length == widget.wordLength) {
      setState(() {
        _validationResult = widget.validator.validateWord(text, widget.wordLength);
      });
    } else {
      setState(() {
        _validationResult = null;
      });
    }

    widget.onChanged(text);
  }

  Color? _getBorderColor() {
    if (_validationResult == null) return null;
    return _validationResult!.isValid ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ?? Theme.of(context).colorScheme.outline,
          width: borderColor != null ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Step number
          Container(
            width: 40,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
            ),
            child: Text(
              '${widget.stepNumber}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Text input - wrapped in AutofillGroup to prevent autofill suggestions
          Expanded(
            child: widget.useCustomKeyboard
                ? GestureDetector(
                    onTap: () => widget.focusNode.requestFocus(),
                    child: AbsorbPointer(
                      child: AutofillGroup(
                        onDisposeAction: AutofillContextAction.cancel,
                        child: TextField(
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: widget.wordLength,
                          textAlign: TextAlign.center,
                          autocorrect: false,
                          enableSuggestions: false,
                          enableIMEPersonalizedLearning: false,
                          autofillHints: null,
                          readOnly: true,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          keyboardType: TextInputType.none,
                          textInputAction: TextInputAction.next,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                letterSpacing: 4,
                                fontWeight: FontWeight.bold,
                              ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            hintText: '·' * widget.wordLength,
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              letterSpacing: 8,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : AutofillGroup(
                    onDisposeAction: AutofillContextAction.cancel,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: widget.wordLength,
                      textAlign: TextAlign.center,
                      autocorrect: false,
                      enableSuggestions: false,
                      enableIMEPersonalizedLearning: false,
                      autofillHints: null,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                          ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        hintText: '·' * widget.wordLength,
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          letterSpacing: 8,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                        UpperCaseTextFormatter(),
                      ],
                      onSubmitted: (_) => widget.onSubmitted(),
                    ),
                  ),
          ),

          // Validation indicator
          Container(
            width: 40,
            padding: const EdgeInsets.all(8),
            child: _validationResult != null
                ? Tooltip(
                    message: _validationResult!.isValid
                        ? 'Valid word (may not be the correct answer)'
                        : 'Not a valid word',
                    child: Icon(
                      _validationResult!.isValid
                          ? Icons.check_circle
                          : Icons.error,
                      color: _validationResult!.isValid
                          ? Colors.green
                          : Colors.red,
                      size: 24,
                      semanticLabel: _validationResult!.isValid
                          ? 'Word is valid'
                          : 'Word is not in dictionary',
                    ),
                  )
                : _hasBeenEdited
                    ? Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.outline,
                        size: 20,
                        semanticLabel: 'Editing',
                      )
                    : const SizedBox(width: 24),
          ),
        ],
      ),
    );
  }
}

/// Converts text to uppercase as user types
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
