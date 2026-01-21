import '../constants/emoji_lists.dart';

/// User profile for score sharing.
///
/// Contains a 4-character uppercase name and an emoji tag index.
class UserProfile {
  /// 4-character name (A-Z uppercase only).
  final String name;

  /// Index into [EmojiLists.tagEmojis] (0-255).
  final int emojiIndex;

  const UserProfile({
    required this.name,
    required this.emojiIndex,
  });

  /// Get the emoji character for this profile.
  String get emoji => EmojiLists.getTagEmoji(emojiIndex);

  /// Display name with emoji prefix (e.g., "🎮ALEX").
  String get displayName => '$emoji$name';

  /// Validate the profile data.
  bool get isValid =>
      name.length == 4 &&
      RegExp(r'^[A-Z]{4}$').hasMatch(name) &&
      emojiIndex >= 0 &&
      emojiIndex < 256;

  /// Create a copy with modified fields.
  UserProfile copyWith({
    String? name,
    int? emojiIndex,
  }) {
    return UserProfile(
      name: name ?? this.name,
      emojiIndex: emojiIndex ?? this.emojiIndex,
    );
  }

  /// Serialize to JSON map.
  Map<String, dynamic> toJson() => {
        'name': name,
        'emojiIndex': emojiIndex,
      };

  /// Deserialize from JSON map.
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? 'ANON',
        emojiIndex: json['emojiIndex'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          emojiIndex == other.emojiIndex;

  @override
  int get hashCode => name.hashCode ^ emojiIndex.hashCode;

  @override
  String toString() => 'UserProfile($displayName)';
}
