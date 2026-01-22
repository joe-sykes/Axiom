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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose an emoji and 4-letter name for sharing scores.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Emoji + Name input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Emoji picker button
              InkWell(
                onTap: _selectEmoji,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 56,
                  height: 56,
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
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name input
              Expanded(
                child: TextField(
                  controller: _nameController,
                  maxLength: 4,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                    _UpperCaseTextFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: 'ALEX',
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: const OutlineInputBorder(),
                    errorText: _hasInteracted && !_isValid
                        ? '4 letters required'
                        : null,
                  ),
                  onChanged: (_) {
                    setState(() {
                      _hasInteracted = true;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Preview: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${EmojiLists.getTagEmoji(_selectedEmojiIndex)}${_nameController.text.toUpperCase().padRight(4, '_')}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
