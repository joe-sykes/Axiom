import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/axiom_theme.dart';
import '../../core/widgets/app_footer.dart';
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

  void _openPuzzleDetail(AlmanacPuzzle puzzle) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PuzzleDetailPage(puzzle: puzzle),
      ),
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
      return '$day$suffix $month';
    } catch (e) {
      return dateStr;
    }
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

    return RefreshIndicator(
      color: AxiomColors.cyan,
      onRefresh: _loadPastPuzzles,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          int crossAxisCount = 1;
          if (screenWidth >= 1200) {
            crossAxisCount = 4;
          } else if (screenWidth >= 900) {
            crossAxisCount = 3;
          } else if (screenWidth >= 600) {
            crossAxisCount = 2;
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Puzzle Archive',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final puzzle = _puzzles[index];
                      return _buildPuzzleCard(puzzle);
                    },
                    childCount: _puzzles.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: AppFooter(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPuzzleCard(AlmanacPuzzle puzzle) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openPuzzleDetail(puzzle),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Image.network(
                  puzzle.thumbnailUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Center(
                        child: CircularProgressIndicator(color: AxiomColors.cyan),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Center(
                        child: Icon(Icons.broken_image, color: AxiomColors.pink),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AxiomColors.darkNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDate(puzzle.date),
                      style: TextStyle(
                        color: AxiomColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    puzzle.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
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
  bool? _isCorrect;

  @override
  void dispose() {
    _answerController.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Theme.of(context).cardTheme.color,
                    child: Image.network(
                      widget.puzzle.imageUrl,
                      fit: BoxFit.contain,
                      cacheWidth: 800,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 300,
                          color: Theme.of(context).cardTheme.color,
                          child: Center(
                            child: CircularProgressIndicator(color: AxiomColors.cyan),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: Theme.of(context).cardTheme.color,
                          child: Center(
                            child: Icon(Icons.broken_image, size: 64, color: AxiomColors.pink),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                const AppFooter(),
              ],
            ),
          ),
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
