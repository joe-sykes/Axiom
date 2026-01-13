import '../models/puzzle.dart';
import 'dictionary_service.dart';

/// Service for validating game inputs and submissions
class GameValidator {
  final DictionaryService _dictionaryService;

  GameValidator(this._dictionaryService);

  /// Sanitize and normalize user input
  String normalizeInput(String input) {
    return input.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
  }

  /// Validate a single word during input
  WordValidationResult validateWord(String word, int expectedLength) {
    final normalized = normalizeInput(word);

    if (normalized.isEmpty) {
      return WordValidationResult.empty();
    }

    if (normalized.length != expectedLength) {
      return WordValidationResult.wrongLength(expectedLength);
    }

    // If dictionary not loaded yet, allow the word (validation will happen on submit)
    if (!_dictionaryService.isLoaded) {
      return WordValidationResult.valid();
    }

    if (!_dictionaryService.isValidWord(normalized)) {
      return WordValidationResult.notInDictionary();
    }

    return WordValidationResult.valid();
  }

  /// Validate complete ladder at submission time
  /// This checks if user solution forms a valid word ladder path
  Future<GameValidationResult> validateSubmission({
    required Puzzle puzzle,
    required List<String> userWords,
  }) async {
    // Ensure dictionary is loaded before validating submission
    if (!_dictionaryService.isLoaded) {
      final loaded = await _dictionaryService.ensureLoaded();
      if (!loaded) {
        return GameValidationResult.incorrect('Dictionary failed to load. Please refresh and try again.');
      }
    }

    // Check all words entered
    if (userWords.any((w) => w.isEmpty)) {
      return GameValidationResult.incorrect('Please fill in all words');
    }

    // Build complete ladder: [start, ...userWords, end]
    final completeLadder = [
      puzzle.startWord,
      ...userWords.map((w) => w.toUpperCase().trim()),
      puzzle.endWord,
    ];

    // Check length matches
    if (completeLadder.length != puzzle.ladder.length) {
      return GameValidationResult.incorrect('Incorrect number of words');
    }

    // Validate each word is in the dictionary and transitions are valid
    for (int i = 0; i < completeLadder.length; i++) {
      final word = completeLadder[i];

      // Check word is in dictionary (skip start and end words as they're given)
      if (i > 0 && i < completeLadder.length - 1) {
        if (!_dictionaryService.isValidWord(word)) {
          return GameValidationResult.incorrect('Word not in dictionary: $word');
        }
      }

      // Check transition from previous word (each pair must differ by exactly one letter)
      if (i > 0) {
        if (!isValidTransition(completeLadder[i - 1], word)) {
          return GameValidationResult.incorrect(
              'Invalid transition: ${completeLadder[i - 1]} → $word');
        }
      }
    }

    return GameValidationResult.correct();
  }

  /// Check if two words differ by exactly one letter
  bool isValidTransition(String from, String to) {
    if (from.length != to.length) return false;

    int differences = 0;
    for (int i = 0; i < from.length; i++) {
      if (from[i] != to[i]) differences++;
      if (differences > 1) return false;
    }

    return differences == 1;
  }
}

/// Result of validating a single word
class WordValidationResult {
  final bool isValid;
  final String? errorMessage;

  const WordValidationResult._(this.isValid, this.errorMessage);

  factory WordValidationResult.valid() =>
      const WordValidationResult._(true, null);

  factory WordValidationResult.empty() =>
      const WordValidationResult._(false, 'Please enter a word');

  factory WordValidationResult.wrongLength(int expected) =>
      WordValidationResult._(false, 'Word must be $expected letters');

  factory WordValidationResult.notInDictionary() =>
      const WordValidationResult._(false, 'Word not in dictionary');
}

/// Result of validating a complete game submission
class GameValidationResult {
  final bool isCorrect;
  final String? reason;

  const GameValidationResult._(this.isCorrect, this.reason);

  factory GameValidationResult.correct() =>
      const GameValidationResult._(true, null);

  factory GameValidationResult.incorrect(String reason) =>
      GameValidationResult._(false, reason);
}
