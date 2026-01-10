import 'package:flutter/material.dart';

import '../models/user_stats.dart';
import 'stat_item.dart';

class StatsCard extends StatelessWidget {
  final UserStats stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your statistics',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Your Stats',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatItem(
                    icon: Icons.local_fire_department,
                    value: '${stats.currentStreak}',
                    label: 'Streak',
                    color: Colors.orange,
                  ),
                  StatItem(
                    icon: Icons.emoji_events,
                    value: '${stats.longestStreak}',
                    label: 'Best',
                    color: Colors.amber,
                  ),
                  StatItem(
                    icon: Icons.games,
                    value: '${stats.totalGamesPlayed}',
                    label: 'Played',
                    color: Colors.blue,
                  ),
                  StatItem(
                    icon: Icons.percent,
                    value: '${stats.winPercentage.toStringAsFixed(0)}%',
                    label: 'Win Rate',
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
