import 'package:flutter/material.dart';

class FiftyFiftyButton extends StatelessWidget {
  final bool isUsed;
  final VoidCallback? onTap;

  const FiftyFiftyButton({
    super.key,
    required this.isUsed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: isUsed ? '50/50 already used' : 'Remove 2 wrong answers',
      child: Material(
        color: isUsed
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isUsed ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUsed
                    ? theme.colorScheme.outline.withValues(alpha: 0.3)
                    : theme.colorScheme.secondary,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.looks_two,
                  color: isUsed
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                      : theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  '50/50',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isUsed
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isUsed) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
