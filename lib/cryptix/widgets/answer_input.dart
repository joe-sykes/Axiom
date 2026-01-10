import 'package:flutter/material.dart';
import 'letter_box.dart';

class AnswerInput extends StatefulWidget {
  final int length;
  final bool isLocked;
  final bool isCorrect;
  final Function(String) onSubmit;
  final String? correctAnswer;

  const AnswerInput({
    super.key,
    required this.length,
    this.isLocked = false,
    this.isCorrect = false,
    required this.onSubmit,
    this.correctAnswer,
  });

  @override
  State<AnswerInput> createState() => _AnswerInputState();
}

class _AnswerInputState extends State<AnswerInput> {
  late List<String> _letters;
  late List<FocusNode> _focusNodes;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    if (widget.isCorrect && widget.correctAnswer != null) {
      _letters = widget.correctAnswer!.toUpperCase().split('');
    } else {
      _letters = List.filled(widget.length, '');
    }
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(AnswerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length ||
        oldWidget.isCorrect != widget.isCorrect) {
      _disposeNodes();
      _initializeState();
    }
  }

  void _disposeNodes() {
    for (final node in _focusNodes) {
      node.dispose();
    }
  }

  @override
  void dispose() {
    _disposeNodes();
    super.dispose();
  }

  String get currentAnswer => _letters.join();

  void _onLetterChanged(int index, String value) {
    setState(() {
      _letters[index] = value.toUpperCase();
    });
  }

  void _onBackspace(int index) {
    setState(() {
      _letters[index] = '';
    });
  }

  void _focusNext(int currentIndex) {
    if (currentIndex < widget.length - 1) {
      setState(() {
        _focusedIndex = currentIndex + 1;
      });
      _focusNodes[currentIndex + 1].requestFocus();
    }
  }

  void _focusPrevious(int currentIndex) {
    if (currentIndex > 0) {
      setState(() {
        _focusedIndex = currentIndex - 1;
      });
      _focusNodes[currentIndex - 1].requestFocus();
    }
  }

  void _handleSubmit() {
    final answer = currentAnswer;
    if (answer.length == widget.length) {
      widget.onSubmit(answer);
    }
  }

  void _clearAll() {
    setState(() {
      _letters = List.filled(widget.length, '');
      _focusedIndex = 0;
    });
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Letter boxes
        Semantics(
          label: 'Answer input, ${widget.length} letters',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.length, (index) {
                return GestureDetector(
                  onTap: widget.isLocked
                      ? null
                      : () {
                          setState(() {
                            _focusedIndex = index;
                          });
                          _focusNodes[index].requestFocus();
                        },
                  child: LetterBox(
                    index: index,
                    letter: _letters[index],
                    isFocused: _focusedIndex == index && !widget.isLocked,
                    isCorrect: widget.isCorrect,
                    isLocked: widget.isLocked,
                    focusNode: _focusNodes[index],
                    onChanged: (value) => _onLetterChanged(index, value),
                    onBackspace: () => _onBackspace(index),
                    onNext: () => _focusNext(index),
                    onPrevious: () => _focusPrevious(index),
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Letter count indicator
        Text(
          '(${widget.length} letters)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
          semanticsLabel: '${widget.length} letters',
        ),

        const SizedBox(height: 24),

        // Action buttons
        if (!widget.isLocked)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: currentAnswer.length == widget.length
                    ? _handleSubmit
                    : null,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Submit'),
              ),
            ],
          ),
      ],
    );
  }
}
