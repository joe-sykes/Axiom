import 'triverse_puzzle.dart';

/// Represents a user's answer to a single question.
class UserAnswer {
  final String questionId;
  final int selectedIndex;
  final int timeMs;
  final bool correct;
  final double score;

  const UserAnswer({
    required this.questionId,
    required this.selectedIndex,
    required this.timeMs,
    required this.correct,
    required this.score,
  });
}

/// Represents an in-progress or completed Triverse game session.
class TriverseSession {
  final TriverseDaily puzzle;
  final List<UserAnswer> answers;
  final bool fiftyFiftyUsed;
  final List<int>? fiftyFiftyRemovedIndices;
  final int currentQuestionIndex;
  final bool isComplete;

  const TriverseSession({
    required this.puzzle,
    this.answers = const [],
    this.fiftyFiftyUsed = false,
    this.fiftyFiftyRemovedIndices,
    this.currentQuestionIndex = 0,
    this.isComplete = false,
  });

  TriverseSession copyWith({
    TriverseDaily? puzzle,
    List<UserAnswer>? answers,
    bool? fiftyFiftyUsed,
    List<int>? fiftyFiftyRemovedIndices,
    int? currentQuestionIndex,
    bool? isComplete,
  }) {
    return TriverseSession(
      puzzle: puzzle ?? this.puzzle,
      answers: answers ?? this.answers,
      fiftyFiftyUsed: fiftyFiftyUsed ?? this.fiftyFiftyUsed,
      fiftyFiftyRemovedIndices:
          fiftyFiftyRemovedIndices ?? this.fiftyFiftyRemovedIndices,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Calculate total score (max 100, rounded to nearest 5)
  int get totalScore {
    final raw = answers.fold(0.0, (sum, a) => sum + a.score).round();
    // Round to nearest 5, clamped 0-100
    return (((raw + 2) ~/ 5) * 5).clamp(0, 100);
  }

  /// Number of correct answers
  int get correctCount {
    return answers.where((a) => a.correct).length;
  }

  /// Accuracy as fraction (e.g., "5/7")
  String get accuracyDisplay => '$correctCount/${puzzle.questionCount}';

  /// Average response time in seconds
  double get averageTimeSeconds {
    if (answers.isEmpty) return 0;
    final totalMs = answers.fold(0, (sum, a) => sum + a.timeMs);
    return (totalMs / answers.length) / 1000;
  }
}
