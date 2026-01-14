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

  /// Generate a cipher mapping for this puzzle
  Map<String, String> generateCipher() {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    final shuffled = List<String>.from(letters)..shuffle();

    final cipher = <String, String>{};
    for (int i = 0; i < letters.length; i++) {
      cipher[letters[i]] = shuffled[i];
    }
    return cipher;
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
