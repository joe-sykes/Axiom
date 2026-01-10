/// Represents an active game session
class GameSession {
  /// The puzzle being played
  final int puzzleIndex;

  /// User's entered words (null = not yet entered)
  final List<String?> userWords;

  /// When the game started
  final DateTime startTime;

  /// Number of incorrect submissions
  final int incorrectSubmissions;

  /// Whether the game has been completed
  final bool isComplete;

  /// Whether the solution was correct (only valid if isComplete)
  final bool wasSuccessful;

  /// Final score (only valid if isComplete)
  final int? finalScore;

  /// Whether this is today's daily puzzle
  final bool isDailyPuzzle;

  const GameSession({
    required this.puzzleIndex,
    required this.userWords,
    required this.startTime,
    required this.incorrectSubmissions,
    required this.isComplete,
    required this.wasSuccessful,
    required this.isDailyPuzzle,
    this.finalScore,
  });

  /// Create initial game session
  factory GameSession.initial({
    required int puzzleIndex,
    required int inputCount,
    required bool isDailyPuzzle,
  }) {
    return GameSession(
      puzzleIndex: puzzleIndex,
      userWords: List.filled(inputCount, null),
      startTime: DateTime.now(),
      incorrectSubmissions: 0,
      isComplete: false,
      wasSuccessful: false,
      isDailyPuzzle: isDailyPuzzle,
    );
  }

  /// Check if all words have been entered
  bool get isReadyToSubmit =>
      userWords.every((w) => w != null && w.isNotEmpty);

  /// Elapsed time since game start
  Duration get elapsedTime => DateTime.now().difference(startTime);

  /// Get entered words as non-nullable list (empty string for nulls)
  List<String> get enteredWords =>
      userWords.map((w) => w ?? '').toList();

  /// Create a copy with updated fields
  GameSession copyWith({
    int? puzzleIndex,
    List<String?>? userWords,
    DateTime? startTime,
    int? incorrectSubmissions,
    bool? isComplete,
    bool? wasSuccessful,
    int? finalScore,
    bool? isDailyPuzzle,
  }) {
    return GameSession(
      puzzleIndex: puzzleIndex ?? this.puzzleIndex,
      userWords: userWords ?? this.userWords,
      startTime: startTime ?? this.startTime,
      incorrectSubmissions: incorrectSubmissions ?? this.incorrectSubmissions,
      isComplete: isComplete ?? this.isComplete,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      finalScore: finalScore ?? this.finalScore,
      isDailyPuzzle: isDailyPuzzle ?? this.isDailyPuzzle,
    );
  }
}
