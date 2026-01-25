import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'analytics_stub.dart' if (dart.library.html) 'analytics_web.dart' as analytics;

/// Game names for analytics tracking
class GameNames {
  static const almanac = 'Almanac';
  static const cryptix = 'Cryptix';
  static const doublet = 'Doublet';
  static const triverse = 'Triverse';
  static const cryptogram = 'Cryptogram';
}

/// Streak milestones to track
const _streakMilestones = [3, 7, 14, 30, 50, 100, 365];

/// Service for Google Analytics tracking
class AnalyticsService {
  /// Track a page view
  static void trackPageView(String pagePath, String pageTitle) {
    if (kIsWeb) {
      analytics.trackPageView(pagePath, pageTitle);
    }
  }

  /// Track when a user starts a game
  static void trackGameStart(String gameName) {
    if (kIsWeb) {
      analytics.trackGameStart(gameName);
    }
  }

  /// Track when a user completes a puzzle
  static void trackGameComplete({
    required String gameName,
    required int score,
    required int timeSeconds,
    int hintsUsed = 0,
    bool isArchive = false,
  }) {
    if (kIsWeb) {
      analytics.trackGameComplete(
        gameName: gameName,
        score: score,
        timeSeconds: timeSeconds,
        hintsUsed: hintsUsed,
        isArchive: isArchive,
      );
    }
  }

  /// Track when a user uses a hint
  static void trackHintUsed(String gameName, int hintNumber) {
    if (kIsWeb) {
      analytics.trackHintUsed(gameName, hintNumber);
    }
  }

  /// Track streak milestone if the new streak is a milestone
  static void trackStreakIfMilestone(String gameName, int newStreak) {
    if (kIsWeb && _streakMilestones.contains(newStreak)) {
      analytics.trackStreakMilestone(gameName, newStreak);
    }
  }

  /// Track share action
  static void trackShare(String gameName, {String method = 'copy'}) {
    if (kIsWeb) {
      analytics.trackShare(gameName, method);
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
    // Map all routes to consistent, clean titles
    switch (routeName) {
      // Home
      case '/':
        return 'Home';
      case '/privacy':
        return 'Privacy Policy';

      // Almanac
      case '/almanac':
        return 'Almanac';
      case '/almanac/archive':
        return 'Almanac Archive';
      case '/almanac/archive/puzzle':
        return 'Almanac Archive Puzzle';
      case '/almanac/privacy':
        return 'Almanac Privacy';

      // Cryptix
      case '/cryptix':
        return 'Cryptix';
      case '/cryptix/archive':
        return 'Cryptix Archive';
      case '/cryptix/archive/puzzle':
        return 'Cryptix Archive Puzzle';
      case '/cryptix/help':
        return 'Cryptix Help';
      case '/cryptix/privacy':
        return 'Cryptix Privacy';

      // Doublet
      case '/doublet':
        return 'Doublet';
      case '/doublet/play':
        return 'Doublet Play';
      case '/doublet/archive':
        return 'Doublet Archive';
      case '/doublet/results':
        return 'Doublet Results';
      case '/doublet/privacy':
        return 'Doublet Privacy';

      // Triverse
      case '/triverse':
        return 'Triverse';
      case '/triverse/play':
        return 'Triverse Play';
      case '/triverse/archive':
        return 'Triverse Archive';
      case '/triverse/privacy':
        return 'Triverse Privacy';

      // Cryptogram
      case '/cryptogram':
        return 'Cryptogram';
      case '/cryptogram/archive':
        return 'Cryptogram Archive';
      case '/cryptogram/archive/puzzle':
        return 'Cryptogram Archive Puzzle';

      // Sharing
      case '/c':
        return 'Share Compare';

      default:
        // For any unmapped routes, create a clean title
        return routeName
            .replaceAll('/', ' ')
            .trim()
            .split(' ')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '')
            .join(' ');
    }
  }
}
