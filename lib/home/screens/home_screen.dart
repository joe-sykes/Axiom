import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../almanac/providers/almanac_providers.dart';
import '../../core/constants/route_names.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/axiom_theme.dart';
import '../../core/widgets/app_footer.dart';
import '../../core/widgets/migration_banner.dart';
import '../../cryptix/providers/cryptix_providers.dart';
import '../../cryptogram/providers/cryptogram_providers.dart';
import '../../doublet/providers/providers.dart';
import '../../main.dart' show migrationJustCompleted;
import '../../sharing/models/daily_scores.dart';
import '../../sharing/providers/sharing_providers.dart';
import '../../sharing/widgets/progress_bar_widget.dart';
import '../../triverse/providers/triverse_providers.dart';

class AxiomHomeScreen extends ConsumerStatefulWidget {
  const AxiomHomeScreen({super.key});

  @override
  ConsumerState<AxiomHomeScreen> createState() => _AxiomHomeScreenState();
}

class _AxiomHomeScreenState extends ConsumerState<AxiomHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Show migration success message if just migrated
    if (migrationJustCompleted) {
      migrationJustCompleted = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Your progress has been transferred successfully!'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    // Get stats from each game
    final cryptixState = ref.watch(cryptixGameProvider);
    final doubletStats = ref.watch(userStatsProvider);
    final almanacStreakAsync = ref.watch(almanacStreakProvider);
    final almanacStreak = almanacStreakAsync.valueOrNull ?? 0;
    final almanacCompletedAsync = ref.watch(almanacCompletedCountProvider);
    final almanacCompleted = almanacCompletedAsync.valueOrNull ?? 0;
    final triverseStreakAsync = ref.watch(triverseStreakProvider);
    final triverseStreak = triverseStreakAsync.valueOrNull ?? 0;
    final triverseCompletedAsync = ref.watch(triverseCompletedCountProvider);
    final triverseCompleted = triverseCompletedAsync.valueOrNull ?? 0;
    final cryptogramStreakAsync = ref.watch(cryptogramStreakProvider);
    final cryptogramStreak = cryptogramStreakAsync.valueOrNull ?? 0;
    final cryptogramSolvedAsync = ref.watch(cryptogramTotalSolvedProvider);
    final cryptogramSolved = cryptogramSolvedAsync.valueOrNull ?? 0;

    return Column(
      children: [
        // Migration banner (only shows on old domain)
        const MigrationBanner(),
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_white_64.png',
                    height: 28,
                    width: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AXIOM',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () =>
                      ref.read(themeModeProvider.notifier).toggleTheme(),
                  tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                ),
              ],
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 800
                      ? 4
                      : (constraints.maxWidth > 500 ? 2 : 1);
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Main content
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Progress bar
                                const DailyProgressBar(),
                                const SizedBox(height: 16),
                                // Header
                                Text(
                                  'DAILY PUZZLES',
                                  style:
                                      Theme.of(context).textTheme.headlineMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Choose your challenge',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.outline,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),

                                // Game cards
                                GridView.count(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio:
                                      crossAxisCount == 1 ? 1.6 : 1.0,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _GameCard(
                                      title: 'Almanac',
                                      subtitle: 'Daily Logic Puzzle',
                                      icon: Icons.lightbulb_outline,
                                      accentColor: AxiomColors.almanacAccent,
                                      route: RouteNames.almanac,
                                      gameType: GameType.almanac,
                                      streak:
                                          almanacStreak > 0 ? almanacStreak : null,
                                      played: almanacCompleted > 0
                                          ? almanacCompleted
                                          : null,
                                    ),
                                    _GameCard(
                                      title: 'Cryptix',
                                      subtitle: 'Daily Cryptic Clue',
                                      icon: Icons.quiz_outlined,
                                      accentColor: AxiomColors.cryptixAccent,
                                      route: RouteNames.cryptix,
                                      gameType: GameType.cryptix,
                                      streak: cryptixState.stats.currentStreak > 0
                                          ? cryptixState.stats.currentStreak
                                          : null,
                                      played: cryptixState.stats.totalSolved > 0
                                          ? cryptixState.stats.totalSolved
                                          : null,
                                    ),
                                    _GameCard(
                                      title: 'Doublet',
                                      subtitle: 'Daily Word Ladder',
                                      icon: Icons.linear_scale,
                                      accentColor: AxiomColors.doubletAccent,
                                      route: RouteNames.doubletPlay,
                                      gameType: GameType.doublet,
                                      streak: doubletStats.currentStreak > 0
                                          ? doubletStats.currentStreak
                                          : null,
                                      played: doubletStats.totalGamesPlayed > 0
                                          ? doubletStats.totalGamesPlayed
                                          : null,
                                    ),
                                    _GameCard(
                                      title: 'Triverse',
                                      subtitle: 'Daily Trivia Challenge',
                                      icon: Icons.bolt,
                                      accentColor: AxiomColors.triverseAccent,
                                      route: RouteNames.triverse,
                                      gameType: GameType.triverse,
                                      streak:
                                          triverseStreak > 0 ? triverseStreak : null,
                                      played: triverseCompleted > 0
                                          ? triverseCompleted
                                          : null,
                                    ),
                                    _GameCard(
                                      title: 'Cryptogram',
                                      subtitle: 'Daily Quote Cipher',
                                      icon: Icons.lock_outline,
                                      accentColor: AxiomColors.cryptogramAccent,
                                      route: RouteNames.cryptogram,
                                      gameType: GameType.cryptogram,
                                      streak: cryptogramStreak > 0
                                          ? cryptogramStreak
                                          : null,
                                      played: cryptogramSolved > 0
                                          ? cryptogramSolved
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Footer at bottom
                            const Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: AppFooter(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GameCard extends ConsumerWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String route;
  final int? streak;
  final int? played;
  final GameType gameType;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.route,
    required this.gameType,
    this.streak,
    this.played,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasStats = streak != null || played != null;
    final isCompleted = ref.watch(gameCompletionProvider(gameType));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, route),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withValues(alpha: 0.15),
                      accentColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 48, color: accentColor),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    if (hasStats) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (streak != null) ...[
                            const Icon(
                              Icons.local_fire_department,
                              size: 18,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$streak',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                          if (streak != null && played != null)
                            const SizedBox(width: 16),
                          if (played != null) ...[
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: accentColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$played',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Completion checkmark
          if (isCompleted)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
