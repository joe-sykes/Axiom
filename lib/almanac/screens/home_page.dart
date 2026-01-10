import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/axiom_theme.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/stats_bar.dart';
import '../models/puzzle.dart';
import '../providers/almanac_providers.dart';

/// Helper to get optimized image URL from Firebase Storage
String getOptimizedImageUrl(String originalUrl, {int? width}) {
  if (width == null || !originalUrl.contains('firebasestorage.googleapis.com')) {
    return originalUrl;
  }
  return originalUrl;
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();

  bool _isCorrect = false;
  bool _hasSubmitted = false;
  int _streak = 0;
  int _hintsUsed = 0;
  List<bool> _hintsRevealed = [false, false, false];

  // Timer for scoring
  DateTime? _puzzleStartTime;
  Timer? _scoreTimer;
  int _currentScore = 100;
  int? _finalScore; // Store final score for reopening dialog

  // Animation controller for logo
  late AnimationController _logoAnimationController;
  late Animation<double> _logoRotation;

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _logoRotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeInOut),
    );

    // Load puzzle on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(almanacGameProvider.notifier).loadPuzzle();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _logoAnimationController.dispose();
    _scoreTimer?.cancel();
    super.dispose();
  }

  void _startScoreTimer() {
    _puzzleStartTime = DateTime.now();
    _scoreTimer?.cancel();
    _scoreTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_puzzleStartTime == null || _isCorrect) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(_puzzleStartTime!);
      if (elapsed.inSeconds > 180) {
        final secondsOverThreshold = elapsed.inSeconds - 180;
        final timeDeduction = (secondsOverThreshold / 10).floor();
        final hintDeduction = _hintsUsed * 20;
        final newScore = (100 - timeDeduction - hintDeduction).clamp(0, 100);
        if (newScore != _currentScore) {
          setState(() {
            _currentScore = newScore;
          });
        }
      }
    });
  }

  int _calculateFinalScore() {
    if (_puzzleStartTime == null) return 100;

    final elapsed = DateTime.now().difference(_puzzleStartTime!);
    int score = 100;

    if (elapsed.inSeconds > 180) {
      final secondsOverThreshold = elapsed.inSeconds - 180;
      score -= (secondsOverThreshold / 10).floor();
    }

    score -= _hintsUsed * 20;
    return score.clamp(0, 100);
  }

  void _submitAnswer() {
    final guess = _answerController.text;
    if (guess.trim().isEmpty) return;

    final gameState = ref.read(almanacGameProvider);
    if (gameState.todaysPuzzle == null) return;

    final correct = ref.read(almanacGameProvider.notifier).checkAnswer(guess);
    if (correct) {
      _scoreTimer?.cancel();
      final score = _calculateFinalScore();
      _finalScore = score;
      _showCompletionDialog(score);
    }
    setState(() {
      _isCorrect = correct;
      _hasSubmitted = true;
    });
  }

  Widget _buildScoreIcons(int score) {
    if (score >= 90) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 48, color: Colors.amber),
          SizedBox(width: 8),
          Icon(Icons.auto_awesome, size: 48, color: Colors.amber),
          SizedBox(width: 8),
          Icon(Icons.celebration, size: 48, color: Colors.amber),
        ],
      );
    }
    if (score >= 70) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 48, color: Colors.amber),
          SizedBox(width: 8),
          Icon(Icons.gps_fixed, size: 48, color: Colors.blue),
        ],
      );
    }
    if (score >= 50) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.thumb_up, size: 48, color: Colors.blue),
          SizedBox(width: 8),
          Icon(Icons.fitness_center, size: 48, color: Colors.orange),
        ],
      );
    }
    return const Icon(Icons.gps_fixed, size: 48, color: Colors.blue);
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return 'Amazing!';
    if (score >= 70) return 'Great Job!';
    if (score >= 50) return 'Good Work!';
    return 'Puzzle Complete!';
  }

  void _showCompletionDialog(int score) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final message = _getScoreMessage(score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Score icons
                _buildScoreIcons(score),
                const SizedBox(height: 16),

                // Message
                Text(
                  message,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AxiomColors.success : AxiomColors.successDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Score display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isDark ? AxiomColors.success : AxiomColors.successDark)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Score',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$score',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AxiomColors.success : AxiomColors.successDark,
                        ),
                      ),
                      Text(
                        'out of 100',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CompletionStatItem(
                      label: 'Hints Used',
                      value: '$_hintsUsed',
                      icon: Icons.lightbulb_outline,
                    ),
                    _CompletionStatItem(
                      label: 'Streak',
                      value: '$_streak',
                      icon: Icons.local_fire_department,
                    ),
                  ],
                ),

                if (_hintsUsed > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    '-${_hintsUsed * 20} points for hints',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AxiomColors.pink,
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareScore(score),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy Score'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.pushNamed(context, RouteNames.almanacArchive);
                    },
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('View Archive'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareScore(int score) {
    String emoji;
    if (score >= 90) {
      emoji = '🏆';
    } else if (score >= 70) {
      emoji = '⭐';
    } else if (score >= 50) {
      emoji = '👍';
    } else {
      emoji = '🎯';
    }

    final shareText = '$emoji I just scored $score on today\'s Almanac.\nThink you can beat me? 🧠\n👉 https://axiompuzzles.web.app';

    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Score copied to clipboard!'),
        backgroundColor: AxiomColors.cyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _revealHint(int index) {
    if (_hintsRevealed[index]) return;
    ref.read(almanacGameProvider.notifier).revealHint(index);
    setState(() {
      _hintsRevealed[index] = true;
      _hintsUsed++;
      _currentScore = (_currentScore - 20).clamp(0, 100);
    });
  }

  void _tryAgain() {
    setState(() {
      _isCorrect = false;
      _hasSubmitted = false;
      _answerController.clear();
    });
  }

  void _openArchive() {
    Navigator.pushNamed(context, RouteNames.almanacArchive);
  }

  void _toggleTheme() {
    ref.read(themeModeProvider.notifier).toggleTheme();
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.image_search, size: 28),
              SizedBox(width: 10),
              Text('About Almanac'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Almanac is a daily puzzle game where you identify images from clues.',
                  style: Theme.of(dialogContext).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'How to Play',
                  style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                    color: AxiomColors.cyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('1. View the daily puzzle image and clue'),
                const Text('2. Type your answer and submit'),
                const Text('3. Use hints if you need help (-20 points each)'),
                const SizedBox(height: 16),
                Text(
                  'Scoring System',
                  style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                    color: AxiomColors.cyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Start with 100 points'),
                const Text('After 3 minutes: -1 point every 10 seconds'),
                const Text('Each hint used: -20 points'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final day = date.day;
      String suffix;
      if (day >= 11 && day <= 13) {
        suffix = 'th';
      } else {
        switch (day % 10) {
          case 1:
            suffix = 'st';
          case 2:
            suffix = 'nd';
          case 3:
            suffix = 'rd';
          default:
            suffix = 'th';
        }
      }
      final month = DateFormat('MMMM').format(date);
      return '$day$suffix $month ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(almanacGameProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    // Start timer when puzzle is ready
    if (gameState.state == AlmanacPuzzleState.ready && _puzzleStartTime == null) {
      _startScoreTimer();
    }

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
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          ),
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image_search),
                SizedBox(width: 10),
                Text('ALMANAC'),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'About Almanac',
            onPressed: _showInfoDialog,
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View Archive',
            onPressed: _openArchive,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(gameState)),
            if (_streak > 0)
              StatsBar(
                streak: _streak,
                played: _streak,
              ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AlmanacGameState gameState) {
    if (gameState.state == AlmanacPuzzleState.loading) {
      _logoAnimationController.repeat();
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _logoRotation,
              child: const Icon(Icons.image_search, size: 100),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading puzzle...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    _logoAnimationController.stop();
    _logoAnimationController.reset();

    if (gameState.state == AlmanacPuzzleState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AxiomColors.pink),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                gameState.errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.read(almanacGameProvider.notifier).loadPuzzle(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (gameState.todaysPuzzle == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.extension, size: 64, color: AxiomColors.cyan),
            const SizedBox(height: 16),
            Text(
              'No puzzle available today',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return _buildPuzzleContent(gameState.todaysPuzzle!);
  }

  Widget _buildPuzzleContent(AlmanacPuzzle puzzle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AxiomColors.darkNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Puzzle for ${_formatDate(puzzle.date)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AxiomColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // Puzzle image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Theme.of(context).cardTheme.color,
                  child: Image.network(
                    puzzle.imageUrl,
                    fit: BoxFit.contain,
                    cacheWidth: 800,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: Theme.of(context).cardTheme.color,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AxiomColors.cyan,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Theme.of(context).cardTheme.color,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 48, color: AxiomColors.pink),
                              const SizedBox(height: 8),
                              Text('Failed to load image',
                                  style: TextStyle(color: AxiomColors.pink)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    puzzle.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Hints section
              if (!_isCorrect && puzzle.hints.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildHintsSection(puzzle),
              ],

              const SizedBox(height: 32),

              // Answer section
              _buildAnswerSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintsSection(AlmanacPuzzle puzzle) {
    final hints = puzzle.hints;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AxiomColors.cyan),
                const SizedBox(width: 8),
                Text(
                  'Hints',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '-20 points each',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AxiomColors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(hints.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _hintsRevealed[index]
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AxiomColors.cyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AxiomColors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          hints[index],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () => _revealHint(index),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: Text('Reveal Hint ${index + 1}'),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection() {
    // Success state
    if (_isCorrect) {
      return Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AxiomColors.cyan, width: 2),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: AxiomColors.cyan, size: 72),
              const SizedBox(height: 16),
              Text(
                'Correct!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AxiomColors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Great job solving today\'s puzzle!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_streak > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        '$_streak day streak!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      if (_finalScore != null) {
                        _showCompletionDialog(_finalScore!);
                      }
                    },
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('View Results'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openArchive,
                    icon: const Icon(Icons.history),
                    label: const Text('View Archive'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Incorrect state
    if (_hasSubmitted && !_isCorrect) {
      return Card(
        color: AxiomColors.pink.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.close, color: AxiomColors.pink, size: 72),
              const SizedBox(height: 16),
              Text(
                'Not quite right',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AxiomColors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Give it another try!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _tryAgain,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Answer input
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Your Answer',
                hintText: 'Type your guess here...',
                prefixIcon: Icon(Icons.edit),
              ),
              onSubmitted: (_) => _submitAnswer(),
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitAnswer,
                icon: const Icon(Icons.send),
                label: const Text('Submit Answer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _CompletionStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
