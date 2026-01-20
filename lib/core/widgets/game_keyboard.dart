import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A Wordle-style on-screen keyboard for game input
class GameKeyboard extends StatelessWidget {
  final void Function(String letter) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onEnter;
  final bool showEnter;
  final String enterLabel;
  /// Letters that have been used/assigned (shown greyed out)
  final Set<String> usedLetters;
  /// Letters that have been revealed via hints (shown with strikethrough)
  final Set<String> revealedLetters;

  const GameKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    this.onEnter,
    this.showEnter = true,
    this.enterLabel = 'ENTER',
    this.usedLetters = const {},
    this.revealedLetters = const {},
  });

  static const _numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  static const _row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  static const _row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  static const _row3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Use compact layout for small screens (iPhone SE, etc.)
    final isCompact = screenHeight < 700;
    final rowSpacing = isCompact ? 4.0 : 6.0;
    final verticalPadding = isCompact ? 5.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900
            : Colors.grey.shade200,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(context, _numbers, isCompact),
            SizedBox(height: rowSpacing),
            _buildRow(context, _row1, isCompact),
            SizedBox(height: rowSpacing),
            _buildRow(context, _row2, isCompact),
            SizedBox(height: rowSpacing),
            _buildBottomRow(context, isCompact),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<String> letters, bool isCompact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters
          .map((letter) => _KeyButton(
                label: letter,
                isCompact: isCompact,
                isUsed: usedLetters.contains(letter.toUpperCase()),
                isRevealed: revealedLetters.contains(letter.toUpperCase()),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onKeyPressed(letter);
                },
              ))
          .toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context, bool isCompact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showEnter)
          _KeyButton(
            label: enterLabel,
            isWide: true,
            isCompact: isCompact,
            onTap: onEnter != null
                ? () {
                    HapticFeedback.mediumImpact();
                    onEnter!();
                  }
                : null,
          ),
        ..._row3.map((letter) => _KeyButton(
              label: letter,
              isCompact: isCompact,
              isUsed: usedLetters.contains(letter.toUpperCase()),
              isRevealed: revealedLetters.contains(letter.toUpperCase()),
              onTap: () {
                HapticFeedback.lightImpact();
                onKeyPressed(letter);
              },
            )),
        _KeyButton(
          icon: Icons.backspace_outlined,
          isWide: true,
          isCompact: isCompact,
          onTap: () {
            HapticFeedback.lightImpact();
            onBackspace();
          },
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isWide;
  final bool isCompact;
  final bool isUsed;
  final bool isRevealed;
  final VoidCallback? onTap;

  const _KeyButton({
    this.label,
    this.icon,
    this.isWide = false,
    this.isCompact = false,
    this.isUsed = false,
    this.isRevealed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final minHeight = isCompact ? 40.0 : 48.0;
    final minWidth = isWide ? (isCompact ? 46.0 : 52.0) : (isCompact ? 29.0 : 32.0);
    final fontSize = isWide ? (isCompact ? 10.0 : 11.0) : (isCompact ? 13.0 : 15.0);
    final iconSize = isCompact ? 18.0 : 20.0;

    // Determine colors based on state
    Color backgroundColor;
    Color textColor;

    if (isRevealed) {
      // Revealed letters - subtle color to indicate they're "locked in"
      backgroundColor = isDark ? Colors.green.shade900 : Colors.green.shade100;
      textColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
    } else if (isUsed) {
      // Used letters - greyed out
      backgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade400;
      textColor = isDark ? Colors.grey.shade600 : Colors.grey.shade500;
    } else if (onTap == null) {
      backgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade400;
      textColor = isDark ? Colors.grey.shade500 : Colors.grey.shade600;
    } else {
      backgroundColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
      textColor = isDark ? Colors.white : Colors.black87;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 1.5 : 2),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: BoxConstraints(
              minWidth: minWidth,
              minHeight: minHeight,
            ),
            padding: EdgeInsets.symmetric(horizontal: isWide ? (isCompact ? 7 : 8) : (isCompact ? 3 : 4)),
            alignment: Alignment.center,
            child: icon != null
                ? Icon(
                    icon,
                    size: iconSize,
                    color: isDark ? Colors.white : Colors.black87,
                  )
                : Text(
                    label ?? '',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      decoration: isRevealed ? TextDecoration.lineThrough : null,
                      decorationColor: textColor,
                      decorationThickness: 2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
