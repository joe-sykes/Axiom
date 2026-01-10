import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============ Core Dependencies ============

/// SharedPreferences instance - must be overridden at app startup
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden in ProviderScope at app startup',
  );
});

// ============ Theme Management ============

const _themeKey = 'axiom_theme_mode';

/// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final value = prefs.getString(_themeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setTheme(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    _prefs.setString(_themeKey, value);
    state = mode;
  }

  void toggleTheme() {
    // Cycle through: system -> light -> dark -> system
    final newMode = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    setTheme(newMode);
  }
}

/// Global theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

// ============ First Launch Tracking ============

const _firstLaunchKey = 'axiom_first_launch_complete';

/// Whether the user has completed first launch
final isFirstLaunchProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return !(prefs.getBool(_firstLaunchKey) ?? false);
});

/// Mark first launch as complete
Future<void> completeFirstLaunch(WidgetRef ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  await prefs.setBool(_firstLaunchKey, true);
}
