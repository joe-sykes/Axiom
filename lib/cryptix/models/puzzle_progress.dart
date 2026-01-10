class PuzzleProgress {
  final int puzzleUid;
  final bool solved;
  final int? score;
  final DateTime? solvedAt;
  final bool hintUsed;
  final int incorrectGuesses;
  final List<int> revealedLetters;

  PuzzleProgress({
    required this.puzzleUid,
    this.solved = false,
    this.score,
    this.solvedAt,
    this.hintUsed = false,
    this.incorrectGuesses = 0,
    this.revealedLetters = const [],
  });

  PuzzleProgress copyWith({
    int? puzzleUid,
    bool? solved,
    int? score,
    DateTime? solvedAt,
    bool? hintUsed,
    int? incorrectGuesses,
    List<int>? revealedLetters,
  }) {
    return PuzzleProgress(
      puzzleUid: puzzleUid ?? this.puzzleUid,
      solved: solved ?? this.solved,
      score: score ?? this.score,
      solvedAt: solvedAt ?? this.solvedAt,
      hintUsed: hintUsed ?? this.hintUsed,
      incorrectGuesses: incorrectGuesses ?? this.incorrectGuesses,
      revealedLetters: revealedLetters ?? this.revealedLetters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'puzzleUid': puzzleUid,
      'solved': solved,
      'score': score,
      'solvedAt': solvedAt?.toIso8601String(),
      'hintUsed': hintUsed,
      'incorrectGuesses': incorrectGuesses,
      'revealedLetters': revealedLetters,
    };
  }

  factory PuzzleProgress.fromJson(Map<String, dynamic> json) {
    return PuzzleProgress(
      puzzleUid: json['puzzleUid'] as int,
      solved: json['solved'] as bool? ?? false,
      score: json['score'] as int?,
      solvedAt: json['solvedAt'] != null
          ? DateTime.parse(json['solvedAt'] as String)
          : null,
      hintUsed: json['hintUsed'] as bool? ?? false,
      incorrectGuesses: json['incorrectGuesses'] as int? ?? 0,
      revealedLetters: (json['revealedLetters'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
}
