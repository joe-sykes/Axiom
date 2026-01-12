import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A Wordle-style on-screen keyboard for game input
class GameKeyboard extends StatelessWidget {
  final void Function(String letter) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onEnter;
  final bool showEnter;
  final String enterLabel;

  const GameKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    this.onEnter,
    this.showEnter = true,
    this.enterLabel = 'ENTER',
  });

  static const _row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  static const _row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  static const _row3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
            _buildRow(context, _row1),
            const SizedBox(height: 6),
            _buildRow(context, _row2),
            const SizedBox(height: 6),
            _buildBottomRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<String> letters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters
          .map((letter) => _KeyButton(
                label: letter,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onKeyPressed(letter);
                },
              ))
          .toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showEnter)
          _KeyButton(
            label: enterLabel,
            isWide: true,
            onTap: onEnter != null
                ? () {
                    HapticFeedback.mediumImpact();
                    onEnter!();
                  }
                : null,
          ),
        ..._row3.map((letter) => _KeyButton(
              label: letter,
              onTap: () {
                HapticFeedback.lightImpact();
                onKeyPressed(letter);
              },
            )),
        _KeyButton(
          icon: Icons.backspace_outlined,
          isWide: true,
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
  final VoidCallback? onTap;

  const _KeyButton({
    this.label,
    this.icon,
    this.isWide = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: onTap == null
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade400)
            : (isDark ? Colors.grey.shade700 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: BoxConstraints(
              minWidth: isWide ? 52 : 32,
              minHeight: 48,
            ),
            padding: EdgeInsets.symmetric(horizontal: isWide ? 8 : 4),
            alignment: Alignment.center,
            child: icon != null
                ? Icon(
                    icon,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black87,
                  )
                : Text(
                    label ?? '',
                    style: TextStyle(
                      fontSize: isWide ? 11 : 15,
                      fontWeight: FontWeight.bold,
                      color: onTap == null
                          ? (isDark ? Colors.grey.shade500 : Colors.grey.shade600)
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
