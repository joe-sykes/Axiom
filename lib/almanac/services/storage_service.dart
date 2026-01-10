import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage of puzzle completion data and streaks
class StorageService {
  static const String _completedPuzzlesKey = 'completed_puzzles';
  static const String _puzzleScoresKey = 'puzzle_scores';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get list of completed puzzle dates
  Future<Set<String>> getCompletedPuzzles() async {
    final p = await prefs;
    final List<String> completed = p.getStringList(_completedPuzzlesKey) ?? [];
    return completed.toSet();
  }

  /// Mark a puzzle as completed and store its score
  Future<void> markPuzzleCompleted(String date, int score) async {
    final p = await prefs;
    final completed = await getCompletedPuzzles();
    completed.add(date);
    await p.setStringList(_completedPuzzlesKey, completed.toList());

    // Store score
    final scores = await getPuzzleScores();
    scores[date] = score;
    await p.setString(_puzzleScoresKey, jsonEncode(scores));
  }

  /// Check if a puzzle is completed
  Future<bool> isPuzzleCompleted(String date) async {
    final completed = await getCompletedPuzzles();
    return completed.contains(date);
  }

  /// Get puzzle scores map
  Future<Map<String, int>> getPuzzleScores() async {
    final p = await prefs;
    final String? scoresJson = p.getString(_puzzleScoresKey);
    if (scoresJson == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(scoresJson);
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  /// Get score for a specific puzzle
  Future<int?> getScoreForPuzzle(String date) async {
    final scores = await getPuzzleScores();
    return scores[date];
  }

  /// Calculate the current streak (consecutive days of puzzle completion)
  Future<int> calculateStreak() async {
    final completed = await getCompletedPuzzles();
    if (completed.isEmpty) return 0;

    // Sort dates in descending order (most recent first)
    final sortedDates = completed.toList()
      ..sort((a, b) => b.compareTo(a));

    // Get today's date in the same format
    final now = DateTime.now().toUtc();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Check if today's puzzle is completed
    if (!sortedDates.contains(today)) {
      // Check if yesterday's puzzle is completed (streak can continue from yesterday)
      final yesterday = DateTime.now().toUtc().subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      if (!sortedDates.contains(yesterdayStr)) {
        return 0; // Streak is broken
      }
    }

    // Count consecutive days
    int streak = 0;
    DateTime currentDate = now;

    // If today isn't completed, start from yesterday
    if (!sortedDates.contains(today)) {
      currentDate = now.subtract(const Duration(days: 1));
    }

    while (true) {
      final dateStr = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      if (sortedDates.contains(dateStr)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
