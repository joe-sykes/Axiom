import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/route_names.dart';
import '../providers/triverse_providers.dart';
import '../widgets/answer_button.dart';
import '../widgets/feedback_overlay.dart';
import '../widgets/fifty_fifty_button.dart';
import '../widgets/results_dialog.dart';
import '../widgets/timer_bar.dart';

class TriversePlay extends ConsumerStatefulWidget {
  const TriversePlay({super.key});

  @override
  ConsumerState<TriversePlay> createState() => _TriversePlayState();
}

class _TriversePlayState extends ConsumerState<TriversePlay> {
  final GlobalKey<TimerBarState> _timerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = ref.read(triverseGameProvider);
      if (gameState.phase == TriverseGamePhase.notStarted) {
        ref.read(triverseGameProvider.notifier).startGame();
      }
    });
  }

  void _handleTimeUp() {
    ref.read(triverseGameProvider.notifier).timeExpired();
  }

  void _handleAnswerSelected(int index) {
    final gameState = ref.read(triverseGameProvider);
    if (gameState.phase != TriverseGamePhase.playing) return;

    // Select and immediately submit
    ref.read(triverseGameProvider.notifier).selectAnswer(index);
    ref.read(triverseGameProvider.notifier).submitAnswer();
  }

  void _handleContinue() {
    final notifier = ref.read(triverseGameProvider.notifier);
    notifier.nextQuestion();

    // Check if game is complete after moving to next
    final newState = ref.read(triverseGameProvider);
    if (newState.isComplete) {
      _showResults();
    } else {
      // Reset timer for next question
      _timerKey.currentState?.reset();
    }
  }

  void _handleFiftyFifty() {
    ref.read(triverseGameProvider.notifier).useFiftyFifty();
  }

  void _showResults() {
    // Stop the timer before showing results
    _timerKey.currentState?.stop();

    final gameState = ref.read(triverseGameProvider);
    final streak = ref.read(triverseStreakProvider).valueOrNull ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TriverseResultsDialog(
        score: gameState.totalScore,
        correctCount: gameState.correctCount,
        totalQuestions: gameState.puzzle?.questionCount ?? 7,
        streak: streak,
        averageTimeSeconds: gameState.answers.isNotEmpty
            ? gameState.answers
                    .fold(0, (sum, a) => sum + a.timeMs) /
                gameState.answers.length /
                1000
            : 0,
        onClose: () {
          // Navigate to home to show completed state
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.triverse,
            (route) => route.settings.name == RouteNames.home,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(triverseGameProvider);
    final theme = Theme.of(context);

    if (gameState.puzzle == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt),
              SizedBox(width: 8),
              Text('TRIVERSE'),
            ],
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final puzzle = gameState.puzzle!;
    final currentQuestion = puzzle.questions[gameState.currentQuestionIndex];
    final isInFeedback = gameState.phase == TriverseGamePhase.feedback;
    final lastAnswer = gameState.answers.isNotEmpty ? gameState.answers.last : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          ),
          tooltip: 'Back to Axiom',
        ),
        title: GestureDetector(
          onTap: () {
            // Check if already played today
            final alreadyPlayed = ref.read(triverseAlreadyPlayedTodayProvider).valueOrNull ?? false;
            if (alreadyPlayed) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.triverseArchive,
                (route) => route.settings.name == RouteNames.home,
              );
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.triverse,
                (route) => route.settings.name == RouteNames.home,
              );
            }
          },
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt),
                SizedBox(width: 8),
                Text('TRIVERSE'),
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question number and category (above timer)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Question ${gameState.currentQuestionIndex + 1}/7',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentQuestion.category,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Timer (duration based on category) - only show during playing phase
                  if (gameState.phase == TriverseGamePhase.playing)
                    TimerBar(
                      key: _timerKey,
                      durationMs: getTimeLimitForCategory(currentQuestion.category),
                      onTimeUp: _handleTimeUp,
                      isPaused: false,
                    ),
                  if (gameState.phase != TriverseGamePhase.playing) const SizedBox(height: 32),

                  const SizedBox(height: 16),

                  // Question and answers
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                currentQuestion.text,
                                style: theme.textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Answer buttons
                          ...List.generate(4, (index) {
                            final isRemoved = gameState.fiftyFiftyRemovedIndices
                                    ?.contains(index) ??
                                false;

                            AnswerButtonState buttonState;
                            if (isInFeedback) {
                              if (index == currentQuestion.correctIndex) {
                                buttonState = AnswerButtonState.correct;
                              } else if (lastAnswer?.selectedIndex == index) {
                                buttonState = AnswerButtonState.incorrect;
                              } else {
                                buttonState = AnswerButtonState.disabled;
                              }
                            } else if (isRemoved) {
                              buttonState = AnswerButtonState.disabled;
                            } else {
                              buttonState = AnswerButtonState.normal;
                            }

                            return AnswerButton(
                              text: currentQuestion.answers[index],
                              index: index,
                              state: buttonState,
                              onTap: (isInFeedback || isRemoved)
                                  ? null
                                  : () => _handleAnswerSelected(index),
                            );
                          }),

                          // 50/50 button (directly below answers)
                          if (!isInFeedback) ...[
                            const SizedBox(height: 16),
                            Center(
                              child: FiftyFiftyButton(
                                isUsed: gameState.fiftyFiftyUsed,
                                onTap: _handleFiftyFifty,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Fixed bottom feedback bar during feedback phase
                  if (isInFeedback && lastAnswer != null)
                    _FeedbackBar(
                      isCorrect: lastAnswer.correct,
                      correctAnswer: currentQuestion.correctAnswer,
                      onContinue: _handleContinue,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackBar extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final VoidCallback onContinue;

  const _FeedbackBar({
    required this.isCorrect,
    required this.correctAnswer,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? Colors.green : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border(top: BorderSide(color: color, width: 2)),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCorrect ? 'Correct!' : 'Incorrect',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (!isCorrect)
                  Text(
                    correctAnswer,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
