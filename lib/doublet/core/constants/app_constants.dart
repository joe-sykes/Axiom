/// Application constants for Daily Doublet
class AppConstants {
  AppConstants._();

  /// Epoch date: January 1, 2026 (puzzle index 0)
  static final DateTime epochDate = DateTime.utc(2026, 1, 1);

  /// Total number of puzzles available
  static const int totalPuzzles = 288;

  /// Scoring constants
  static const int maxScore = 100;
  static const int penaltyPerIncorrect = 5;
  static const int timePenaltyPer10Sec = 5;
  static const Duration gracePeriod = Duration(seconds: 90); // 1.5 minutes

  /// Cache settings
  static const Duration cacheExpiry = Duration(days: 30);
  static const String puzzleCacheKeyPrefix = 'puzzle_cache_';
  static const String statsKey = 'user_stats';
  static const String themeModeKey = 'theme_mode';
  static const String hasSeenHelpKey = 'has_seen_help';

  /// Firestore collections
  static const String puzzlesCollection = 'puzzles';
  static const String configCollection = 'config';
}
