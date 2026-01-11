import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage of Triverse completion data and streaks.
class TriverseStorageService {
  static const String _completedPuzzlesKey = 'triverse_completed_puzzles';
  static const String _puzzleScoresKey = 'triverse_puzzle_scores';
  static const String _hasSeenHelpKey = 'triverse_has_seen_help';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get list of completed puzzle dates.
  Future<Set<String>> getCompletedPuzzles() async {
    final p = await prefs;
    final List<String> completed = p.getStringList(_completedPuzzlesKey) ?? [];
    return completed.toSet();
  }

  /// Mark a puzzle as completed and store its score.
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

  /// Check if a puzzle is completed.
  Future<bool> isPuzzleCompleted(String date) async {
    final completed = await getCompletedPuzzles();
    return completed.contains(date);
  }

  /// Get puzzle scores map.
  Future<Map<String, int>> getPuzzleScores() async {
    final p = await prefs;
    final String? scoresJson = p.getString(_puzzleScoresKey);
    if (scoresJson == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(scoresJson);
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  /// Get score for a specific puzzle.
  Future<int?> getScoreForPuzzle(String date) async {
    final scores = await getPuzzleScores();
    return scores[date];
  }

  /// Calculate the current streak (consecutive days of puzzle completion).
  Future<int> calculateStreak() async {
    final completed = await getCompletedPuzzles();
    if (completed.isEmpty) return 0;

    final sortedDates = completed.toList()..sort((a, b) => b.compareTo(a));

    final now = DateTime.now().toUtc();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (!sortedDates.contains(today)) {
      final yesterday = DateTime.now().toUtc().subtract(const Duration(days: 1));
      final yesterdayStr =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      if (!sortedDates.contains(yesterdayStr)) {
        return 0;
      }
    }

    int streak = 0;
    DateTime currentDate = now;

    if (!sortedDates.contains(today)) {
      currentDate = now.subtract(const Duration(days: 1));
    }

    while (true) {
      final dateStr =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      if (sortedDates.contains(dateStr)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Check if user has seen the help dialog.
  Future<bool> hasSeenHelp() async {
    final p = await prefs;
    return p.getBool(_hasSeenHelpKey) ?? false;
  }

  /// Mark the help dialog as seen.
  Future<void> markHelpAsSeen() async {
    final p = await prefs;
    await p.setBool(_hasSeenHelpKey, true);
  }
}
