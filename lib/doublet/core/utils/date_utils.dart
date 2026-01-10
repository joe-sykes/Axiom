import '../constants/app_constants.dart';

/// Utility class for puzzle-to-date mapping
class PuzzleDateUtils {
  PuzzleDateUtils._();

  /// Get today's date normalized to UTC midnight
  static DateTime get todayUtc {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day);
  }

  /// Get puzzle index for any given date
  /// Uses modulo for infinite cycling after all puzzles are exhausted
  static int getPuzzleIndexForDate(DateTime date) {
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);
    final daysSinceEpoch =
        normalizedDate.difference(AppConstants.epochDate).inDays;

    // Handle dates before epoch (defensive)
    if (daysSinceEpoch < 0) {
      return (AppConstants.totalPuzzles +
              (daysSinceEpoch % AppConstants.totalPuzzles)) %
          AppConstants.totalPuzzles;
    }

    return daysSinceEpoch % AppConstants.totalPuzzles;
  }

  /// Get today's puzzle index
  static int getTodaysPuzzleIndex() {
    return getPuzzleIndexForDate(DateTime.now());
  }

  /// Get the first release date for a puzzle index
  static DateTime getFirstReleaseDateForPuzzle(int puzzleIndex) {
    return AppConstants.epochDate.add(Duration(days: puzzleIndex));
  }

  /// Check if a puzzle is today's puzzle
  static bool isTodaysPuzzle(int puzzleIndex) {
    return puzzleIndex == getTodaysPuzzleIndex();
  }

  /// Get puzzle number for display (1-indexed, human-friendly)
  /// This is the total number of days since epoch + 1
  static int getPuzzleNumberForDate(DateTime date) {
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);
    return normalizedDate.difference(AppConstants.epochDate).inDays + 1;
  }

  /// Get today's puzzle number for display
  static int getTodaysPuzzleNumber() {
    return getPuzzleNumberForDate(DateTime.now());
  }

  /// Check if a date is in the past or today
  static bool isDatePlayable(DateTime date) {
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);
    return !normalizedDate.isAfter(todayUtc);
  }

  /// Get all puzzle indices that have been released
  static List<int> getReleasedPuzzleIndices() {
    final daysSinceEpoch = todayUtc.difference(AppConstants.epochDate).inDays;

    // All puzzle indices that have been released at least once
    if (daysSinceEpoch >= AppConstants.totalPuzzles) {
      // Full rotation completed - all puzzles available
      return List.generate(AppConstants.totalPuzzles, (i) => i);
    }

    // Partial rotation - only puzzles 0 to daysSinceEpoch
    if (daysSinceEpoch < 0) {
      return [];
    }

    return List.generate(daysSinceEpoch + 1, (i) => i);
  }
}
