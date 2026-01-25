/// Stub implementation for non-web platforms

void trackPageView(String pagePath, String pageTitle) {
  // No-op on non-web platforms
}

void trackGameStart(String gameName) {
  // No-op on non-web platforms
}

void trackGameComplete({
  required String gameName,
  required int score,
  required int timeSeconds,
  required int hintsUsed,
  required bool isArchive,
}) {
  // No-op on non-web platforms
}

void trackHintUsed(String gameName, int hintNumber) {
  // No-op on non-web platforms
}

void trackStreakMilestone(String gameName, int streakDays) {
  // No-op on non-web platforms
}

void trackShare(String gameName, String method) {
  // No-op on non-web platforms
}
