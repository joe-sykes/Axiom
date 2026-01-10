import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/route_names.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/axiom_theme.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                Text('Almanac'),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last updated: ${DateTime.now().year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),

                _buildSection(
                  context,
                  'The Short Version',
                  'We keep things simple here at Almanac. We collect minimal data, '
                  "we don't sell anything to anyone, and we're just here to give "
                  "your brain a good workout. That's it. That's the policy.",
                ),

                _buildSection(
                  context,
                  'What We Collect',
                  'Honestly, not much:\n\n'
                  '\u2022 Your puzzle progress and scores (stored locally on your device)\n'
                  '\u2022 Your streak data (also local - we love seeing you come back!)\n'
                  '\u2022 Basic analytics to see if anyone is actually playing\n\n'
                  "We don't ask for your email, your first pet's name, or your "
                  "mother's maiden name. We're a puzzle game, not a bank.",
                ),

                _buildSection(
                  context,
                  'Cookies',
                  "We use the essential ones to keep things running smoothly. "
                  "No tracking cookies following you around the internet like a lost puppy. "
                  "Your puzzle-solving habits stay between us.",
                ),

                _buildSection(
                  context,
                  'Third-Party Services',
                  'We use Firebase (by Google) to host the app and store puzzles. '
                  "They have their own privacy policy that's probably longer than this one. "
                  "But we're not sharing your personal data with them because... "
                  "well, we don't have any to share!",
                ),

                _buildSection(
                  context,
                  'Data Security',
                  "Your high scores are protected by the same technology that "
                  "protects your browser. We can't see them, we can't change them, "
                  "and we definitely can't give you hints. Sorry.",
                ),

                _buildSection(
                  context,
                  'Children',
                  "Almanac is suitable for puzzle enthusiasts of all ages. "
                  "We don't knowingly collect data from anyone, "
                  "let alone children. If a kid beats your score, "
                  "that's between you and your ego.",
                ),

                _buildSection(
                  context,
                  'Changes to This Policy',
                  "If we ever need to update this policy, we'll do it here. "
                  "But let's be honest - our main job is making puzzles, "
                  "not writing legal documents.",
                ),

                _buildSection(
                  context,
                  'Contact',
                  "Got questions? Concerns? Puzzle ideas? "
                  "We'd love to hear from you! Just... we're still setting up "
                  "the contact form. Check back later, or solve another puzzle "
                  "while you wait.",
                ),

                const SizedBox(height: 32),
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteNames.home,
                        (route) => false,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AxiomColors.cyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AxiomColors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.psychology, color: AxiomColors.cyan, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'Now go solve some puzzles!',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AxiomColors.cyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: AxiomColors.cyan, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AxiomColors.cyan,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
