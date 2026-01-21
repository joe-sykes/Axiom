import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/emoji_lists.dart';
import '../models/user_profile.dart';
import '../providers/sharing_providers.dart';
import 'emoji_picker_dialog.dart';

/// Dialog for setting up or editing user profile (name + emoji).
class ProfileSetupDialog extends ConsumerStatefulWidget {
  const ProfileSetupDialog({super.key});

  @override
  ConsumerState<ProfileSetupDialog> createState() => _ProfileSetupDialogState();
}

class _ProfileSetupDialogState extends ConsumerState<ProfileSetupDialog> {
  late TextEditingController _nameController;
  int _selectedEmojiIndex = 0;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    final existingProfile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: existingProfile?.name ?? '');
    _selectedEmojiIndex = existingProfile?.emojiIndex ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final name = _nameController.text.trim().toUpperCase();
    return name.length == 4 && RegExp(r'^[A-Z]{4}$').hasMatch(name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Create Your Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose a name and emoji to identify yourself when sharing scores.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            // Emoji picker button
            Center(
              child: InkWell(
                onTap: _selectEmoji,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      EmojiLists.getTagEmoji(_selectedEmojiIndex),
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _selectEmoji,
                child: const Text('Tap to change emoji'),
              ),
            ),
            const SizedBox(height: 16),
            // Name input
            TextField(
              controller: _nameController,
              maxLength: 4,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                _UpperCaseTextFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'NAME (4 letters)',
                hintText: 'ALEX',
                counterText: '',
                border: const OutlineInputBorder(),
                errorText: _hasInteracted && !_isValid
                    ? 'Enter exactly 4 letters'
                    : null,
              ),
              onChanged: (_) {
                setState(() {
                  _hasInteracted = true;
                });
              },
            ),
            const SizedBox(height: 16),
            // Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Preview',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${EmojiLists.getTagEmoji(_selectedEmojiIndex)}${_nameController.text.toUpperCase().padRight(4, '_')}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isValid ? _saveProfile : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectEmoji() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => EmojiPickerDialog(
        selectedIndex: _selectedEmojiIndex,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedEmojiIndex = result;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_isValid) return;

    final profile = UserProfile(
      name: _nameController.text.trim().toUpperCase(),
      emojiIndex: _selectedEmojiIndex,
    );

    await ref.read(userProfileProvider.notifier).setProfile(profile);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

/// Text formatter that converts input to uppercase.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
