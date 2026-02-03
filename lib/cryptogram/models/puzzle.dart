/// Cryptogram puzzle model
class CryptogramPuzzle {
  final String id;
  final String date;
  final String quote;
  final String author;
  final int likes;
  final int difficulty;
  final String difficultyLabel;

  CryptogramPuzzle({
    required this.id,
    required this.date,
    required this.quote,
    required this.author,
    required this.likes,
    required this.difficulty,
    required this.difficultyLabel,
  });

  factory CryptogramPuzzle.fromMap(Map<String, dynamic> map, String id) {
    return CryptogramPuzzle(
      id: id,
      date: map['date'] as String? ?? id,
      quote: map['quote'] as String? ?? '',
      author: map['author'] as String? ?? 'Unknown',
      likes: map['likes'] as int? ?? 0,
      difficulty: map['difficulty'] as int? ?? 5,
      difficultyLabel: map['difficulty_label'] as String? ?? 'medium',
    );
  }

  /// Generate a cipher mapping for this puzzle (derangement - no letter maps to itself)
  Map<String, String> generateCipher() {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    List<String> shuffled;

    // Keep shuffling until no letter maps to itself (derangement)
    do {
      shuffled = List<String>.from(letters)..shuffle();
    } while (_hasFixedPoint(letters, shuffled));

    final cipher = <String, String>{};
    for (int i = 0; i < letters.length; i++) {
      cipher[letters[i]] = shuffled[i];
    }
    return cipher;
  }

  /// Check if any letter maps to itself
  static bool _hasFixedPoint(List<String> original, List<String> shuffled) {
    for (int i = 0; i < original.length; i++) {
      if (original[i] == shuffled[i]) return true;
    }
    return false;
  }

  /// Encode the quote using a cipher
  String encodeQuote(Map<String, String> cipher) {
    return quote.split('').map((char) {
      final upper = char.toUpperCase();
      if (cipher.containsKey(upper)) {
        return char == upper ? cipher[upper]! : cipher[upper]!.toLowerCase();
      }
      return char;
    }).join('');
  }
}
