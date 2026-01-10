import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';
import '../models/puzzle_progress.dart';

class CryptixStorageService {
  final SharedPreferences _prefs;

  static const String _statsKey = 'cryptix_user_stats';
  static const String _progressPrefix = 'cryptix_puzzle_progress_';
  static const String _firstLaunchKey = 'cryptix_first_launch';
  static const String _themeModeKey = 'cryptix_theme_mode';

  CryptixStorageService(this._prefs);

  CryptixUserStats getStats() {
    final json = _prefs.getString(_statsKey);
    if (json == null) return const CryptixUserStats();
    return CryptixUserStats.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveStats(CryptixUserStats stats) async {
    await _prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  PuzzleProgress? getPuzzleProgress(int puzzleUid) {
    final json = _prefs.getString('$_progressPrefix$puzzleUid');
    if (json == null) return null;
    return PuzzleProgress.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> savePuzzleProgress(PuzzleProgress progress) async {
    await _prefs.setString(
      '$_progressPrefix${progress.puzzleUid}',
      jsonEncode(progress.toJson()),
    );
  }

  Map<int, PuzzleProgress> getAllProgress() {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_progressPrefix));
    final result = <int, PuzzleProgress>{};

    for (final key in keys) {
      final json = _prefs.getString(key);
      if (json != null) {
        final progress = PuzzleProgress.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
        result[progress.puzzleUid] = progress;
      }
    }

    return result;
  }

  bool isFirstLaunch() {
    return _prefs.getBool(_firstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool(_firstLaunchKey, false);
  }

  String? getThemeMode() {
    return _prefs.getString(_themeModeKey);
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }
}
