import 'package:flutter/material.dart';

/// A stats bar widget showing streak, played, and win rate
/// Used at the bottom of puzzle screens when stats are available
class StatsBar extends StatelessWidget {
  final int? streak;
  final int? played;
  final int? winRate; // percentage 0-100
  final int? totalScore;

  const StatsBar({
    super.key,
    this.streak,
    this.played,
    this.winRate,
    this.totalScore,
  });

  /// Returns true if any stat is available
  bool get hasStats => streak != null || played != null || winRate != null || totalScore != null;

  @override
  Widget build(BuildContext context) {
    if (!hasStats) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (streak != null)
            _StatItem(
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
              value: '$streak',
              label: 'Streak',
            ),
          if (played != null)
            _StatItem(
              icon: Icons.grid_view,
              iconColor: theme.colorScheme.primary,
              value: '$played',
              label: 'Played',
            ),
          if (winRate != null)
            _StatItem(
              icon: Icons.percent,
              iconColor: Colors.green,
              value: '$winRate%',
              label: 'Win Rate',
            ),
          if (totalScore != null)
            _StatItem(
              icon: Icons.star,
              iconColor: Colors.amber,
              value: '$totalScore',
              label: 'Total Score',
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
