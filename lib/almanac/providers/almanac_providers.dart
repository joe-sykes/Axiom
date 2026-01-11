import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/firebase/firebase_manager.dart';
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
  final service = ref.watch(almanacPuzzleServiceProvider);
  return service.getTodaysPuzzle();
});

/// Archive puzzles
final almanacArchivePuzzlesProvider = FutureProvider<List<AlmanacPuzzle>>((ref) async {
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

  const AlmanacGameState({
    this.todaysPuzzle,
    this.state = AlmanacPuzzleState.loading,
    this.errorMessage,
    this.isCorrect,
    this.hintsUsed = 0,
    this.hintsRevealed = const [false, false, false],
    this.score = 100,
    this.startTime,
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

  void revealHint(int index) {
    if (index < 0 || index >= 3) return;
    if (state.hintsRevealed[index]) return;

    final newRevealed = List<bool>.from(state.hintsRevealed);
    newRevealed[index] = true;

    // Score penalty for using hints
    final newScore = state.score - 10;

    state = state.copyWith(
      hintsRevealed: newRevealed,
      hintsUsed: state.hintsUsed + 1,
      score: newScore.clamp(0, 100),
    );
  }

  bool checkAnswer(String guess) {
    if (state.todaysPuzzle == null) return false;

    final isCorrect = state.todaysPuzzle!.checkAnswer(guess);
    state = state.copyWith(
      isCorrect: isCorrect,
      state: isCorrect ? AlmanacPuzzleState.solved : state.state,
    );
    return isCorrect;
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

/// Almanac total completed puzzles count
final almanacCompletedCountProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(almanacStorageServiceProvider);
  final completed = await storage.getCompletedPuzzles();
  return completed.length;
});

// ============ Initialization ============

Future<void> initializeAlmanacServices(WidgetRef ref) async {
  await ref.read(almanacGameProvider.notifier).loadPuzzle();
}
