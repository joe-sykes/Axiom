import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CryptogramStorageService {
  static const _keyPrefix = 'cryptogram_';
  static const _lastPlayedDateKey = '${_keyPrefix}last_played_date';
  static const _currentStreakKey = '${_keyPrefix}current_streak';
  static const _bestStreakKey = '${_keyPrefix}best_streak';
  static const _totalSolvedKey = '${_keyPrefix}total_solved';
  static const _currentPuzzleKey = '${_keyPrefix}current_puzzle';
  static const _currentCipherKey = '${_keyPrefix}current_cipher';
  static const _userMappingKey = '${_keyPrefix}user_mapping';
  static const _completedTodayKey = '${_keyPrefix}completed_today';
  static const _todayScoreKey = '${_keyPrefix}today_score';
  static const _hasSeenHelpKey = '${_keyPrefix}has_seen_help';

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Streak management
  Future<int> getCurrentStreak() async {
    await init();
    return _prefs.getInt(_currentStreakKey) ?? 0;
  }

  Future<int> getBestStreak() async {
    await init();
    return _prefs.getInt(_bestStreakKey) ?? 0;
  }

  Future<int> getTotalSolved() async {
    await init();
    return _prefs.getInt(_totalSolvedKey) ?? 0;
  }

  Future<void> recordCompletion(int score) async {
    await init();
    final today = _getTodayString();
    final lastPlayed = _prefs.getString(_lastPlayedDateKey);

    int currentStreak = _prefs.getInt(_currentStreakKey) ?? 0;

    if (lastPlayed == _getYesterdayString()) {
      currentStreak++;
    } else if (lastPlayed != today) {
      currentStreak = 1;
    }

    final bestStreak = _prefs.getInt(_bestStreakKey) ?? 0;
    final totalSolved = (_prefs.getInt(_totalSolvedKey) ?? 0) + 1;

    await _prefs.setString(_lastPlayedDateKey, today);
    await _prefs.setInt(_currentStreakKey, currentStreak);
    await _prefs.setInt(_bestStreakKey, currentStreak > bestStreak ? currentStreak : bestStreak);
    await _prefs.setInt(_totalSolvedKey, totalSolved);
    await _prefs.setBool(_completedTodayKey, true);
    await _prefs.setInt(_todayScoreKey, score);
  }

  Future<bool> hasCompletedToday() async {
    await init();
    final lastPlayed = _prefs.getString(_lastPlayedDateKey);
    return lastPlayed == _getTodayString();
  }

  Future<int?> getTodayScore() async {
    await init();
    if (await hasCompletedToday()) {
      return _prefs.getInt(_todayScoreKey);
    }
    return null;
  }

  // Puzzle state management
  Future<void> saveCurrentPuzzle(String puzzleId, Map<String, String> cipher) async {
    await init();
    await _prefs.setString(_currentPuzzleKey, puzzleId);
    await _prefs.setString(_currentCipherKey, jsonEncode(cipher));
  }

  Future<Map<String, String>?> getCurrentCipher() async {
    await init();
    final cipherJson = _prefs.getString(_currentCipherKey);
    if (cipherJson == null) return null;
    final decoded = jsonDecode(cipherJson) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> saveUserMapping(Map<String, String> mapping) async {
    await init();
    await _prefs.setString(_userMappingKey, jsonEncode(mapping));
  }

  Future<Map<String, String>> getUserMapping() async {
    await init();
    final mappingJson = _prefs.getString(_userMappingKey);
    if (mappingJson == null) return {};
    final decoded = jsonDecode(mappingJson) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> clearCurrentPuzzle() async {
    await init();
    await _prefs.remove(_currentPuzzleKey);
    await _prefs.remove(_currentCipherKey);
    await _prefs.remove(_userMappingKey);
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getYesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  /// Check if user has seen the help dialog
  Future<bool> hasSeenHelp() async {
    await init();
    return _prefs.getBool(_hasSeenHelpKey) ?? false;
  }

  /// Mark the help dialog as seen
  Future<void> markHelpAsSeen() async {
    await init();
    await _prefs.setBool(_hasSeenHelpKey, true);
  }
}
