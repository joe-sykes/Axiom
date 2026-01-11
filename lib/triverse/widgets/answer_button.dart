import 'package:flutter/material.dart';
import '../../core/theme/axiom_theme.dart';

enum AnswerButtonState { normal, selected, correct, incorrect, disabled }

class AnswerButton extends StatelessWidget {
  final String text;
  final int index;
  final AnswerButtonState state;
  final bool isHidden;
  final VoidCallback? onTap;

  const AnswerButton({
    super.key,
    required this.text,
    required this.index,
    required this.state,
    this.isHidden = false,
    this.onTap,
  });

  String get _label => String.fromCharCode(65 + index); // A, B, C, D

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    switch (state) {
      case AnswerButtonState.normal:
        backgroundColor = theme.colorScheme.surface;
        borderColor = theme.colorScheme.outline;
        textColor = theme.colorScheme.onSurface;
        break;
      case AnswerButtonState.selected:
        backgroundColor = theme.colorScheme.primaryContainer;
        borderColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.onPrimaryContainer;
        break;
      case AnswerButtonState.correct:
        backgroundColor = isDark
            ? AxiomColors.successDark.withValues(alpha: 0.2)
            : AxiomColors.success.withValues(alpha: 0.2);
        borderColor = isDark ? AxiomColors.successDark : AxiomColors.success;
        textColor = isDark ? AxiomColors.successDark : AxiomColors.success;
        break;
      case AnswerButtonState.incorrect:
        backgroundColor = theme.colorScheme.errorContainer;
        borderColor = theme.colorScheme.error;
        textColor = theme.colorScheme.onErrorContainer;
        break;
      case AnswerButtonState.disabled:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        borderColor = theme.colorScheme.outline.withValues(alpha: 0.3);
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: state == AnswerButtonState.disabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      fontWeight: state == AnswerButtonState.selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (state == AnswerButtonState.correct)
                  Icon(Icons.check_circle, color: borderColor),
                if (state == AnswerButtonState.incorrect)
                  Icon(Icons.cancel, color: borderColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
