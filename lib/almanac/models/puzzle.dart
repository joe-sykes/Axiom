/// This class represents a single puzzle in our app.
/// It's a "data class" - it just holds data, no business logic.
///
/// WHY WE NEED THIS:
/// - Provides a consistent structure for puzzle data
/// - Makes it easy to pass puzzle data between screens
/// - Converts raw data from Cloud Functions into typed Dart objects
class AlmanacPuzzle {
  /// Unique identifier for the puzzle (matches Firestore document ID)
  final String id;

  /// The date this puzzle is for (format: "2025-01-03")
  /// Stored as a string for simplicity - easier to compare and display
  final String date;

  /// URL to the puzzle image in Firebase Storage
  /// This URL is generated server-side and is safe to use directly
  final String imageUrl;

  /// URL to the thumbnail image (smaller version for archive grid)
  /// Falls back to imageUrl if not provided
  final String thumbnailUrl;

  /// The puzzle description/hint shown to the user
  final String description;

  /// List of accepted answers (all valid solutions)
  /// Users don't see this - it's used for answer checking
  /// SECURITY NOTE: This is only included for today's puzzle when checking answers
  /// Past puzzles may include answers for display purposes
  final List<String> acceptedAnswers;

  /// Three optional hints for the puzzle
  final String? hint1;
  final String? hint2;
  final String? hint3;

  /// Constructor - creates a new Puzzle instance
  /// The 'required' keyword means these fields MUST be provided
  AlmanacPuzzle({
    required this.id,
    required this.date,
    required this.imageUrl,
    String? thumbnailUrl,
    required this.description,
    required this.acceptedAnswers,
    this.hint1,
    this.hint2,
    this.hint3,
  }) : thumbnailUrl = thumbnailUrl ?? imageUrl;

  /// Factory constructor to create a Puzzle from a Map (JSON-like data)
  ///
  /// WHY THIS EXISTS:
  /// Cloud Functions return data as a Map (like JSON).
  /// This method converts that raw data into a typed Puzzle object.
  ///
  /// Example:
  /// - Input: `{"id": "abc", "date": "2025-01-03", "imageUrl": "...", ...}`
  /// - Output: `Puzzle(id: "abc", date: "2025-01-03", ...)`
  factory AlmanacPuzzle.fromMap(Map<String, dynamic> map) {
    final imageUrl = map['imageUrl'] as String? ?? '';
    return AlmanacPuzzle(
      // The 'as String' casts the value to a String type
      // The '?? ""' provides a default empty string if the value is null
      id: map['id'] as String? ?? '',
      date: map['date'] as String? ?? '',
      imageUrl: imageUrl,
      // Use thumbnailUrl if provided, otherwise fall back to imageUrl
      thumbnailUrl: map['thumbnailUrl'] as String? ?? imageUrl,
      description: map['description'] as String? ?? '',
      // For the list, we need to convert each item to a String
      // List<dynamic> is cast to List<String> safely
      acceptedAnswers: (map['acceptedAnswers'] as List<dynamic>?)
          ?.map((answer) => answer.toString())
          .toList() ?? [],
      hint1: map['hint1'] as String?,
      hint2: map['hint2'] as String?,
      hint3: map['hint3'] as String?,
    );
  }

  /// Returns a list of available hints
  List<String> get hints {
    final List<String> result = [];
    if (hint1 != null && hint1!.isNotEmpty) result.add(hint1!);
    if (hint2 != null && hint2!.isNotEmpty) result.add(hint2!);
    if (hint3 != null && hint3!.isNotEmpty) result.add(hint3!);
    return result;
  }

  /// Checks if a user's guess matches any accepted answer
  ///
  /// WHY THIS IS HERE:
  /// Keeps answer-checking logic with the Puzzle model
  /// Makes it reusable and testable
  ///
  /// RULES:
  /// - Case-insensitive (converts both to lowercase)
  /// - Trims whitespace from both ends
  bool checkAnswer(String guess) {
    // Normalize the user's guess
    final normalizedGuess = guess.trim().toLowerCase();

    // Check if any accepted answer matches
    return acceptedAnswers.any(
      (answer) => answer.trim().toLowerCase() == normalizedGuess,
    );
  }
}
