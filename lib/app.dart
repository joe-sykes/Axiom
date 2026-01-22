import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/services/analytics_service.dart';
import 'core/theme/axiom_theme.dart';
import 'routes.dart';

/// Custom scroll behavior that hides scrollbars on web
class NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Return the child without wrapping it in a Scrollbar
    return child;
  }
}

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
      onGenerateRoute: generateRoute,
      scrollBehavior: NoScrollbarBehavior(),
      navigatorObservers: [AnalyticsNavigatorObserver()],
    );
  }
}
