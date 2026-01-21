import 'package:flutter/material.dart';

import '../models/daily_scores.dart';

/// A row showing score comparison for a single game.
class ComparisonRow extends StatelessWidget {
  final GameType game;
  final int myScore;
  final int friendScore;

  const ComparisonRow({
    super.key,
    required this.game,
    required this.myScore,
    required this.friendScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iWin = myScore > friendScore;
    final friendWins = friendScore > myScore;
    final isTie = myScore == friendScore;

    final highlightColor = isTie
        ? theme.colorScheme.outline
        : (iWin ? Colors.green : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlightColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // My score (left)
          Expanded(
            child: Row(
              children: [
                if (iWin)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.arrow_left,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                Text(
                  '$myScore',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: iWin ? FontWeight.bold : FontWeight.normal,
                    color: iWin ? Colors.green : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Game info (center)
          Column(
            children: [
              Icon(
                game.icon,
                color: game.color,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                game.displayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Friend score (right)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$friendScore',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: friendWins ? FontWeight.bold : FontWeight.normal,
                    color: friendWins ? Colors.orange : theme.colorScheme.onSurface,
                  ),
                ),
                if (friendWins)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.arrow_right,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Row showing total score comparison.
class TotalComparisonRow extends StatelessWidget {
  final int myTotal;
  final int friendTotal;

  const TotalComparisonRow({
    super.key,
    required this.myTotal,
    required this.friendTotal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iWin = myTotal > friendTotal;
    final friendWins = friendTotal > myTotal;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // My total (left)
          Expanded(
            child: Column(
              children: [
                Text(
                  '$myTotal',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iWin ? Colors.green : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Label (center)
          Column(
            children: [
              Icon(
                Icons.functions,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                'TOTAL',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          // Friend total (right)
          Expanded(
            child: Column(
              children: [
                Text(
                  '$friendTotal',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: friendWins ? Colors.orange : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
