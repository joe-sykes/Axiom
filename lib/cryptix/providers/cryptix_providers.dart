import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/firebase/firebase_manager.dart';
import '../models/puzzle.dart';
import '../models/puzzle_progress.dart';
import '../models/user_stats.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/scoring_service.dart';

// ============ Core Dependencies ============

/// SharedPreferences instance - must be overridden at app startup
final cryptixPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden in ProviderScope at app startup',
  );
});

// ============ Services ============

/// Firestore service for Cryptix
final cryptixFirestoreProvider = Provider<CryptixFirestoreService>((ref) {
  return CryptixFirestoreService(FirebaseManager.cryptixFirestore);
});

/// Storage service for local persistence
final cryptixStorageProvider = Provider<CryptixStorageService>((ref) {
  final prefs = ref.watch(cryptixPrefsProvider);
  return CryptixStorageService(prefs);
});

// ============ Puzzle State ============

enum CryptixPuzzleState { loading, ready, solved, error }

class CryptixGameState {
  final CryptixPuzzle? todaysPuzzle;
  final PuzzleProgress? todaysProgress;
  final CryptixUserStats stats;
  final CryptixPuzzleState state;
  final String? errorMessage;
  final DateTime? startTime;
  final bool hintUsed;
  final int incorrectGuesses;
  final List<int> revealedLetters;

  const CryptixGameState({
    this.todaysPuzzle,
    this.todaysProgress,
    this.stats = const CryptixUserStats(),
    this.state = CryptixPuzzleState.loading,
    this.errorMessage,
    this.startTime,
    this.hintUsed = false,
    this.incorrectGuesses = 0,
    this.revealedLetters = const [],
  });

  bool get isSolved => todaysProgress?.solved ?? false;

  bool get canRevealLetter {
    if (todaysPuzzle == null) return false;
    return revealedLetters.length < todaysPuzzle!.length;
  }

  CryptixGameState copyWith({
    CryptixPuzzle? todaysPuzzle,
    PuzzleProgress? todaysProgress,
    CryptixUserStats? stats,
    CryptixPuzzleState? state,
    String? errorMessage,
    DateTime? startTime,
    bool? hintUsed,
    int? incorrectGuesses,
    List<int>? revealedLetters,
  }) {
    return CryptixGameState(
      todaysPuzzle: todaysPuzzle ?? this.todaysPuzzle,
      todaysProgress: todaysProgress ?? this.todaysProgress,
      stats: stats ?? this.stats,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      startTime: startTime ?? this.startTime,
      hintUsed: hintUsed ?? this.hintUsed,
      incorrectGuesses: incorrectGuesses ?? this.incorrectGuesses,
      revealedLetters: revealedLetters ?? this.revealedLetters,
    );
  }
}

class CryptixGameNotifier extends StateNotifier<CryptixGameState> {
  final Ref _ref;

  CryptixGameNotifier(this._ref) : super(const CryptixGameState());

  CryptixFirestoreService get _firestore => _ref.read(cryptixFirestoreProvider);
  CryptixStorageService get _storage => _ref.read(cryptixStorageProvider);

  Future<void> init() async {
    state = state.copyWith(state: CryptixPuzzleState.loading);

    try {
      final stats = _storage.getStats();
      state = state.copyWith(stats: stats);
      await loadTodaysPuzzle();
    } catch (e) {
      state = state.copyWith(
        state: CryptixPuzzleState.error,
        errorMessage: 'Failed to load puzzle: $e',
      );
    }
  }

  Future<void> loadTodaysPuzzle() async {
    try {
      final puzzle = await _firestore.getTodaysPuzzle();

      if (puzzle != null) {
        final progress = _storage.getPuzzleProgress(puzzle.uid);

        if (progress?.solved == true) {
          state = state.copyWith(
            todaysPuzzle: puzzle,
            todaysProgress: progress,
            state: CryptixPuzzleState.solved,
            hintUsed: progress!.hintUsed,
            incorrectGuesses: progress.incorrectGuesses,
            revealedLetters: List.from(progress.revealedLetters),
          );
        } else {
          state = state.copyWith(
            todaysPuzzle: puzzle,
            todaysProgress: progress,
            state: CryptixPuzzleState.ready,
            startTime: DateTime.now(),
            hintUsed: progress?.hintUsed ?? false,
            incorrectGuesses: progress?.incorrectGuesses ?? 0,
            revealedLetters: List.from(progress?.revealedLetters ?? []),
          );
        }
      } else {
        state = state.copyWith(
          state: CryptixPuzzleState.error,
          errorMessage: 'No puzzle available for today',
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: CryptixPuzzleState.error,
        errorMessage: 'Failed to load puzzle: $e',
      );
    }
  }

  void useHint() {
    if (!state.hintUsed && !state.isSolved) {
      state = state.copyWith(hintUsed: true);
      _saveCurrentProgress();
    }
  }

  void revealLetter() {
    if (!state.canRevealLetter || state.isSolved || state.todaysPuzzle == null) return;

    // Get list of unrevealed indices
    final unrevealedIndices = <int>[];
    for (int i = 0; i < state.todaysPuzzle!.length; i++) {
      if (!state.revealedLetters.contains(i)) {
        unrevealedIndices.add(i);
      }
    }

    if (unrevealedIndices.isEmpty) return;

    // Pick a random unrevealed index
    final random = Random();
    final randomIndex = unrevealedIndices[random.nextInt(unrevealedIndices.length)];
    final newRevealed = [...state.revealedLetters, randomIndex];
    state = state.copyWith(revealedLetters: newRevealed);
    _saveCurrentProgress();
  }

  Future<bool> submitGuess(String guess) async {
    if (state.todaysPuzzle == null || state.isSolved) return false;

    final isCorrect =
        guess.toUpperCase().trim() == state.todaysPuzzle!.answer.toUpperCase();

    if (isCorrect) {
      await _handleCorrectGuess();
    } else {
      state = state.copyWith(incorrectGuesses: state.incorrectGuesses + 1);
      _saveCurrentProgress();
    }

    return isCorrect;
  }

  Future<void> _handleCorrectGuess() async {
    final elapsed = DateTime.now().difference(state.startTime ?? DateTime.now());
    final score = ScoringService.calculateScore(
      elapsed: elapsed,
      hintUsed: state.hintUsed,
      incorrectGuesses: state.incorrectGuesses,
      revealedLetters: state.revealedLetters.length,
    );

    final progress = PuzzleProgress(
      puzzleUid: state.todaysPuzzle!.uid,
      solved: true,
      score: score,
      solvedAt: DateTime.now(),
      hintUsed: state.hintUsed,
      incorrectGuesses: state.incorrectGuesses,
      revealedLetters: state.revealedLetters,
    );

    await _storage.savePuzzleProgress(progress);
    await _updateStats(score);

    state = state.copyWith(
      todaysProgress: progress,
      state: CryptixPuzzleState.solved,
    );
  }

  Future<void> _saveCurrentProgress() async {
    if (state.todaysPuzzle == null) return;

    final progress = PuzzleProgress(
      puzzleUid: state.todaysPuzzle!.uid,
      solved: false,
      hintUsed: state.hintUsed,
      incorrectGuesses: state.incorrectGuesses,
      revealedLetters: state.revealedLetters,
    );
    await _storage.savePuzzleProgress(progress);
  }

  Future<void> _updateStats(int score) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPlayed = state.stats.lastPlayedDate;

    int newStreak;
    if (lastPlayed == null) {
      newStreak = 1;
    } else {
      final lastPlayedDay = DateTime(
        lastPlayed.year,
        lastPlayed.month,
        lastPlayed.day,
      );
      final difference = today.difference(lastPlayedDay).inDays;

      if (difference == 1) {
        newStreak = state.stats.currentStreak + 1;
      } else if (difference == 0) {
        newStreak = state.stats.currentStreak;
      } else {
        newStreak = 1;
      }
    }

    final newStats = state.stats.copyWith(
      currentStreak: newStreak,
      bestStreak: newStreak > state.stats.bestStreak ? newStreak : state.stats.bestStreak,
      totalSolved: state.stats.totalSolved + 1,
      totalScore: state.stats.totalScore + score,
      lastPlayedDate: now,
    );

    await _storage.saveStats(newStats);
    state = state.copyWith(stats: newStats);
  }

  Future<List<CryptixPuzzle>> getArchivePuzzles() async {
    return _firestore.getPastPuzzles();
  }

  Future<Map<int, PuzzleProgress>> getAllProgress() async {
    return _storage.getAllProgress();
  }

  Future<void> markArchivePuzzleSolved(int puzzleUid) async {
    final existingProgress = _storage.getPuzzleProgress(puzzleUid);
    if (existingProgress?.solved == true) return;

    final progress = PuzzleProgress(
      puzzleUid: puzzleUid,
      solved: true,
      solvedAt: DateTime.now(),
    );
    await _storage.savePuzzleProgress(progress);

    // Update totalSolved count for archive puzzles too
    final newStats = state.stats.copyWith(
      totalSolved: state.stats.totalSolved + 1,
    );
    await _storage.saveStats(newStats);
    state = state.copyWith(stats: newStats);
  }
}

final cryptixGameProvider =
    StateNotifierProvider<CryptixGameNotifier, CryptixGameState>((ref) {
  return CryptixGameNotifier(ref);
});

// ============ App State ============

class CryptixAppState {
  final bool isFirstLaunch;
  final bool initialized;

  const CryptixAppState({
    this.isFirstLaunch = true,
    this.initialized = false,
  });

  CryptixAppState copyWith({
    bool? isFirstLaunch,
    bool? initialized,
  }) {
    return CryptixAppState(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      initialized: initialized ?? this.initialized,
    );
  }
}

class CryptixAppNotifier extends StateNotifier<CryptixAppState> {
  final Ref _ref;

  CryptixAppNotifier(this._ref) : super(const CryptixAppState());

  CryptixStorageService get _storage => _ref.read(cryptixStorageProvider);

  Future<void> init() async {
    final isFirstLaunch = _storage.isFirstLaunch();
    state = CryptixAppState(
      isFirstLaunch: isFirstLaunch,
      initialized: true,
    );
  }

  Future<void> completeFirstLaunch() async {
    await _storage.setFirstLaunchComplete();
    state = state.copyWith(isFirstLaunch: false);
  }
}

final cryptixAppProvider =
    StateNotifierProvider<CryptixAppNotifier, CryptixAppState>((ref) {
  return CryptixAppNotifier(ref);
});

// ============ Initialization ============

Future<void> initializeCryptixServices(WidgetRef ref) async {
  await ref.read(cryptixAppProvider.notifier).init();
  await ref.read(cryptixGameProvider.notifier).init();
}
