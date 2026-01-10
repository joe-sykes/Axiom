/// Result of a completed game
class GameResult {
  final int puzzleIndex;
  final DateTime playedAt;
  final bool wasSuccessful;
  final int score;
  final Duration timeTaken;
  final int incorrectAttempts;
  final bool wasDailyPuzzle;

  const GameResult({
    required this.puzzleIndex,
    required this.playedAt,
    required this.wasSuccessful,
    required this.score,
    required this.timeTaken,
    required this.incorrectAttempts,
    required this.wasDailyPuzzle,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      puzzleIndex: json['puzzleIndex'] as int,
      playedAt: DateTime.parse(json['playedAt'] as String),
      wasSuccessful: json['wasSuccessful'] as bool,
      score: json['score'] as int,
      timeTaken: Duration(milliseconds: json['timeTakenMs'] as int),
      incorrectAttempts: json['incorrectAttempts'] as int,
      wasDailyPuzzle: json['wasDailyPuzzle'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'puzzleIndex': puzzleIndex,
        'playedAt': playedAt.toIso8601String(),
        'wasSuccessful': wasSuccessful,
        'score': score,
        'timeTakenMs': timeTaken.inMilliseconds,
        'incorrectAttempts': incorrectAttempts,
        'wasDailyPuzzle': wasDailyPuzzle,
      };
}
