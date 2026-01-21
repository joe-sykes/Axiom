/// Curated emoji lists for the sharing feature.
///
/// - [tagEmojis]: 256 emojis for user profile tags
/// - [encodingEmojis]: 64 emojis for encoding share data
class EmojiLists {
  EmojiLists._();

  /// 256 curated emojis for user profile tags.
  /// Includes faces, animals, food, objects, and symbols.
  /// No flags to ensure cross-platform compatibility.
  static const List<String> tagEmojis = [
    // Faces (0-63)
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
    '🙂', '😉', '😊', '😇', '🥰', '😍', '🤩', '😘',
    '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭',
    '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶', '😏',
    '😒', '🙄', '😬', '😮', '🤯', '😴', '🥳', '🤠',
    '🤡', '🥸', '😎', '🤓', '🧐', '😕', '😟', '🙁',
    '😮', '😯', '😲', '😳', '🥺', '😦', '😧', '😨',
    '😰', '😥', '😢', '😭', '😱', '😖', '😣', '😞',

    // Animals (64-127)
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
    '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🙈',
    '🙉', '🙊', '🐒', '🐔', '🐧', '🐦', '🐤', '🐣',
    '🐥', '🦆', '🦅', '🦉', '🦇', '🐺', '🐗', '🐴',
    '🦄', '🐝', '🐛', '🦋', '🐌', '🐞', '🐜', '🦟',
    '🦗', '🕷️', '🦂', '🐢', '🐍', '🦎', '🦖', '🦕',
    '🐙', '🦑', '🦐', '🦞', '🦀', '🐡', '🐠', '🐟',
    '🐬', '🐳', '🐋', '🦈', '🐊', '🐅', '🐆', '🦓',

    // Food (128-191)
    '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓',
    '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝',
    '🍅', '🍆', '🥑', '🥦', '🥬', '🥒', '🌶️', '🫑',
    '🌽', '🥕', '🫒', '🧄', '🧅', '🥔', '🍠', '🥐',
    '🥯', '🍞', '🥖', '🥨', '🧀', '🥚', '🍳', '🧈',
    '🥞', '🧇', '🥓', '🥩', '🍗', '🍖', '🦴', '🌭',
    '🍔', '🍟', '🍕', '🫓', '🥪', '🥙', '🧆', '🌮',
    '🌯', '🫔', '🥗', '🥘', '🫕', '🍝', '🍜', '🍲',

    // Objects & Symbols (192-255)
    '⭐', '🌟', '✨', '💫', '🔥', '💥', '💢', '💦',
    '💨', '🌈', '☀️', '🌙', '⚡', '❄️', '🌸', '🌺',
    '🌻', '🌼', '🌷', '🌹', '🏵️', '🎄', '🎋', '🎍',
    '🍀', '🍁', '🍂', '🍃', '🎈', '🎉', '🎊', '🎁',
    '🎀', '🎗️', '🏆', '🥇', '🥈', '🥉', '⚽', '🏀',
    '🏈', '⚾', '🥎', '🎾', '🏐', '🏉', '🎱', '🎯',
    '🎮', '🕹️', '🎲', '🧩', '♟️', '🎭', '🎨', '🎬',
    '🎤', '🎧', '🎼', '🎹', '🥁', '🎷', '🎺', '🎸',
  ];

  /// 64 distinct emojis for encoding share data (6 bits each).
  /// Chosen for visual distinctness and cross-platform support.
  static const List<String> encodingEmojis = [
    // Row 0 (0-7): Celestial
    '🌟', '🌙', '☀️', '⭐', '💫', '✨', '🔥', '💧',

    // Row 1 (8-15): Nature
    '🌈', '🍀', '🌸', '🌺', '🌻', '🌹', '🍁', '🍂',

    // Row 2 (16-23): Fruits
    '🍎', '🍊', '🍋', '🍉', '🍇', '🍓', '🍒', '🍑',

    // Row 3 (24-31): Animals 1
    '🐶', '🐱', '🐭', '🐰', '🦊', '🐻', '🐼', '🐨',

    // Row 4 (32-39): Animals 2
    '🦁', '🐯', '🐮', '🐷', '🐸', '🐵', '🐔', '🦉',

    // Row 5 (40-47): Objects
    '🎈', '🎁', '🎀', '🎄', '🎯', '🎲', '🎮', '🎸',

    // Row 6 (48-55): Hearts & Symbols
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '💎',

    // Row 7 (56-63): Activities
    '🚀', '✈️', '🎠', '🎡', '🎢', '⚽', '🏆', '🎭',
  ];

  /// Get emoji by index from tag list, with bounds checking.
  static String getTagEmoji(int index) {
    if (index < 0 || index >= tagEmojis.length) {
      return tagEmojis[0];
    }
    return tagEmojis[index];
  }

  /// Get emoji by index from encoding list, with bounds checking.
  static String getEncodingEmoji(int index) {
    if (index < 0 || index >= encodingEmojis.length) {
      return encodingEmojis[0];
    }
    return encodingEmojis[index];
  }

  /// Find index of emoji in encoding list, returns -1 if not found.
  /// Handles variation selectors that may be present or absent.
  static int getEncodingIndex(String emoji) {
    // First try exact match
    final exactIndex = encodingEmojis.indexOf(emoji);
    if (exactIndex != -1) return exactIndex;

    // Try matching without variation selectors
    final normalizedInput = _stripVariationSelectors(emoji);
    for (int i = 0; i < encodingEmojis.length; i++) {
      final normalizedEmoji = _stripVariationSelectors(encodingEmojis[i]);
      if (normalizedEmoji == normalizedInput) {
        return i;
      }
    }

    return -1;
  }

  /// Strip variation selectors (U+FE0E, U+FE0F) from an emoji.
  static String _stripVariationSelectors(String emoji) {
    return emoji.replaceAll('\uFE0E', '').replaceAll('\uFE0F', '');
  }
}
