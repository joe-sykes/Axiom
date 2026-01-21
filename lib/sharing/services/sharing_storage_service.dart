import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Storage service for sharing-related data.
class SharingStorageService {
  final SharedPreferences _prefs;

  static const String _profileKey = 'axiom_user_profile';

  SharingStorageService(this._prefs);

  /// Load the user profile from storage.
  UserProfile? loadProfile() {
    final json = _prefs.getString(_profileKey);
    if (json == null) {
      return null;
    }
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// Save the user profile to storage.
  Future<void> saveProfile(UserProfile profile) async {
    final json = jsonEncode(profile.toJson());
    await _prefs.setString(_profileKey, json);
  }

  /// Check if a profile exists.
  bool hasProfile() {
    return _prefs.containsKey(_profileKey);
  }

  /// Clear the stored profile.
  Future<void> clearProfile() async {
    await _prefs.remove(_profileKey);
  }
}
