class ScoringService {
  static const int baseScore = 100;
  static const int gracePeriodSeconds = 180; // 3 minutes
  static const int deductionIntervalSeconds = 10;
  static const int timeDeduction = 5;
  static const int hintDeduction = 15;
  static const int letterRevealMaxDeduction = 80; // Proportional to word length
  static const int incorrectGuessDeduction = 20;
  static const int minimumScore = 0;

  static int calculateScore({
    required Duration elapsed,
    required bool hintUsed,
    required int incorrectGuesses,
    int revealedLetters = 0,
    int totalLetters = 1,
  }) {
    double score = baseScore.toDouble();

    // Time deductions after grace period
    final totalSeconds = elapsed.inSeconds;
    if (totalSeconds > gracePeriodSeconds) {
      final excessSeconds = totalSeconds - gracePeriodSeconds;
      final intervals = excessSeconds ~/ deductionIntervalSeconds;
      score -= intervals * timeDeduction;
    }

    // Hint deduction (definition reveal)
    if (hintUsed) {
      score -= hintDeduction;
    }

    // Letter reveal deductions - proportional to word length (max 80 points)
    if (totalLetters > 0 && revealedLetters > 0) {
      final letterPenalty = (revealedLetters / totalLetters) * letterRevealMaxDeduction;
      score -= letterPenalty;
    }

    // Incorrect guess deductions
    score -= incorrectGuesses * incorrectGuessDeduction;

    // Clamp and round to nearest 5
    return _roundToNearest5(score.clamp(minimumScore.toDouble(), baseScore.toDouble()).toInt());
  }

  /// Round score to nearest 5 points
  static int _roundToNearest5(int score) {
    return ((score + 2) ~/ 5) * 5;
  }

  static String getScoreEmojis(int score) {
    if (score >= 90) return '🏆🌟✨';
    if (score >= 75) return '🎉🎊';
    if (score >= 60) return '👏👍';
    if (score >= 40) return '💪🙂';
    if (score >= 20) return '🤔📚';
    return '😅📖';
  }

  static String getScoreMessage(int score) {
    if (score >= 90) return 'Brilliant!';
    if (score >= 75) return 'Excellent!';
    if (score >= 60) return 'Well done!';
    if (score >= 40) return 'Good effort!';
    if (score >= 20) return 'Keep practising!';
    return 'Better luck tomorrow!';
  }
}
