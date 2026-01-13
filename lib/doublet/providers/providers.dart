import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/firebase/firebase_manager.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/scoring_utils.dart';
import '../models/game_session.dart';
import '../models/puzzle.dart';
import '../models/user_stats.dart';
import '../services/dictionary_service.dart';
import '../services/game_validator.dart';
import '../services/puzzle_service.dart';
import '../services/storage_service.dart';

// ============ Core Dependencies ============

/// SharedPreferences instance - must be initialized before app starts
final doubletPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

/// Firestore instance for Doublet
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseManager.doubletFirestore;
});

// ============ Services ============

/// Dictionary service for word validation
final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  return DictionaryService();
});

/// Puzzle service for fetching puzzles
final puzzleServiceProvider = Provider<PuzzleService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final prefs = ref.watch(doubletPrefsProvider);
  return PuzzleService(firestore, prefs);
});

/// Storage service for local persistence
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(doubletPrefsProvider);
  return StorageService(prefs);
});

/// Game validator for input/submission validation
final gameValidatorProvider = Provider<GameValidator>((ref) {
  final dictionary = ref.watch(dictionaryServiceProvider);
  return GameValidator(dictionary);
});

// ============ Puzzle State ============

/// Today's puzzle index
final todaysPuzzleIndexProvider = Provider<int>((ref) {
  return PuzzleDateUtils.getTodaysPuzzleIndex();
});

/// Today's puzzle number (for display)
final todaysPuzzleNumberProvider = Provider<int>((ref) {
  return PuzzleDateUtils.getTodaysPuzzleNumber();
});

/// Fetch today's puzzle
final todaysPuzzleProvider = FutureProvider<Puzzle>((ref) async {
  final service = ref.watch(puzzleServiceProvider);
  final index = ref.watch(todaysPuzzleIndexProvider);
  return service.getPuzzle(index);
});

/// Fetch a specific puzzle by index
final puzzleProvider = FutureProvider.family<Puzzle, int>((ref, index) async {
  final service = ref.watch(puzzleServiceProvider);
  return service.getPuzzle(index);
});

// ============ Game State ============

/// Active game session state
class GameStateNotifier extends StateNotifier<GameSession?> {
  final Ref _ref;

  GameStateNotifier(this._ref) : super(null);

  /// Start a new game
  void startGame(Puzzle puzzle, bool isDailyPuzzle) {
    state = GameSession.initial(
      puzzleIndex: puzzle.index,
      inputCount: puzzle.inputCount,
      isDailyPuzzle: isDailyPuzzle,
    );
  }

  /// Update a word at a specific index
  void setWord(int index, String word) {
    if (state == null) return;

    final newWords = [...state!.userWords];
    newWords[index] = word.toUpperCase().trim();

    state = state!.copyWith(userWords: newWords);
  }

  /// Submit the current solution
  Future<GameValidationResult> submitSolution(Puzzle puzzle) async {
    if (state == null) {
      return GameValidationResult.incorrect('No active game');
    }

    final validator = _ref.read(gameValidatorProvider);
    final result = await validator.validateSubmission(
      puzzle: puzzle,
      userWords: state!.enteredWords,
    );

    if (result.isCorrect) {
      // Calculate score
      final score = ScoringUtils.calculateScore(
        timeTaken: state!.elapsedTime,
        incorrectSubmissions: state!.incorrectSubmissions,
      );

      // Mark game as complete
      state = state!.copyWith(
        isComplete: true,
        wasSuccessful: true,
        finalScore: score,
      );

      // Record in storage
      final storage = _ref.read(storageServiceProvider);
      if (state!.isDailyPuzzle) {
        await storage.recordDailyPuzzleCompletion(
          puzzleIndex: puzzle.index,
          score: score,
          wasSuccessful: true,
          timeTaken: state!.elapsedTime,
          incorrectAttempts: state!.incorrectSubmissions,
        );
      } else {
        await storage.recordArchivePuzzleCompletion(
          puzzleIndex: puzzle.index,
          score: score,
          wasSuccessful: true,
          timeTaken: state!.elapsedTime,
          incorrectAttempts: state!.incorrectSubmissions,
        );
      }

      // Refresh stats
      _ref.invalidate(userStatsProvider);
    } else {
      // Record incorrect submission
      state = state!.copyWith(
        incorrectSubmissions: state!.incorrectSubmissions + 1,
      );
    }

    return result;
  }

  /// End game as failed (give up)
  Future<void> giveUp(Puzzle puzzle) async {
    if (state == null) return;

    state = state!.copyWith(
      isComplete: true,
      wasSuccessful: false,
      finalScore: 0,
    );

    // Record in storage
    final storage = _ref.read(storageServiceProvider);
    if (state!.isDailyPuzzle) {
      await storage.recordDailyPuzzleCompletion(
        puzzleIndex: puzzle.index,
        score: 0,
        wasSuccessful: false,
        timeTaken: state!.elapsedTime,
        incorrectAttempts: state!.incorrectSubmissions,
      );
    } else {
      await storage.recordArchivePuzzleCompletion(
        puzzleIndex: puzzle.index,
        score: 0,
        wasSuccessful: false,
        timeTaken: state!.elapsedTime,
        incorrectAttempts: state!.incorrectSubmissions,
      );
    }

    // Refresh stats
    _ref.invalidate(userStatsProvider);
  }

  /// Clear current game
  void clearGame() {
    state = null;
  }
}

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameSession?>((ref) {
  return GameStateNotifier(ref);
});

// ============ User Stats ============

/// User statistics
final userStatsProvider = Provider<UserStats>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.loadStats();
});

/// Whether today's puzzle has been completed
final hasCompletedTodayProvider = Provider<bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.hasCompletedTodaysPuzzle();
});

/// Whether user has seen the help dialog
final hasSeenHelpProvider = Provider<bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.hasSeenHelp();
});

// ============ Theme ============

/// Theme mode state
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeModeNotifier(this._storage)
      : super(_storage.getThemeMode() ?? ThemeMode.system);

  void setTheme(ThemeMode mode) {
    _storage.setThemeMode(mode);
    state = mode;
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(newMode);
  }
}

final doubletThemeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storage);
});

// ============ Initialization ============

/// Initialize all services that need async setup
Future<void> initializeDoubletServices(WidgetRef ref) async {
  final dictionary = ref.read(dictionaryServiceProvider);
  await dictionary.initialize();

  // Check and reset streak if needed
  final storage = ref.read(storageServiceProvider);
  await storage.checkAndResetStreakIfNeeded();

  // Prefetch puzzles in background (non-blocking, non-critical)
  final puzzleService = ref.read(puzzleServiceProvider);
  final todayIndex = ref.read(todaysPuzzleIndexProvider);
  // Don't await - prefetch runs in background without blocking app startup
  puzzleService.prefetchForToday(todayIndex);
}
