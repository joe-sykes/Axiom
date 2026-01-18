import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'analytics_stub.dart' if (dart.library.html) 'analytics_web.dart' as analytics;

/// Service for Google Analytics tracking
class AnalyticsService {
  static void trackPageView(String pagePath, String pageTitle) {
    if (kIsWeb) {
      analytics.trackPageView(pagePath, pageTitle);
    }
  }
}

/// Navigation observer that tracks route changes in Google Analytics
class AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackRoute(previousRoute);
    }
  }

  void _trackRoute(Route<dynamic> route) {
    final routeName = route.settings.name;
    if (routeName != null) {
      final pageTitle = _getPageTitle(routeName);
      AnalyticsService.trackPageView(routeName, pageTitle);
    }
  }

  String _getPageTitle(String routeName) {
    switch (routeName) {
      case '/':
        return 'Axiom Home';
      case '/almanac':
        return 'Almanac';
      case '/almanac/archive':
        return 'Almanac Archive';
      case '/cryptix':
        return 'Cryptix';
      case '/cryptix/archive':
        return 'Cryptix Archive';
      case '/cryptix/help':
        return 'Cryptix Help';
      case '/doublet':
        return 'Doublet';
      case '/doublet/play':
        return 'Doublet Play';
      case '/doublet/archive':
        return 'Doublet Archive';
      case '/doublet/results':
        return 'Doublet Results';
      default:
        return routeName;
    }
  }
}
