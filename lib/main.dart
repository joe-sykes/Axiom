import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/firebase/firebase_manager.dart';
import 'core/providers/core_providers.dart';
import 'almanac/providers/almanac_providers.dart';
import 'cryptix/providers/cryptix_providers.dart';
import 'doublet/providers/providers.dart';

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
