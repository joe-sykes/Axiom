import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/firebase/firebase_manager.dart';
import '../../core/services/analytics_service.dart';
import '../models/puzzle.dart';
import '../services/puzzle_service.dart';
import '../services/storage_service.dart';

// ============ Core Dependencies ============

/// SharedPreferences instance - must be overridden at app startup
final almanacPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden in ProviderScope at app startup',
  );
});

// ============ Services ============

/// Puzzle service for Almanac
final almanacPuzzleServiceProvider = Provider<AlmanacPuzzleService>((ref) {
  return AlmanacPuzzleService(FirebaseManager.almanacFirestore);
});

// ============ Puzzle State ============

/// Today's puzzle
final almanacTodaysPuzzleProvider = FutureProvider<AlmanacPuzzle?>((ref) async {
  await FirebaseManager.ensureAlmanacInitialized();
  final service = ref.watch(almanacPuzzleServiceProvider);
  return service.getTodaysPuzzle();
});

/// Archive puzzles
final almanacArchivePuzzlesProvider = FutureProvider<List<AlmanacPuzzle>>((ref) async {
  await FirebaseManager.ensureAlmanacInitialized();
  final service = ref.watch(almanacPuzzleServiceProvider);
  return service.getPastPuzzles();
});

// ============ Game State ============

enum AlmanacPuzzleState { loading, ready, solved, error }

class AlmanacGameState {
  final AlmanacPuzzle? todaysPuzzle;
  final AlmanacPuzzleState state;
  final String? errorMessage;
  final bool? isCorrect;
  final int hintsUsed;
  final List<bool> hintsRevealed;
  final int score;
  final DateTime? startTime;
  final int incorrectGuesses;

  const AlmanacGameState({
    this.todaysPuzzle,
    this.state = AlmanacPuzzleState.loading,
    this.errorMessage,
    this.isCorrect,
    this.hintsUsed = 0,
    this.hintsRevealed = const [false, false, false],
    this.score = 100,
    this.startTime,
    this.incorrectGuesses = 0,
  });

  AlmanacGameState copyWith({
    AlmanacPuzzle? todaysPuzzle,
    AlmanacPuzzleState? state,
    String? errorMessage,
    bool? isCorrect,
    int? hintsUsed,
    List<bool>? hintsRevealed,
    int? score,
    DateTime? startTime,
    int? incorrectGuesses,
  }) {
    return AlmanacGameState(
      todaysPuzzle: todaysPuzzle ?? this.todaysPuzzle,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      isCorrect: isCorrect ?? this.isCorrect,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      hintsRevealed: hintsRevealed ?? this.hintsRevealed,
      score: score ?? this.score,
      startTime: startTime ?? this.startTime,
      incorrectGuesses: incorrectGuesses ?? this.incorrectGuesses,
    );
  }
}

class AlmanacGameNotifier extends StateNotifier<AlmanacGameState> {
  final Ref _ref;

  AlmanacGameNotifier(this._ref) : super(const AlmanacGameState());

  Future<void> loadPuzzle() async {
    state = state.copyWith(state: AlmanacPuzzleState.loading);

    try {
      final puzzle = await _ref.read(almanacTodaysPuzzleProvider.future);
      if (puzzle != null) {
        // Track game start
        AnalyticsService.trackGameStart(GameNames.almanac);

        state = state.copyWith(
          todaysPuzzle: puzzle,
          state: AlmanacPuzzleState.ready,
          startTime: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          state: AlmanacPuzzleState.error,
          errorMessage: 'No puzzle available for today',
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: AlmanacPuzzleState.error,
        errorMessage: 'Failed to load puzzle: $e',
      );
    }
  }

  // Scoring constants
  static const int _baseScore = 100;
  static const int _hintPenalty = 20;
  static const int _incorrectGuessPenalty = 15;
  static const int _gracePeriodSeconds = 180; // 3 minutes
  static const int _timePenaltyInterval = 20; // seconds
  static const int _timePenaltyPoints = 5;

  void revealHint(int index) {
    if (index < 0 || index >= 3) return;
    if (state.hintsRevealed[index]) return;

    final newRevealed = List<bool>.from(state.hintsRevealed);
    newRevealed[index] = true;

    final newHintsUsed = state.hintsUsed + 1;

    // Track hint usage
    AnalyticsService.trackHintUsed(GameNames.almanac, newHintsUsed);

    state = state.copyWith(
      hintsRevealed: newRevealed,
      hintsUsed: newHintsUsed,
    );
  }

  bool checkAnswer(String guess, {bool isArchive = false}) {
    if (state.todaysPuzzle == null) return false;

    final isCorrect = state.todaysPuzzle!.checkAnswer(guess);

    if (isCorrect) {
      // Calculate final score when solved
      final finalScore = _calculateFinalScore();
      final timeSeconds = state.startTime != null
          ? DateTime.now().difference(state.startTime!).inSeconds
          : 0;

      // Track completion in analytics
      AnalyticsService.trackGameComplete(
        gameName: GameNames.almanac,
        score: finalScore,
        timeSeconds: timeSeconds,
        hintsUsed: state.hintsUsed,
        isArchive: isArchive,
      );

      state = state.copyWith(
        isCorrect: isCorrect,
        state: AlmanacPuzzleState.solved,
        score: finalScore,
      );
    } else {
      // Track incorrect guess
      state = state.copyWith(
        isCorrect: isCorrect,
        incorrectGuesses: state.incorrectGuesses + 1,
      );
    }
    return isCorrect;
  }

  int _calculateFinalScore() {
    double score = _baseScore.toDouble();

    // Hint penalty: -20 per hint
    score -= state.hintsUsed * _hintPenalty;

    // Incorrect guess penalty: -15 per wrong answer
    score -= state.incorrectGuesses * _incorrectGuessPenalty;

    // Time penalty: -5 per 20 seconds after 3 minute grace period
    if (state.startTime != null) {
      final elapsed = DateTime.now().difference(state.startTime!);
      if (elapsed.inSeconds > _gracePeriodSeconds) {
        final overtime = elapsed.inSeconds - _gracePeriodSeconds;
        final intervals = overtime ~/ _timePenaltyInterval;
        score -= intervals * _timePenaltyPoints;
      }
    }

    // Clamp to 0-100 and round to nearest 5
    final clamped = score.clamp(0, 100).toInt();
    return ((clamped + 2) ~/ 5) * 5;
  }

  void resetGame() {
    state = const AlmanacGameState();
  }
}

final almanacGameProvider =
    StateNotifierProvider<AlmanacGameNotifier, AlmanacGameState>((ref) {
  return AlmanacGameNotifier(ref);
});

// ============ Stats ============

/// Storage service provider
final almanacStorageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Almanac streak - calculated from completed puzzles
final almanacStreakProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(almanacStorageServiceProvider);
  return storage.calculateStreak();
});

/// Almanac total completed puzzles count (daily + archive)
final almanacCompletedCountProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(almanacStorageServiceProvider);
  final dailyCompleted = await storage.getCompletedPuzzles();
  final archiveCompleted = await storage.getCompletedArchivePuzzles();
  // Merge both sets to avoid double-counting if same date in both
  final allCompleted = {...dailyCompleted, ...archiveCompleted};
  return allCompleted.length;
});

// ============ Initialization ============

Future<void> initializeAlmanacServices(WidgetRef ref) async {
  await ref.read(almanacGameProvider.notifier).loadPuzzle();
}
