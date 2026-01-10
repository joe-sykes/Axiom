import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';
import '../models/game_result.dart';
import '../models/user_stats.dart';

/// Service for local storage operations
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ============ Stats ============

  /// Load user stats from local storage
  UserStats loadStats() {
    final json = _prefs.getString(AppConstants.statsKey);
    if (json == null) return const UserStats();

    try {
      return UserStats.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      return const UserStats();
    }
  }

  /// Save user stats to local storage
  Future<void> saveStats(UserStats stats) async {
    await _prefs.setString(AppConstants.statsKey, jsonEncode(stats.toJson()));
  }

  // ============ Streak Logic ============

  /// Record completion of today's daily puzzle
  Future<UserStats> recordDailyPuzzleCompletion({
    required int puzzleIndex,
    required int score,
    required bool wasSuccessful,
    required Duration timeTaken,
    required int incorrectAttempts,
  }) async {
    final stats = loadStats();
    final today = DateTime.now();
    final todayDate = DateTime.utc(today.year, today.month, today.day);

    // Check if streak should continue or reset
    int newStreak = stats.currentStreak;

    if (stats.lastCompletedDate != null) {
      final lastDate = DateTime.utc(
        stats.lastCompletedDate!.year,
        stats.lastCompletedDate!.month,
        stats.lastCompletedDate!.day,
      );
      final daysDiff = todayDate.difference(lastDate).inDays;

      if (daysDiff == 0) {
        // Already completed today - no streak change
      } else if (daysDiff == 1 && wasSuccessful) {
        // Consecutive day - increment streak
        newStreak = stats.currentStreak + 1;
      } else if (daysDiff > 1) {
        // Missed days - reset streak
        newStreak = wasSuccessful ? 1 : 0;
      }
    } else if (wasSuccessful) {
      // First ever completion
      newStreak = 1;
    }

    // Create result record
    final result = GameResult(
      puzzleIndex: puzzleIndex,
      playedAt: DateTime.now(),
      wasSuccessful: wasSuccessful,
      score: score,
      timeTaken: timeTaken,
      incorrectAttempts: incorrectAttempts,
      wasDailyPuzzle: true,
    );

    // Update stats
    final newStats = stats.copyWith(
      currentStreak: newStreak,
      longestStreak: max(stats.longestStreak, newStreak),
      lastCompletedPuzzleIndex: puzzleIndex,
      lastCompletedDate: todayDate,
      history: [...stats.history, result],
      totalGamesPlayed: stats.totalGamesPlayed + 1,
      totalGamesWon: stats.totalGamesWon + (wasSuccessful ? 1 : 0),
    );

    await saveStats(newStats);
    return newStats;
  }

  /// Record completion of an archive puzzle (does NOT affect streak)
  Future<UserStats> recordArchivePuzzleCompletion({
    required int puzzleIndex,
    required int score,
    required bool wasSuccessful,
    required Duration timeTaken,
    required int incorrectAttempts,
  }) async {
    final stats = loadStats();

    // Archive puzzles don't affect streak!
    final result = GameResult(
      puzzleIndex: puzzleIndex,
      playedAt: DateTime.now(),
      wasSuccessful: wasSuccessful,
      score: score,
      timeTaken: timeTaken,
      incorrectAttempts: incorrectAttempts,
      wasDailyPuzzle: false,
    );

    final newStats = stats.copyWith(
      history: [...stats.history, result],
      totalGamesPlayed: stats.totalGamesPlayed + 1,
      totalGamesWon: stats.totalGamesWon + (wasSuccessful ? 1 : 0),
    );

    await saveStats(newStats);
    return newStats;
  }

  /// Check if daily streak should be reset due to missed day
  Future<bool> checkAndResetStreakIfNeeded() async {
    final stats = loadStats();

    if (stats.lastCompletedDate == null || stats.currentStreak == 0) {
      return false;
    }

    final todayUtc = PuzzleDateUtils.todayUtc;
    final lastDate = DateTime.utc(
      stats.lastCompletedDate!.year,
      stats.lastCompletedDate!.month,
      stats.lastCompletedDate!.day,
    );

    final daysDiff = todayUtc.difference(lastDate).inDays;

    if (daysDiff > 1) {
      // Missed at least one day - reset streak
      final newStats = stats.copyWith(currentStreak: 0);
      await saveStats(newStats);
      return true;
    }

    return false;
  }

  /// Check if user has completed today's puzzle
  bool hasCompletedTodaysPuzzle() {
    final stats = loadStats();

    if (stats.lastCompletedDate == null) return false;

    final todayUtc = PuzzleDateUtils.todayUtc;
    final lastCompletedUtc = DateTime.utc(
      stats.lastCompletedDate!.year,
      stats.lastCompletedDate!.month,
      stats.lastCompletedDate!.day,
    );

    return todayUtc.isAtSameMomentAs(lastCompletedUtc);
  }

  /// Get result for a specific puzzle (if played)
  GameResult? getResultForPuzzle(int puzzleIndex) {
    final stats = loadStats();
    try {
      return stats.history.lastWhere((r) => r.puzzleIndex == puzzleIndex);
    } catch (_) {
      return null;
    }
  }

  // ============ Theme ============

  /// Get saved theme mode
  ThemeMode? getThemeMode() {
    final value = _prefs.getString(AppConstants.themeModeKey);
    if (value == null) return null;

    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Save theme mode preference
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(AppConstants.themeModeKey, value);
  }

  // ============ First-time User ============

  /// Check if user has seen the help dialog
  bool hasSeenHelp() {
    return _prefs.getBool(AppConstants.hasSeenHelpKey) ?? false;
  }

  /// Mark that user has seen the help dialog
  Future<void> markHelpAsSeen() async {
    await _prefs.setBool(AppConstants.hasSeenHelpKey, true);
  }
}
