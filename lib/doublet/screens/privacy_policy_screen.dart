import 'package:flutter/material.dart';

void showDoubletPrivacyPolicy(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const DoubletPrivacyPolicyDialog(),
  );
}

class DoubletPrivacyPolicyDialog extends StatelessWidget {
  const DoubletPrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Privacy Policy',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      title: 'The Short Version',
                      content:
                          'We don\'t collect your data. Seriously. Your scores, '
                          'streaks, and word-guessing abilities stay on your device. '
                          'We\'re too busy making puzzles to spy on you.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'What Stays on Your Device',
                      content: '''
Your game progress and scores
Your impressive (or not so impressive) streak
Your theme preference (we respect dark mode enthusiasts)
Your entire puzzle history

All of this is stored locally using your browser's storage. We never see it, and frankly, we don't want to know how many times you had to guess "SHORE".''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'What We Actually Store',
                      content:
                          'Just the puzzles! They live on Firebase so you can play '
                          'the same daily puzzle as everyone else. No accounts, no '
                          'profiles, no "please verify your email" nonsense.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'Cookies',
                      content:
                          'We don\'t use tracking cookies. The only cookies we care '
                          'about are the ones you might be snacking on while playing. '
                          '(We recommend chocolate chip.)',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'Analytics',
                      content:
                          'Firebase may collect basic anonymous usage data (like '
                          '"someone played the game"). This helps us know the app '
                          'is working. We can\'t identify you from this data, and '
                          'we definitely can\'t see that you took 47 attempts on '
                          'puzzle #42.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'Security',
                      content:
                          'Your local data is as secure as your device. We use '
                          'HTTPS for everything. The puzzles are read-only, so '
                          'no one can cheat by modifying them. (Nice try though.)',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'Children\'s Privacy',
                      content:
                          'Daily Doublet is safe for all ages. We don\'t collect '
                          'personal information from anyone, including children. '
                          'It\'s just words and puzzles, all the way down.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'Changes to This Policy',
                      content:
                          'If we ever change this policy, we\'ll update it here. '
                          'But honestly, our privacy stance is pretty simple: '
                          'your data is yours, and we like it that way.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'Contact',
                      content:
                          'Questions? Concerns? Found a bug? Just want to tell us '
                          'about your 30-day streak? We\'d love to hear from you! '
                          '(Contact details coming soon.)',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Last updated: ${DateTime.now().year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

/// Screen wrapper for routing
class DoubletPrivacyScreen extends StatelessWidget {
  const DoubletPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Show dialog immediately and pop when closed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDoubletPrivacyPolicy(context);
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
