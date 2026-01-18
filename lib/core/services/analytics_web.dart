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
