import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/core_providers.dart';
import '../../core/widgets/app_footer.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text('CRYPTIX'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        actions: [
          Builder(
            builder: (context) {
              final isDark = themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) == Brightness.dark);
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/archive'),
            tooltip: 'Archive',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.of(context).pushNamed('/help'),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                ConstrainedBox(
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
                            'Last updated: 2026',
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
                                  const Text('🔒', style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TL;DR',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('🔒', style: TextStyle(fontSize: 24)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'We only collect anonymous analytics. No accounts, no personal data, no creepy tracking. Your game progress stays on your device. Simple! 🎉',
                                style: theme.textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        _Section(
                          emoji: '👋',
                          title: 'Overview',
                          content:
                              'CRYPTIX is designed with your privacy in mind. We believe puzzles should be fun, not stressful - and worrying about your data definitely isn\'t fun! We collect minimal data and store everything locally on your device.',
                        ),

                        _Section(
                          emoji: '📊',
                          title: 'Data We Collect',
                          content:
                              'We only collect anonymous usage data through Google Analytics to help us understand how the app is used and make it even better:',
                          bullets: [
                            'Page views and navigation patterns',
                            'Device type and browser information',
                            'Geographic region (country level only)',
                            'App performance metrics',
                          ],
                        ),

                        _Section(
                          emoji: '🚫',
                          title: 'Data We Do NOT Collect',
                          content: 'Here\'s what we promise NOT to collect:',
                          bullets: [
                            'Personal information (name, email, etc.)',
                            'Account credentials (we don\'t even have accounts!)',
                            'Your puzzle answers or solving patterns',
                            'Any data that could identify you personally',
                            'Your secret cryptic-solving strategies 🤫',
                          ],
                        ),

                        _Section(
                          emoji: '💾',
                          title: 'Local Storage',
                          content:
                              'Your game progress, statistics, and preferences are stored locally on your device. This includes:',
                          bullets: [
                            'Puzzles you\'ve solved ✓',
                            'Your streak and score history 🔥',
                            'Theme preference (light/dark mode) 🌙',
                          ],
                        ),

                        _Section(
                          emoji: '🍪',
                          title: 'No Cookies Banner',
                          content:
                              'You might have noticed we don\'t have an annoying cookies banner - that\'s because we don\'t use cookies for tracking or advertising! Google Analytics uses local storage and doesn\'t place tracking cookies. You\'re welcome. 😊',
                        ),

                        _Section(
                          emoji: '👤',
                          title: 'No Accounts',
                          content:
                              'CRYPTIX doesn\'t require or support user accounts. All your data stays on your device, which means:\n\n• Maximum privacy 🛡️\n• No password to remember 🧠\n• But if you clear your browser data, your progress will be lost 😢\n\nSo maybe don\'t do that!',
                        ),

                        _Section(
                          emoji: '🔗',
                          title: 'Third-Party Services',
                          content:
                              'We use these third-party services (and they\'re pretty trustworthy):',
                          bullets: [
                            'Google Analytics - for anonymous usage statistics',
                            'Firebase/Firestore - for storing puzzle data (read-only)',
                          ],
                        ),

                        _Section(
                          emoji: '⏰',
                          title: 'Data Retention',
                          content:
                              'Analytics data is retained according to Google Analytics\' default retention policies. Your local data is retained until you clear it manually - so your streak is safe!',
                        ),

                        _Section(
                          emoji: '⚖️',
                          title: 'Your Rights',
                          content:
                              'Since we don\'t collect personal data, there\'s nothing to delete or export. You can clear your local data at any time by clearing your browser\'s storage for this site. But then you\'d lose your streak... and we\'d be sad. 😢',
                        ),

                        _Section(
                          emoji: '📬',
                          title: 'Contact',
                          content:
                              'Contact information coming soon! In the meantime, if you have questions about this privacy policy, keep solving puzzles and we\'ll figure it out. 🧩',
                        ),

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
                                const Text(
                                  '🧩 🔐 ✨',
                                  style: TextStyle(fontSize: 32),
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

                        // Navigation links
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 16),
                        Center(
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                },
                                icon: const Icon(Icons.home, size: 18),
                                label: const Text('Home'),
                              ),
                              TextButton.icon(
                                onPressed: () => Navigator.of(context).pushNamed('/archive'),
                                icon: const Icon(Icons.archive_outlined, size: 18),
                                label: const Text('Archive'),
                              ),
                              TextButton.icon(
                                onPressed: () => Navigator.of(context).pushNamed('/help'),
                                icon: const Icon(Icons.help_outline, size: 18),
                                label: const Text('Help'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String emoji;
  final String title;
  final String content;
  final List<String>? bullets;

  const _Section({
    required this.emoji,
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
              Text(emoji, style: const TextStyle(fontSize: 24)),
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
