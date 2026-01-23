import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle data migration between domains
class MigrationService {
  final SharedPreferences _prefs;

  /// Old Firebase hosting domains
  static const List<String> oldDomains = [
    'axiompuzzles.web.app',
    'axiompuzzles.firebaseapp.com',
  ];

  /// New custom domain
  static const String newDomain = 'axiom-puzzles.com';

  /// Keys that should be migrated (essential user progress data)
  static const List<String> _essentialKeyPatterns = [
    'streak',
    'completed',
    'solved',
    'scores',
    'played',
    'best',
    'total',
    'last_played',
    'results',
    'stats',
  ];

  /// Keys to explicitly exclude (temporary/large data)
  static const List<String> _excludeKeyPatterns = [
    'cipher',
    'mapping',
    'current_puzzle',
    'help',
    'seen',
  ];

  MigrationService(this._prefs);

  bool _shouldMigrateKey(String key) {
    // Exclude temporary data
    for (final pattern in _excludeKeyPatterns) {
      if (key.toLowerCase().contains(pattern)) {
        return false;
      }
    }
    // Include essential data
    for (final pattern in _essentialKeyPatterns) {
      if (key.toLowerCase().contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Export essential SharedPreferences data as a base64-encoded JSON string
  String exportData() {
    final keys = _prefs.getKeys();
    final data = <String, dynamic>{};

    for (final key in keys) {
      if (!_shouldMigrateKey(key)) continue;

      final value = _prefs.get(key);
      if (value != null) {
        // Use compact format: [type_char, value]
        // s=string, i=int, d=double, b=bool, l=stringList
        if (value is String) {
          data[key] = ['s', value];
        } else if (value is int) {
          data[key] = ['i', value];
        } else if (value is double) {
          data[key] = ['d', value];
        } else if (value is bool) {
          data[key] = ['b', value];
        } else if (value is List<String>) {
          data[key] = ['l', value];
        }
      }
    }

    final jsonString = jsonEncode(data);
    return base64Url.encode(utf8.encode(jsonString));
  }

  /// Import data from a base64-encoded JSON string
  Future<bool> importData(String base64Data) async {
    try {
      // Try URL-safe base64 first, then regular base64
      String jsonString;
      try {
        jsonString = utf8.decode(base64Url.decode(base64Data));
      } catch (_) {
        jsonString = utf8.decode(base64Decode(base64Data));
      }

      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      for (final entry in data.entries) {
        final key = entry.key;
        final entryValue = entry.value;

        // Handle compact format: [type_char, value]
        if (entryValue is List && entryValue.length == 2) {
          final type = entryValue[0] as String;
          final value = entryValue[1];

          switch (type) {
            case 's':
              await _prefs.setString(key, value as String);
            case 'i':
              await _prefs.setInt(key, value as int);
            case 'd':
              await _prefs.setDouble(key, (value as num).toDouble());
            case 'b':
              await _prefs.setBool(key, value as bool);
            case 'l':
              await _prefs.setStringList(key, (value as List).cast<String>());
          }
        }
        // Handle old format: {type: ..., value: ...}
        else if (entryValue is Map<String, dynamic>) {
          final type = entryValue['type'] as String;
          final value = entryValue['value'];

          switch (type) {
            case 'string':
              await _prefs.setString(key, value as String);
            case 'int':
              await _prefs.setInt(key, value as int);
            case 'double':
              await _prefs.setDouble(key, (value as num).toDouble());
            case 'bool':
              await _prefs.setBool(key, value as bool);
            case 'stringList':
              await _prefs.setStringList(key, (value as List).cast<String>());
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Migration import failed: $e');
      return false;
    }
  }

  /// Check if there's any data to migrate (user has played before)
  bool hasDataToMigrate() {
    final keys = _prefs.getKeys();
    // Check for any game-related keys
    return keys.any((key) =>
        key.contains('stats') ||
        key.contains('streak') ||
        key.contains('completed') ||
        key.contains('progress'));
  }

  /// Generate the migration URL for the new domain
  String getMigrationUrl() {
    final data = exportData();
    return 'https://$newDomain?migrate=$data';
  }
}
