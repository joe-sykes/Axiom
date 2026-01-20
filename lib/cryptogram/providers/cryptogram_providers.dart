import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/puzzle.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

// Services
final cryptogramFirestoreServiceProvider = Provider((ref) => CryptogramFirestoreService());
final cryptogramStorageServiceProvider = Provider((ref) => CryptogramStorageService());

// Daily puzzle
final cryptogramDailyPuzzleProvider = FutureProvider<CryptogramPuzzle?>((ref) async {
  final service = ref.read(cryptogramFirestoreServiceProvider);
  return service.getDailyPuzzle();
});

// Stats
final cryptogramStreakProvider = FutureProvider<int>((ref) async {
  final storage = ref.read(cryptogramStorageServiceProvider);
  return storage.getCurrentStreak();
});

final cryptogramTotalSolvedProvider = FutureProvider<int>((ref) async {
  final storage = ref.read(cryptogramStorageServiceProvider);
  return storage.getTotalSolved();
});

final cryptogramBestStreakProvider = FutureProvider<int>((ref) async {
  final storage = ref.read(cryptogramStorageServiceProvider);
  return storage.getBestStreak();
});

final cryptogramCompletedTodayProvider = FutureProvider<bool>((ref) async {
  final storage = ref.read(cryptogramStorageServiceProvider);
  return storage.hasCompletedToday();
});

final cryptogramTodayScoreProvider = FutureProvider<int?>((ref) async {
  final storage = ref.read(cryptogramStorageServiceProvider);
  return storage.getTodayScore();
});

// Game state
class CryptogramGameState {
  final CryptogramPuzzle? puzzle;
  final Map<String, String> cipher;
  final Map<String, String> userMapping;
  final String encodedQuote;
  final bool isComplete;
  final int score;
  final int hintsUsed;
  final Set<String> revealedLetters;

  CryptogramGameState({
    this.puzzle,
    this.cipher = const {},
    this.userMapping = const {},
    this.encodedQuote = '',
    this.isComplete = false,
    this.score = 100,
    this.hintsUsed = 0,
    this.revealedLetters = const {},
  });

  CryptogramGameState copyWith({
    CryptogramPuzzle? puzzle,
    Map<String, String>? cipher,
    Map<String, String>? userMapping,
    String? encodedQuote,
    bool? isComplete,
    int? score,
    int? hintsUsed,
    Set<String>? revealedLetters,
  }) {
    return CryptogramGameState(
      puzzle: puzzle ?? this.puzzle,
      cipher: cipher ?? this.cipher,
      userMapping: userMapping ?? this.userMapping,
      encodedQuote: encodedQuote ?? this.encodedQuote,
      isComplete: isComplete ?? this.isComplete,
      score: score ?? this.score,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      revealedLetters: revealedLetters ?? this.revealedLetters,
    );
  }
}

class CryptogramGameNotifier extends StateNotifier<CryptogramGameState> {
  final CryptogramStorageService _storage;

  CryptogramGameNotifier(this._storage) : super(CryptogramGameState());

  void initPuzzle(CryptogramPuzzle puzzle) {
    final cipher = puzzle.generateCipher();
    final encoded = puzzle.encodeQuote(cipher);

    state = CryptogramGameState(
      puzzle: puzzle,
      cipher: cipher,
      encodedQuote: encoded,
    );
  }

  void setLetter(String encodedLetter, String decodedLetter) {
    if (state.isComplete) return;

    final upperDecoded = decodedLetter.toUpperCase();
    final upperEncoded = encodedLetter.toUpperCase();

    // Check if this decoded letter is already assigned to a revealed letter
    for (final revealed in state.revealedLetters) {
      if (state.userMapping[revealed] == upperDecoded) {
        // This letter is already used by a revealed letter, can't reassign
        return;
      }
    }

    final newMapping = Map<String, String>.from(state.userMapping);

    // Remove any existing mapping to this decoded letter (but not revealed ones)
    newMapping.removeWhere((k, v) =>
        v.toUpperCase() == upperDecoded && !state.revealedLetters.contains(k));

    // Set the new mapping
    newMapping[upperEncoded] = upperDecoded;

    state = state.copyWith(userMapping: newMapping);

    _checkCompletion();
  }

  void removeLetter(String encodedLetter) {
    if (state.isComplete) return;

    final newMapping = Map<String, String>.from(state.userMapping);
    newMapping.remove(encodedLetter.toUpperCase());

    state = state.copyWith(userMapping: newMapping);
  }

  void revealLetter() {
    if (state.isComplete || state.puzzle == null) return;

    // Get unique letters that actually appear in the encoded quote
    final lettersInQuote = state.encodedQuote
        .toUpperCase()
        .split('')
        .where((c) => RegExp(r'[A-Z]').hasMatch(c))
        .toSet();

    // Build reverse cipher for decoding
    final reverseCipher = <String, String>{};
    state.cipher.forEach((k, v) => reverseCipher[v] = k);

    // Find letters that haven't been revealed or correctly guessed
    final availableLetters = <String>[];
    for (final encoded in lettersInQuote) {
      final decoded = reverseCipher[encoded];
      if (decoded != null &&
          !state.revealedLetters.contains(encoded) &&
          state.userMapping[encoded] != decoded) {
        availableLetters.add(encoded);
      }
    }

    if (availableLetters.isEmpty) return;

    // Use deterministic random based on puzzle date and hints used
    final seed = state.puzzle!.date.hashCode + state.hintsUsed;
    final random = Random(seed);
    final encoded = availableLetters[random.nextInt(availableLetters.length)];
    final decoded = reverseCipher[encoded]!;

    final newMapping = Map<String, String>.from(state.userMapping);
    newMapping[encoded] = decoded;

    final newRevealed = Set<String>.from(state.revealedLetters)..add(encoded);

    state = state.copyWith(
      userMapping: newMapping,
      revealedLetters: newRevealed,
      hintsUsed: state.hintsUsed + 1,
      score: (state.score - 10).clamp(0, 100),
    );

    _checkCompletion();
  }

  void _checkCompletion() {
    if (state.puzzle == null) return;

    // Build the decoded quote from user mapping
    final decoded = state.encodedQuote.split('').map((char) {
      final upper = char.toUpperCase();
      if (state.userMapping.containsKey(upper)) {
        return char == upper
            ? state.userMapping[upper]!
            : state.userMapping[upper]!.toLowerCase();
      }
      return char;
    }).join('');

    if (decoded.toUpperCase() == state.puzzle!.quote.toUpperCase()) {
      state = state.copyWith(isComplete: true);
      _storage.recordCompletion(state.score);
    }
  }

  void reset() {
    if (state.puzzle != null) {
      initPuzzle(state.puzzle!);
    }
  }
}

final cryptogramGameProvider =
    StateNotifierProvider<CryptogramGameNotifier, CryptogramGameState>((ref) {
  final storage = ref.read(cryptogramStorageServiceProvider);
  return CryptogramGameNotifier(storage);
});
