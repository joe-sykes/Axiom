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

  MigrationService(this._prefs);

  /// Export all SharedPreferences data as a base64-encoded JSON string
  String exportData() {
    final keys = _prefs.getKeys();
    final data = <String, dynamic>{};

    for (final key in keys) {
      final value = _prefs.get(key);
      if (value != null) {
        // Store with type info for proper restoration
        if (value is String) {
          data[key] = {'type': 'string', 'value': value};
        } else if (value is int) {
          data[key] = {'type': 'int', 'value': value};
        } else if (value is double) {
          data[key] = {'type': 'double', 'value': value};
        } else if (value is bool) {
          data[key] = {'type': 'bool', 'value': value};
        } else if (value is List<String>) {
          data[key] = {'type': 'stringList', 'value': value};
        }
      }
    }

    final jsonString = jsonEncode(data);
    return base64Encode(utf8.encode(jsonString));
  }

  /// Import data from a base64-encoded JSON string
  Future<bool> importData(String base64Data) async {
    try {
      final jsonString = utf8.decode(base64Decode(base64Data));
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      for (final entry in data.entries) {
        final key = entry.key;
        final typeValue = entry.value as Map<String, dynamic>;
        final type = typeValue['type'] as String;
        final value = typeValue['value'];

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
            await _prefs.setStringList(
              key,
              (value as List).cast<String>(),
            );
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
