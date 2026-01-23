import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/route_names.dart';
import '../../core/theme/axiom_theme.dart';
import '../models/puzzle.dart';
import '../providers/cryptogram_providers.dart';
import '../services/storage_service.dart';

class CryptogramArchiveScreen extends ConsumerStatefulWidget {
  const CryptogramArchiveScreen({super.key});

  @override
  ConsumerState<CryptogramArchiveScreen> createState() => _CryptogramArchiveScreenState();
}

class _CryptogramArchiveScreenState extends ConsumerState<CryptogramArchiveScreen> {
  List<CryptogramPuzzle>? _puzzles;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
  }

  Future<void> _loadPuzzles() async {
    try {
      final service = ref.read(cryptogramFirestoreServiceProvider);
      final puzzles = await service.getArchivePuzzles(limit: 100);

      if (mounted) {
        setState(() {
          _puzzles = puzzles;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.cryptogram,
            (route) => false,
          ),
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline),
                SizedBox(width: 10),
                Text('CRYPTOGRAM'),
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
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
              child: _buildContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: AxiomColors.cyan),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _loadPuzzles();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_puzzles == null || _puzzles!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.archive_outlined,
                size: 64,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No archived puzzles yet',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Come back tomorrow to see today\'s puzzle in the archive!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _puzzles!.length,
          itemBuilder: (context, index) {
            final puzzle = _puzzles![index];
            return _ArchiveItem(
              puzzle: puzzle,
              onTap: () => _openPuzzle(puzzle),
            );
          },
        ),
      ),
    );
  }

  void _openPuzzle(CryptogramPuzzle puzzle) {
    Navigator.pushNamed(
      context,
      RouteNames.cryptogramArchivePuzzle,
      arguments: {'puzzle': puzzle},
    );
  }
}

class _ArchiveItem extends StatefulWidget {
  final CryptogramPuzzle puzzle;
  final VoidCallback onTap;

  const _ArchiveItem({required this.puzzle, required this.onTap});

  @override
  State<_ArchiveItem> createState() => _ArchiveItemState();
}

class _ArchiveItemState extends State<_ArchiveItem> {
  final CryptogramStorageService _storageService = CryptogramStorageService();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkCompletion();
  }

  Future<void> _checkCompletion() async {
    final completed = await _storageService.isAnyPuzzleCompleted(widget.puzzle.date);
    if (mounted) {
      setState(() => _isCompleted = completed);
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange.shade700;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMMM yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          dateFormat.format(DateTime.parse(widget.puzzle.date)),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isCompleted) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '— ${widget.puzzle.author}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(widget.puzzle.difficultyLabel),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.puzzle.difficultyLabel.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _isCompleted ? Icons.check_circle : Icons.play_circle_outline,
                color: _isCompleted ? Colors.green : theme.colorScheme.primary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
