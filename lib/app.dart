import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/route_names.dart';
import 'core/providers/core_providers.dart';
import 'core/theme/axiom_theme.dart';
import 'routes.dart';

class AxiomApp extends ConsumerWidget {
  const AxiomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Axiom',
      debugShowCheckedModeBanner: false,
      theme: axiomLightTheme,
      darkTheme: axiomDarkTheme,
      themeMode: themeMode,
      initialRoute: RouteNames.home,
      onGenerateRoute: generateRoute,
    );
  }
}
