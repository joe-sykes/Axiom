import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_manager.dart';
import '../models/triverse_puzzle.dart';
import '../models/triverse_session.dart';
import '../services/triverse_puzzle_service.dart';
import '../services/triverse_storage_service.dart';

// ============ Constants ============

const double kMaxQuestionScore = 100 / 7; // ~14.29 points

// Time limits by category
int getTimeLimitForCategory(String category) {
  switch (category) {
    case 'Quick Fire':
      return 12000; // 12 seconds
    case 'Think Twice':
      return 15000; // 15 seconds
    case 'Brain Buster':
      return 20000; // 20 seconds
    default:
      return 15000; // Default 15 seconds
  }
}

// ============ Services ============

final triverseServiceProvider = Provider<TriverseService>((ref) {
  return TriverseService(FirebaseManager.triverseFirestore);
});

final triverseStorageProvider = Provider<TriverseStorageService>((ref) {
  return TriverseStorageService();
});

// ============ Puzzle State ============

final triverseTodaysPuzzleProvider = FutureProvider<TriverseDaily?>((ref) async {
  final service = ref.watch(triverseServiceProvider);
  return service.getTodaysPuzzle();
});

// ============ Game State ============

enum TriverseGamePhase { notStarted, playing, feedback, complete }

class TriverseGameState {
  final TriverseDaily? puzzle;
  final TriverseGamePhase phase;
  final int currentQuestionIndex;
  final List<UserAnswer> answers;
  final bool fiftyFiftyUsed;
  final List<int>? fiftyFiftyRemovedIndices;
  final int? selectedAnswerIndex;
  final int timerStartMs;
  final String? errorMessage;

  const TriverseGameState({
    this.puzzle,
    this.phase = TriverseGamePhase.notStarted,
    this.currentQuestionIndex = 0,
    this.answers = const [],
    this.fiftyFiftyUsed = false,
    this.fiftyFiftyRemovedIndices,
    this.selectedAnswerIndex,
    this.timerStartMs = 0,
    this.errorMessage,
  });

  TriverseGameState copyWith({
    TriverseDaily? puzzle,
    TriverseGamePhase? phase,
    int? currentQuestionIndex,
    List<UserAnswer>? answers,
    bool? fiftyFiftyUsed,
    List<int>? fiftyFiftyRemovedIndices,
    int? selectedAnswerIndex,
    int? timerStartMs,
    String? errorMessage,
    bool clearFiftyFifty = false,
    bool clearSelectedAnswer = false,
  }) {
    return TriverseGameState(
      puzzle: puzzle ?? this.puzzle,
      phase: phase ?? this.phase,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      fiftyFiftyUsed: fiftyFiftyUsed ?? this.fiftyFiftyUsed,
      fiftyFiftyRemovedIndices:
          clearFiftyFifty ? null : (fiftyFiftyRemovedIndices ?? this.fiftyFiftyRemovedIndices),
      selectedAnswerIndex:
          clearSelectedAnswer ? null : (selectedAnswerIndex ?? this.selectedAnswerIndex),
      timerStartMs: timerStartMs ?? this.timerStartMs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => puzzle == null && errorMessage == null;
  bool get hasError => errorMessage != null;
  bool get isComplete => phase == TriverseGamePhase.complete;

  int get totalScore => answers.fold(0.0, (sum, a) => sum + a.score).round();
  int get correctCount => answers.where((a) => a.correct).length;
  String get accuracyDisplay => '$correctCount/${puzzle?.questionCount ?? 7}';
}

class TriverseGameNotifier extends StateNotifier<TriverseGameState> {
  final Ref _ref;
  final Random _random = Random();

  TriverseGameNotifier(this._ref) : super(const TriverseGameState());

  Future<void> loadPuzzle() async {
    try {
      final puzzle = await _ref.read(triverseTodaysPuzzleProvider.future);
      if (puzzle != null) {
        state = state.copyWith(puzzle: puzzle);
      } else {
        state = state.copyWith(errorMessage: 'No puzzle available for today');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load puzzle: $e');
    }
  }

  void loadArchivePuzzle(TriverseDaily puzzle) {
    state = state.copyWith(puzzle: puzzle);
  }

  void startGame() {
    if (state.puzzle == null) return;
    state = state.copyWith(
      phase: TriverseGamePhase.playing,
      currentQuestionIndex: 0,
      answers: [],
      fiftyFiftyUsed: false,
      timerStartMs: DateTime.now().millisecondsSinceEpoch,
      clearFiftyFifty: true,
      clearSelectedAnswer: true,
    );
  }

  void selectAnswer(int index) {
    if (state.phase != TriverseGamePhase.playing) return;
    state = state.copyWith(selectedAnswerIndex: index);
  }

  void submitAnswer() {
    if (state.phase != TriverseGamePhase.playing) return;
    if (state.puzzle == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final timeMs = now - state.timerStartMs;
    final question = state.puzzle!.questions[state.currentQuestionIndex];
    final timeLimit = getTimeLimitForCategory(question.category);

    final selectedIndex = state.selectedAnswerIndex ?? -1;
    final correct = selectedIndex == question.correctIndex;

    // Calculate score based on time (relative to category's time limit)
    double score = 0;
    if (correct) {
      final timeRemaining = timeLimit - timeMs;
      final timeBonus = (timeRemaining / timeLimit).clamp(0.0, 1.0);
      score = kMaxQuestionScore * (0.5 + 0.5 * timeBonus);
    }

    final answer = UserAnswer(
      questionId: question.id,
      selectedIndex: selectedIndex,
      timeMs: timeMs,
      correct: correct,
      score: score,
    );

    final newAnswers = [...state.answers, answer];
    state = state.copyWith(
      answers: newAnswers,
      phase: TriverseGamePhase.feedback,
    );
  }

  void timeExpired() {
    if (state.phase != TriverseGamePhase.playing) return;
    if (state.puzzle == null) return;

    final question = state.puzzle!.questions[state.currentQuestionIndex];
    final timeLimit = getTimeLimitForCategory(question.category);
    final answer = UserAnswer(
      questionId: question.id,
      selectedIndex: -1,
      timeMs: timeLimit,
      correct: false,
      score: 0,
    );

    final newAnswers = [...state.answers, answer];
    state = state.copyWith(
      answers: newAnswers,
      phase: TriverseGamePhase.feedback,
    );
  }

  void nextQuestion() {
    if (state.puzzle == null) return;

    final nextIndex = state.currentQuestionIndex + 1;
    if (nextIndex >= state.puzzle!.questionCount) {
      state = state.copyWith(phase: TriverseGamePhase.complete);
      _saveCompletion();
    } else {
      state = state.copyWith(
        currentQuestionIndex: nextIndex,
        phase: TriverseGamePhase.playing,
        timerStartMs: DateTime.now().millisecondsSinceEpoch,
        clearFiftyFifty: true,
        clearSelectedAnswer: true,
      );
    }
  }

  void useFiftyFifty() {
    if (state.fiftyFiftyUsed) return;
    if (state.phase != TriverseGamePhase.playing) return;
    if (state.puzzle == null) return;

    final question = state.puzzle!.questions[state.currentQuestionIndex];
    final correctIndex = question.correctIndex;

    // Get indices of wrong answers
    final wrongIndices = <int>[];
    for (int i = 0; i < 4; i++) {
      if (i != correctIndex) wrongIndices.add(i);
    }

    // Shuffle and pick 2 to remove
    wrongIndices.shuffle(_random);
    final toRemove = wrongIndices.take(2).toList();

    state = state.copyWith(
      fiftyFiftyUsed: true,
      fiftyFiftyRemovedIndices: toRemove,
    );
  }

  Future<void> _saveCompletion() async {
    if (state.puzzle == null) return;
    final storage = _ref.read(triverseStorageProvider);
    await storage.markPuzzleCompleted(state.puzzle!.date, state.totalScore);
    _ref.invalidate(triverseStreakProvider);
    _ref.invalidate(triverseCompletedCountProvider);
    _ref.invalidate(triverseAlreadyPlayedTodayProvider);
    _ref.invalidate(triverseTodaysScoreProvider);
    _ref.invalidate(triverseCompletedPuzzlesProvider);
  }

  void reset() {
    state = const TriverseGameState();
  }
}

final triverseGameProvider =
    StateNotifierProvider<TriverseGameNotifier, TriverseGameState>((ref) {
  return TriverseGameNotifier(ref);
});

// ============ Stats ============

final triverseStreakProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(triverseStorageProvider);
  return storage.calculateStreak();
});

final triverseCompletedCountProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(triverseStorageProvider);
  final completed = await storage.getCompletedPuzzles();
  return completed.length;
});

final triverseAlreadyPlayedTodayProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(triverseStorageProvider);
  final now = DateTime.now().toUtc();
  final today =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return storage.isPuzzleCompleted(today);
});

final triverseTodaysScoreProvider = FutureProvider<int?>((ref) async {
  final storage = ref.watch(triverseStorageProvider);
  final now = DateTime.now().toUtc();
  final today =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return storage.getScoreForPuzzle(today);
});

final triverseCompletedPuzzlesProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final storage = ref.watch(triverseStorageProvider);
  final completed = await storage.getCompletedPuzzles();
  final scores = await storage.getPuzzleScores();
  return {
    'completed': completed,
    'scores': scores,
  };
});

final triverseArchivePuzzlesProvider =
    FutureProvider<List<TriverseDaily>>((ref) async {
  final service = ref.watch(triverseServiceProvider);
  return service.getArchivePuzzles();
});
