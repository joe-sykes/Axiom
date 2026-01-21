import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comparison_data.dart';
import '../models/daily_scores.dart';
import '../providers/sharing_providers.dart';
import '../services/score_codec.dart';
import '../widgets/comparison_row.dart';
import '../widgets/winner_banner.dart';

/// Screen for comparing scores with a friend.
class ComparisonScreen extends ConsumerWidget {
  final String encodedData;

  const ComparisonScreen({
    super.key,
    required this.encodedData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendData = ScoreCodec.decode(encodedData);
    final myScores = ref.watch(todaysScoresProvider);
    final myProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SCORE COMPARISON'),
        centerTitle: true,
      ),
      body: _buildComparison(
        context,
        ref,
        friendData,
        myScores,
        myProfile?.displayName ?? 'YOU',
      ),
    );
  }

  Widget _buildComparison(
    BuildContext context,
    WidgetRef ref,
    ComparisonData friendData,
    DailyScores myScores,
    String myDisplayName,
  ) {
    // Check for tampered data
    if (!friendData.isValid) {
      return _buildTamperedError(context);
    }

    // Check if user has played today
    if (!myScores.isComplete) {
      return _buildIncompleteError(context, friendData);
    }

    // Calculate totals
    final myTotal = myScores.totalScore;
    final friendTotal = friendData.totalScore;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with both players
          _buildPlayersHeader(context, myDisplayName, friendData.displayName),
          const SizedBox(height: 24),

          // Per-game comparison rows
          ...GameType.values.map((game) {
            final myScore = myScores.scores[game] ?? 0;
            final friendScore = friendData.scoreForGame(game);
            return ComparisonRow(
              game: game,
              myScore: myScore,
              friendScore: friendScore,
            );
          }),

          // Total comparison
          TotalComparisonRow(
            myTotal: myTotal,
            friendTotal: friendTotal,
          ),

          // Winner banner
          WinnerBanner(
            myTotal: myTotal,
            friendTotal: friendTotal,
            myName: myDisplayName,
            friendName: friendData.playerName,
          ),

          const SizedBox(height: 24),

          // Play again button
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersHeader(
    BuildContext context,
    String myName,
    String friendName,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // My profile
          Expanded(
            child: Column(
              children: [
                Text(
                  myName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'YOU',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // VS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'VS',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          // Friend profile
          Expanded(
            child: Column(
              children: [
                Text(
                  friendName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'FRIEND',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTamperedError(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Looks like you\'ve tampered with this, insecure?!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'The share code appears to be invalid or modified.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncompleteError(BuildContext context, ComparisonData friendData) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pending_actions,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Complete Today\'s Puzzles First!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '${friendData.displayName} is waiting to compare scores with you.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Finish all 5 puzzles to see who\'s the champion!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Go Play!'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
