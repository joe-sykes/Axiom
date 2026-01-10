import 'dart:math';
import 'game_result.dart';

/// Local user statistics
class UserStats {
  final int currentStreak;
  final int longestStreak;
  final int? lastCompletedPuzzleIndex;
  final DateTime? lastCompletedDate;
  final List<GameResult> history;
  final int totalGamesPlayed;
  final int totalGamesWon;

  const UserStats({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedPuzzleIndex,
    this.lastCompletedDate,
    this.history = const [],
    this.totalGamesPlayed = 0,
    this.totalGamesWon = 0,
  });

  /// Average score across all games
  double get averageScore {
    if (history.isEmpty) return 0;
    final total = history.fold<int>(0, (sum, r) => sum + r.score);
    return total / history.length;
  }

  /// Win percentage
  double get winPercentage {
    if (totalGamesPlayed == 0) return 0;
    return (totalGamesWon / totalGamesPlayed) * 100;
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedPuzzleIndex: json['lastCompletedPuzzleIndex'] as int?,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => GameResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      totalGamesWon: json['totalGamesWon'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastCompletedPuzzleIndex': lastCompletedPuzzleIndex,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
        'history': history.map((e) => e.toJson()).toList(),
        'totalGamesPlayed': totalGamesPlayed,
        'totalGamesWon': totalGamesWon,
      };

  UserStats copyWith({
    int? currentStreak,
    int? longestStreak,
    int? lastCompletedPuzzleIndex,
    DateTime? lastCompletedDate,
    List<GameResult>? history,
    int? totalGamesPlayed,
    int? totalGamesWon,
  }) {
    return UserStats(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: max(
        longestStreak ?? this.longestStreak,
        currentStreak ?? this.currentStreak,
      ),
      lastCompletedPuzzleIndex:
          lastCompletedPuzzleIndex ?? this.lastCompletedPuzzleIndex,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      history: history ?? this.history,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalGamesWon: totalGamesWon ?? this.totalGamesWon,
    );
  }
}
