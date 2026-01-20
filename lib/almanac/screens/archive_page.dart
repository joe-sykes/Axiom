import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/axiom_theme.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/game_keyboard.dart';
import '../models/puzzle.dart';
import '../providers/almanac_providers.dart';

class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({super.key});

  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  List<AlmanacPuzzle> _puzzles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPastPuzzles();
  }

  Future<void> _loadPastPuzzles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final puzzles = await ref.read(almanacArchivePuzzlesProvider.future);
      setState(() {
        _puzzles = puzzles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openPuzzleDetail(AlmanacPuzzle puzzle) {
    Navigator.pushNamed(
      context,
      RouteNames.almanacArchivePuzzle,
      arguments: {'puzzle': puzzle},
    );
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
  }

  void _toggleTheme() {
    ref.read(themeModeProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: _goHome,
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb_outline),
                SizedBox(width: 10),
                Text('ALMANAC'),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AxiomColors.cyan),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AxiomColors.pink),
              const SizedBox(height: 16),
              Text(
                'Failed to load archive',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPastPuzzles,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_puzzles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AxiomColors.cyan),
            const SizedBox(height: 16),
            Text(
              'No past puzzles yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back tomorrow!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'ARCHIVE',
              style: theme.textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AxiomColors.cyan,
              onRefresh: _loadPastPuzzles,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _puzzles.length,
                    itemBuilder: (context, index) {
                      final puzzle = _puzzles[index];
                      return _ArchiveItem(
                        puzzle: puzzle,
                        onTap: () => _openPuzzleDetail(puzzle),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchiveItem extends StatelessWidget {
  final AlmanacPuzzle puzzle;
  final VoidCallback onTap;

  const _ArchiveItem({
    required this.puzzle,
    required this.onTap,
  });

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(puzzle.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      puzzle.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.play_circle_outline,
                size: 32,
                color: theme.colorScheme.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PuzzleDetailPage extends ConsumerStatefulWidget {
  final AlmanacPuzzle puzzle;

  const PuzzleDetailPage({super.key, required this.puzzle});

  @override
  ConsumerState<PuzzleDetailPage> createState() => _PuzzleDetailPageState();
}

class _PuzzleDetailPageState extends ConsumerState<PuzzleDetailPage> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  bool? _isCorrect;

  bool get _useCustomKeyboard {
    if (!kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    final guess = _answerController.text;
    if (guess.trim().isEmpty) return;

    final correct = widget.puzzle.checkAnswer(guess);
    setState(() {
      _isCorrect = correct;
    });
  }

  void _tryAgain() {
    setState(() {
      _isCorrect = null;
      _answerController.clear();
    });
  }

  void _toggleTheme() {
    ref.read(themeModeProvider.notifier).toggleTheme();
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
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_formatDate(widget.puzzle.date)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              widget.puzzle.description,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildAnswerSection(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Show custom keyboard on mobile devices when puzzle is not solved
            if (_useCustomKeyboard && _isCorrect != true)
              GameKeyboard(
                onKeyPressed: (letter) {
                  _answerController.text = _answerController.text + letter;
                  _answerController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _answerController.text.length),
                  );
                },
                onBackspace: () {
                  if (_answerController.text.isNotEmpty) {
                    _answerController.text = _answerController.text
                        .substring(0, _answerController.text.length - 1);
                    _answerController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _answerController.text.length),
                    );
                  }
                },
                onEnter: _submitAnswer,
                showEnter: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection() {
    if (_isCorrect == true) {
      return Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AxiomColors.cyan, width: 2),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: AxiomColors.cyan, size: 64),
              const SizedBox(height: 16),
              Text(
                'Correct!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AxiomColors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'All accepted answers:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: widget.puzzle.acceptedAnswers.map((answer) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AxiomColors.cyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AxiomColors.cyan.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      answer,
                      style: TextStyle(
                        color: AxiomColors.cyan,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }

    if (_isCorrect == false) {
      return Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AxiomColors.pink, width: 2),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.close, color: AxiomColors.pink, size: 64),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Can you guess this past puzzle?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              focusNode: _answerFocusNode,
              showCursor: true,
              readOnly: _useCustomKeyboard,
              keyboardType: _useCustomKeyboard ? TextInputType.none : null,
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
