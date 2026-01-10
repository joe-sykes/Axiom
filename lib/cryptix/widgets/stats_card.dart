import 'package:flutter/material.dart';
import '../models/user_stats.dart';

class StatsCard extends StatelessWidget {
  final CryptixUserStats stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Statistics',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatTile(
                  value: '${stats.currentStreak}',
                  label: 'Current\nStreak',
                  icon: Icons.local_fire_department,
                ),
                _StatTile(
                  value: '${stats.bestStreak}',
                  label: 'Best\nStreak',
                  icon: Icons.emoji_events,
                ),
                _StatTile(
                  value: '${stats.totalSolved}',
                  label: 'Puzzles\nSolved',
                  icon: Icons.check_circle,
                ),
                _StatTile(
                  value: stats.averageScore.toStringAsFixed(0),
                  label: 'Average\nScore',
                  icon: Icons.analytics,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${label.replaceAll('\n', ' ')}: $value',
      child: Column(
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
