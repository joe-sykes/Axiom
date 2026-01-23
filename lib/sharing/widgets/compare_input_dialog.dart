import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/route_names.dart';
import '../providers/sharing_providers.dart';
import '../services/score_codec.dart';

/// Dialog for inputting a friend's share code to compare scores.
class CompareInputDialog extends ConsumerStatefulWidget {
  const CompareInputDialog({super.key});

  @override
  ConsumerState<CompareInputDialog> createState() => _CompareInputDialogState();
}

class _CompareInputDialogState extends ConsumerState<CompareInputDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Compare with Friend'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Paste your friend\'s share link or emoji code:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Paste link or emoji code here...',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) {
                setState(() {
                  _error = null;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Accepts: URL or emoji string',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _compare,
          child: const Text('Compare'),
        ),
      ],
    );
  }

  void _compare() {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        _error = 'Please paste a share code';
      });
      return;
    }

    // Try to decode the input
    final data = decodeShareData(input);

    if (!data.isValid) {
      setState(() {
        _error = data.errorMessage ?? "Couldn't read that code. Try again?";
      });
      return;
    }

    // Close dialog and navigate to comparison screen
    Navigator.of(context).pop();

    // Extract the encoded data to pass to the comparison screen
    String encodedData;
    if (input.contains('axiom-puzzles.com/c/')) {
      final uri = Uri.tryParse(input);
      encodedData = uri?.path.substring(3) ?? input;
    } else if (input.contains(' ')) {
      // Emoji string - convert to base64
      final base64 = ScoreCodec.fromEmojiString(input);
      encodedData = base64 ?? input;
    } else {
      encodedData = input;
    }

    Navigator.of(context).pushNamed(
      '${RouteNames.compare}/$encodedData',
    );
  }
}
