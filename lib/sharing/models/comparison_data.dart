import '../constants/emoji_lists.dart';
import 'daily_scores.dart';

/// Decoded comparison data from a share link or emoji string.
class ComparisonData {
  /// Protocol version.
  final int version;

  /// Date the scores are for.
  final DateTime date;

  /// Player's 4-character name.
  final String playerName;

  /// Index into [EmojiLists.tagEmojis].
  final int emojiIndex;

  /// Scores for each game (ordered by [GameType] index).
  final List<int> scores;

  /// Whether the checksum validated successfully.
  final bool isValid;

  /// Error message if decoding failed.
  final String? errorMessage;

  const ComparisonData({
    required this.version,
    required this.date,
    required this.playerName,
    required this.emojiIndex,
    required this.scores,
    required this.isValid,
    this.errorMessage,
  });

  /// Create an invalid result with an error message.
  factory ComparisonData.invalid(String message) => ComparisonData(
        version: 0,
        date: DateTime.now(),
        playerName: '????',
        emojiIndex: 0,
        scores: [],
        isValid: false,
        errorMessage: message,
      );

  /// Get the player's emoji.
  String get playerEmoji => EmojiLists.getTagEmoji(emojiIndex);

  /// Display name with emoji (e.g., "🎮ALEX").
  String get displayName => '$playerEmoji$playerName';

  /// Total score across all games.
  int get totalScore => scores.fold(0, (sum, score) => sum + score);

  /// Get score for a specific game type.
  int scoreForGame(GameType game) {
    if (game.index < scores.length) {
      return scores[game.index];
    }
    return 0;
  }

  /// Date formatted as YYYY-MM-DD.
  String get dateString => date.toIso8601String().split('T')[0];

  @override
  String toString() =>
      'ComparisonData($displayName, date: $dateString, scores: $scores, '
      'valid: $isValid${errorMessage != null ? ', error: $errorMessage' : ''})';
}
