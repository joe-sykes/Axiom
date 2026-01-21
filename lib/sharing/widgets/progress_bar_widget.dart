import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_scores.dart';
import '../providers/sharing_providers.dart';
import 'share_options_panel.dart';

/// Progress bar showing daily puzzle completion status.
///
/// Shows X/5 progress when incomplete, transforms to share options when all complete.
class DailyProgressBar extends ConsumerWidget {
  const DailyProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(todaysScoresProvider);
    return _buildContent(context, ref, scores);
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, DailyScores scores) {
    final theme = Theme.of(context);
    final totalGames = GameType.values.length;
    final completedCount = scores.completedCount;
    final isComplete = scores.isComplete;

    // When all complete, show share options
    if (isComplete) {
      return ShareOptionsPanel(scores: scores);
    }

    // Otherwise show progress bar
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY'S PROGRESS",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/$totalGames',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completedCount / totalGames,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                _getProgressColor(completedCount, totalGames, theme),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEncouragementMessage(completedCount, totalGames),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int completed, int total, ThemeData theme) {
    final progress = completed / total;
    if (progress >= 1.0) {
      return Colors.green;
    } else if (progress >= 0.6) {
      return Colors.amber;
    } else if (progress >= 0.2) {
      return theme.colorScheme.primary;
    }
    return theme.colorScheme.primary.withOpacity(0.7);
  }

  String _getEncouragementMessage(int completed, int total) {
    if (completed == 0) {
      return 'Start your puzzle journey today!';
    } else if (completed == 1) {
      return 'Great start! ${total - completed} more to go.';
    } else if (completed == 2) {
      return 'Nice progress! Keep it up.';
    } else if (completed == 3) {
      return 'More than halfway there!';
    } else if (completed == 4) {
      return 'Almost there! Just one more.';
    }
    return 'All complete!';
  }
}
