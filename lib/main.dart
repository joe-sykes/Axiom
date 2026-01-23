import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/firebase/firebase_manager.dart';
import 'core/providers/core_providers.dart';
import 'core/services/migration_service.dart';
import 'core/services/migration_platform.dart' as migration;
import 'almanac/providers/almanac_providers.dart';
import 'cryptix/providers/cryptix_providers.dart';
import 'doublet/providers/providers.dart';

/// Tracks if migration was just completed (for showing success message)
bool migrationJustCompleted = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path-based URLs on web (e.g., /c/data instead of /#/c/data)
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Initialize Firebase for all apps
  await FirebaseManager.initializeAll();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Handle migration from old domain (web only)
  if (kIsWeb) {
    final migrateData = migration.getMigrationParam();
    if (migrateData != null && migrateData.isNotEmpty) {
      final migrationService = MigrationService(prefs);
      final success = await migrationService.importData(migrateData);
      if (success) {
        migrationJustCompleted = true;
      }
      // Clean up URL
      migration.clearMigrationParam();
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences provider with actual instance
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Override for each game's prefs provider
        almanacPrefsProvider.overrideWithValue(prefs),
        cryptixPrefsProvider.overrideWithValue(prefs),
        doubletPrefsProvider.overrideWithValue(prefs),
      ],
      child: const AxiomApp(),
    ),
  );
}
