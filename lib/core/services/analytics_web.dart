import 'package:flutter/foundation.dart';
import 'dart:js_interop';

@JS('gtag')
external void _gtag(String command, String action, JSObject? params);

/// Web implementation using Google Analytics gtag
void trackPageView(String pagePath, String pageTitle) {
  try {
    final params = {
      'page_path': pagePath,
      'page_title': pageTitle,
    }.jsify() as JSObject;
    _gtag('event', 'page_view', params);
  } catch (e) {
    debugPrint('Analytics error: $e');
  }
}

/// Track game start
void trackGameStart(String gameName) {
  try {
    final params = {
      'game_name': gameName,
    }.jsify() as JSObject;
    _gtag('event', 'game_start', params);
  } catch (e) {
    debugPrint('Analytics error: $e');
  }
}

/// Track game completion with score and time
void trackGameComplete({
  required String gameName,
  required int score,
  required int timeSeconds,
  required int hintsUsed,
  required bool isArchive,
}) {
  try {
    final params = {
      'game_name': gameName,
      'score': score,
      'time_seconds': timeSeconds,
      'hints_used': hintsUsed,
      'is_archive': isArchive,
    }.jsify() as JSObject;
    _gtag('event', 'game_complete', params);
  } catch (e) {
    debugPrint('Analytics error: $e');
  }
}

/// Track hint usage
void trackHintUsed(String gameName, int hintNumber) {
  try {
    final params = {
      'game_name': gameName,
      'hint_number': hintNumber,
    }.jsify() as JSObject;
    _gtag('event', 'hint_used', params);
  } catch (e) {
    debugPrint('Analytics error: $e');
  }
}

/// Track streak milestones (3, 7, 14, 30, etc.)
void trackStreakMilestone(String gameName, int streakDays) {
  try {
    final params = {
      'game_name': gameName,
      'streak_days': streakDays,
    }.jsify() as JSObject;
    _gtag('event', 'streak_milestone', params);
  } catch (e) {
    debugPrint('Analytics error: $e');
  }
}

/// Track share action
void trackShare(String gameName, String method) {
  try {
    final params = {
      'game_name': gameName,
      'method': method,
    }.jsify() as JSObject;
    _gtag('event', 'share', params);
  } catch (e) {
    debugPrint('Analytics error: $e');
  }
}
