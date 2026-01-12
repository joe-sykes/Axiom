import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../almanac/providers/almanac_providers.dart';
import '../../core/constants/route_names.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/axiom_theme.dart';
import '../../core/widgets/app_footer.dart';
import '../../cryptix/providers/cryptix_providers.dart';
import '../../doublet/providers/providers.dart';
import '../../triverse/providers/triverse_providers.dart';

class AxiomHomeScreen extends ConsumerWidget {
  const AxiomHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Scaffold(
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
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'DAILY PUZZLES',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your challenge',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Game cards
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: crossAxisCount == 1 ? 1.6 : 1.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                        _GameCard(
                          title: 'Almanac',
                          subtitle: 'Daily Image Puzzle',
                          icon: Icons.image_search,
                          accentColor: AxiomColors.almanacAccent,
                          route: RouteNames.almanac,
                          streak: almanacStreak > 0 ? almanacStreak : null,
                          played: almanacCompleted > 0 ? almanacCompleted : null,
                        ),
                        _GameCard(
                          title: 'Cryptix',
                          subtitle: 'Daily Cryptic Clue',
                          icon: Icons.quiz_outlined,
                          accentColor: AxiomColors.cryptixAccent,
                          route: RouteNames.cryptix,
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
                          streak: triverseStreak > 0 ? triverseStreak : null,
                          played: triverseCompleted > 0 ? triverseCompleted : null,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  const AppFooter(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String route;
  final int? streak;
  final int? played;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.route,
    this.streak,
    this.played,
  });

  @override
  Widget build(BuildContext context) {
    final hasStats = streak != null || played != null;

    return Card(
      clipBehavior: Clip.antiAlias,
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
                      Icon(
                        Icons.local_fire_department,
                        size: 18,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }
}
