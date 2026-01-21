import 'package:flutter/material.dart';

/// The five puzzle games in Axiom.
enum GameType {
  almanac,
  cryptix,
  cryptogram,
  doublet,
  triverse;

  /// Display name for the game.
  String get displayName {
    switch (this) {
      case GameType.almanac:
        return 'ALMANAC';
      case GameType.cryptix:
        return 'CRYPTIX';
      case GameType.cryptogram:
        return 'CRYPTOGRAM';
      case GameType.doublet:
        return 'DOUBLET';
      case GameType.triverse:
        return 'TRIVERSE';
    }
  }

  /// Icon for the game.
  IconData get icon {
    switch (this) {
      case GameType.almanac:
        return Icons.lightbulb_outline;
      case GameType.cryptix:
        return Icons.quiz_outlined;
      case GameType.cryptogram:
        return Icons.lock_outline;
      case GameType.doublet:
        return Icons.linear_scale;
      case GameType.triverse:
        return Icons.bolt;
    }
  }

  /// Accent color for the game.
  Color get color {
    switch (this) {
      case GameType.almanac:
        return const Color(0xFF00B8B5); // Cyan
      case GameType.cryptix:
        return const Color(0xFF3498DB); // Blue
      case GameType.cryptogram:
        return const Color(0xFFE74C3C); // Red
      case GameType.doublet:
        return Colors.indigo;
      case GameType.triverse:
        return const Color(0xFF9B59B6); // Purple
    }
  }
}

/// Aggregated daily scores for all games.
class DailyScores {
  /// The date these scores are for.
  final DateTime date;

  /// Scores for each game. Null means not completed.
  final Map<GameType, int?> scores;

  const DailyScores({
    required this.date,
    required this.scores,
  });

  /// Number of games completed.
  int get completedCount =>
      scores.values.where((score) => score != null).length;

  /// Whether all games are completed.
  bool get isComplete => completedCount == GameType.values.length;

  /// Total score across all completed games.
  int get totalScore =>
      scores.values.whereType<int>().fold(0, (sum, score) => sum + score);

  /// Maximum possible total score.
  int get maxTotalScore => GameType.values.length * 100;

  /// Get score for a specific game (null if not completed).
  int? scoreFor(GameType game) => scores[game];

  /// Get scores as ordered list (0 for incomplete games).
  List<int> get scoreList =>
      GameType.values.map((game) => scores[game] ?? 0).toList();

  /// Get scores as ordered list (null for incomplete games).
  List<int?> get nullableScoreList =>
      GameType.values.map((game) => scores[game]).toList();

  /// Create an empty scores object for today.
  factory DailyScores.empty() => DailyScores(
        date: DateTime.now(),
        scores: {for (final game in GameType.values) game: null},
      );

  @override
  String toString() =>
      'DailyScores(date: ${date.toIso8601String().split('T')[0]}, '
      'completed: $completedCount/${GameType.values.length}, '
      'total: $totalScore)';
}
