import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/route_names.dart';
import '../providers/core_providers.dart';
import '../widgets/app_footer.dart';

/// Unified Privacy Policy screen for all Axiom games
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: GestureDetector(
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          ),
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text('AXIOM'),
          ),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Privacy Policy',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Last updated: ${DateTime.now().year}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // TL;DR Box at top
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock, size: 24, color: theme.colorScheme.tertiary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TL;DR',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.lock, size: 24, color: theme.colorScheme.tertiary),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'We only collect anonymous analytics. No accounts, no personal data, no creepy tracking. Your game progress stays on your device. Simple!',
                                style: theme.textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        _Section(
                          icon: Icons.waving_hand,
                          title: 'Overview',
                          content:
                              'Axiom is designed with your privacy in mind. We believe puzzles should be fun, not stressful - and worrying about your data definitely isn\'t fun! We collect minimal data and store everything locally on your device.',
                        ),

                        _Section(
                          icon: Icons.analytics,
                          title: 'Data We Collect',
                          content:
                              'We only collect anonymous usage data through Google Analytics to help us understand how the app is used and make it even better:',
                          bullets: const [
                            'Page views and navigation patterns',
                            'Device type and browser information',
                            'Geographic region (country level only)',
                            'App performance metrics',
                          ],
                        ),

                        _Section(
                          icon: Icons.block,
                          title: 'Data We Do NOT Collect',
                          content: 'Here\'s what we promise NOT to collect:',
                          bullets: const [
                            'Personal information (name, email, etc.)',
                            'Account credentials (we don\'t even have accounts!)',
                            'Your puzzle answers or solving patterns',
                            'Any data that could identify you personally',
                            'Your secret puzzle-solving strategies',
                          ],
                        ),

                        _Section(
                          icon: Icons.save,
                          title: 'Local Storage',
                          content:
                              'Your game progress, statistics, and preferences are stored locally on your device. This includes:',
                          bullets: const [
                            'Puzzles you\'ve solved',
                            'Your streak and score history',
                            'Theme preference (light/dark mode)',
                          ],
                        ),

                        _Section(
                          icon: Icons.cookie,
                          title: 'No Cookies Banner',
                          content:
                              'You might have noticed we don\'t have an annoying cookies banner - that\'s because we don\'t use cookies for tracking or advertising! Google Analytics uses local storage and doesn\'t place tracking cookies. You\'re welcome.',
                        ),

                        _Section(
                          icon: Icons.person_off,
                          title: 'No Accounts',
                          content:
                              'Axiom doesn\'t require or support user accounts. All your data stays on your device, which means:\n\n- Maximum privacy\n- No password to remember\n- But if you clear your browser data, your progress will be lost\n\nSo maybe don\'t do that!',
                        ),

                        _Section(
                          icon: Icons.link,
                          title: 'Third-Party Services',
                          content:
                              'We use these third-party services (and they\'re pretty trustworthy):',
                          bullets: const [
                            'Google Analytics - for anonymous usage statistics',
                            'Firebase/Firestore - for storing puzzle data (read-only)',
                          ],
                        ),

                        _Section(
                          icon: Icons.schedule,
                          title: 'Data Retention',
                          content:
                              'Analytics data is retained according to Google Analytics\' default retention policies. Your local data is retained until you clear it manually - so your streak is safe!',
                        ),

                        _Section(
                          icon: Icons.gavel,
                          title: 'Your Rights',
                          content:
                              'Since we don\'t collect personal data, there\'s nothing to delete or export. You can clear your local data at any time by clearing your browser\'s storage for this site.',
                        ),

                        _ContactSection(),

                        const SizedBox(height: 32),

                        // Fun footer
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.extension, size: 32, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Icon(Icons.security, size: 32, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Icon(Icons.auto_awesome, size: 32, color: theme.colorScheme.primary),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'That\'s it! Pretty simple, right?\nNow go solve some puzzles!',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final List<String>? bullets;

  const _Section({
    required this.icon,
    required this.title,
    required this.content,
    this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyLarge,
          ),
          if (bullets != null) ...[
            const SizedBox(height: 8),
            ...bullets!.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(left: 32, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: theme.textTheme.bodyLarge,
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mail, size: 24, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Contact',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'For bug reports, feature requests, or any other enquiries, contact us at:',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          SelectableText(
            'fruitstonepuzzles@gmail.com',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
