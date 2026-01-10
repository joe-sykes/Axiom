import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import '../../core/theme/axiom_theme.dart';

class ClueDisplay extends StatelessWidget {
  final CryptixPuzzle puzzle;
  final bool showHint;

  const ClueDisplay({
    super.key,
    required this.puzzle,
    this.showHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Clue text with optional highlighting
            Semantics(
              label: 'Cryptic clue: ${puzzle.clue}',
              child: _buildClueText(context),
            ),

            // Hint indicator
            if (showHint) ...[
              const SizedBox(height: 16),
              _buildHintIndicator(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClueText(BuildContext context) {
    final theme = Theme.of(context);
    final clue = puzzle.clue;

    if (!showHint) {
      return Text(
        clue,
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          height: 1.5,
        ),
      );
    }

    // Check if we can highlight the definition
    if (puzzle.matchesDefinitionInClue()) {
      return _buildHighlightedClue(context);
    }

    // Double definition - show clue without highlighting
    return Text(
      clue,
      textAlign: TextAlign.center,
      style: theme.textTheme.headlineSmall?.copyWith(
        height: 1.5,
      ),
    );
  }

  Widget _buildHighlightedClue(BuildContext context) {
    final theme = Theme.of(context);
    final clue = puzzle.clue;
    final definition = puzzle.definitionSegment;

    final lowerClue = clue.toLowerCase();
    final lowerDefinition = definition.toLowerCase();
    final startIndex = lowerClue.indexOf(lowerDefinition);

    if (startIndex == -1) {
      return Text(
        clue,
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          height: 1.5,
        ),
      );
    }

    final endIndex = startIndex + definition.length;
    final beforeHint = clue.substring(0, startIndex);
    final hintText = clue.substring(startIndex, endIndex);
    final afterHint = clue.substring(endIndex);

    final isDark = theme.brightness == Brightness.dark;

    return Text.rich(
      TextSpan(
        style: theme.textTheme.headlineSmall?.copyWith(
          height: 1.5,
        ),
        children: [
          if (beforeHint.isNotEmpty) TextSpan(text: beforeHint),
          TextSpan(
            text: hintText,
            style: TextStyle(
              backgroundColor: isDark
                  ? AxiomColors.hintHighlight.withValues(alpha: 0.3)
                  : AxiomColors.hintHighlight.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (afterHint.isNotEmpty) TextSpan(text: afterHint),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildHintIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (puzzle.isDoubleDefinition) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (isDark ? AxiomColors.accentDark : AxiomColors.accent)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AxiomColors.accentDark : AxiomColors.accent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: isDark ? AxiomColors.accentDark : AxiomColors.accent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'This is a double definition clue. The answer satisfies both parts: "${puzzle.definitions.join('" and "')}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AxiomColors.accentDark : AxiomColors.accent,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (puzzle.matchesDefinitionInClue()) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AxiomColors.hintHighlight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AxiomColors.hintHighlight,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lightbulb,
              color: Color(0xFFF9A825),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'The highlighted text is the definition part of the clue.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFF9A825),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
