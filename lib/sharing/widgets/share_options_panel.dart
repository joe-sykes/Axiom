import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;

import '../models/daily_scores.dart';
import '../providers/sharing_providers.dart';
import 'compare_input_dialog.dart';
import 'profile_setup_dialog.dart';

/// Panel showing share options when all puzzles are complete.
class ShareOptionsPanel extends ConsumerWidget {
  final DailyScores scores;

  const ShareOptionsPanel({
    super.key,
    required this.scores,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00B8B5).withOpacity(0.15),
            const Color(0xFF9B59B6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00B8B5).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALL COMPLETE!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Total: ${scores.totalScore}/${scores.maxTotalScore}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (profile != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.displayName,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _shareUrl(context, ref),
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Share Link'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareEmoji(context, ref),
                  icon: const Icon(Icons.emoji_emotions, size: 18),
                  label: const Text('Share Emoji'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _compareFriend(context, ref),
              icon: const Icon(Icons.people, size: 18),
              label: const Text('Compare with Friend'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ensureProfile(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider);
    if (profile != null) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProfileSetupDialog(),
    );
  }

  Future<void> _shareUrl(BuildContext context, WidgetRef ref) async {
    await _ensureProfile(context, ref);

    final profile = ref.read(userProfileProvider);
    if (profile == null) return;

    final url = ref.read(shareUrlProvider);
    if (url == null) {
      _showError(context, 'Could not generate share link');
      return;
    }

    await _shareContent(context, url, 'Share your Axiom score');
  }

  Future<void> _shareEmoji(BuildContext context, WidgetRef ref) async {
    await _ensureProfile(context, ref);

    final profile = ref.read(userProfileProvider);
    if (profile == null) return;

    final emojiString = ref.read(shareEmojiStringProvider);
    if (emojiString == null) {
      _showError(context, 'Could not generate emoji code');
      return;
    }

    const taglines = [
      'Decode my score if you dare',
      'Can you crack the code?',
      'Think you can beat this?',
      'Your move',
      'Decipher this',
    ];
    final tagline = taglines[Random().nextInt(taglines.length)];

    final message = '''
$emojiString

$tagline
https://axiom-puzzles.com
''';

    await _shareContent(context, message, 'Share your Axiom score');
  }

  Future<void> _shareContent(BuildContext context, String content, String subject) async {
    if (kIsWeb) {
      await Clipboard.setData(ClipboardData(text: content));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      await Clipboard.setData(ClipboardData(text: content));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      await Share.share(content, subject: subject);
    }
  }

  void _compareFriend(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CompareInputDialog(),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }
}
