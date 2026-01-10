import '../constants/app_constants.dart';

/// Utility class for score calculations
class ScoringUtils {
  ScoringUtils._();

  /// Calculate final score based on time and accuracy
  static int calculateScore({
    required Duration timeTaken,
    required int incorrectSubmissions,
  }) {
    int score = AppConstants.maxScore;

    // Time penalty: After 3 minutes, -5 points per 10 seconds
    if (timeTaken > AppConstants.gracePeriod) {
      final overtime = timeTaken - AppConstants.gracePeriod;
      final penalty10SecBlocks = overtime.inSeconds ~/ 10;
      score -= penalty10SecBlocks * AppConstants.timePenaltyPer10Sec;
    }

    // Accuracy penalty: -5 per incorrect submission
    score -= incorrectSubmissions * AppConstants.penaltyPerIncorrect;

    // Floor at 0
    return score.clamp(0, AppConstants.maxScore);
  }

  /// Get breakdown of score calculation (for display)
  static ScoreBreakdown getBreakdown({
    required Duration timeTaken,
    required int incorrectSubmissions,
  }) {
    int timePenalty = 0;

    if (timeTaken > AppConstants.gracePeriod) {
      final overtime = timeTaken - AppConstants.gracePeriod;
      final penalty10SecBlocks = overtime.inSeconds ~/ 10;
      timePenalty = penalty10SecBlocks * AppConstants.timePenaltyPer10Sec;
    }

    final accuracyPenalty =
        incorrectSubmissions * AppConstants.penaltyPerIncorrect;
    final finalScore = (AppConstants.maxScore - timePenalty - accuracyPenalty)
        .clamp(0, AppConstants.maxScore);

    return ScoreBreakdown(
      baseScore: AppConstants.maxScore,
      timePenalty: timePenalty,
      accuracyPenalty: accuracyPenalty,
      finalScore: finalScore,
      timeTaken: timeTaken,
      incorrectSubmissions: incorrectSubmissions,
    );
  }
}

/// Breakdown of score calculation for UI display
class ScoreBreakdown {
  final int baseScore;
  final int timePenalty;
  final int accuracyPenalty;
  final int finalScore;
  final Duration timeTaken;
  final int incorrectSubmissions;

  const ScoreBreakdown({
    required this.baseScore,
    required this.timePenalty,
    required this.accuracyPenalty,
    required this.finalScore,
    required this.timeTaken,
    required this.incorrectSubmissions,
  });

  String get formattedTime {
    final minutes = timeTaken.inMinutes;
    final seconds = timeTaken.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
