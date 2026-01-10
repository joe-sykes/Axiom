import 'package:flutter/services.dart' show rootBundle;

/// Service for validating words against the Scrabble dictionary
class DictionaryService {
  Set<String>? _dictionary;
  bool _isLoaded = false;

  /// Whether the dictionary has been loaded
  bool get isLoaded => _isLoaded;

  /// Number of words in the dictionary
  int get wordCount => _dictionary?.length ?? 0;

  /// Load dictionary from bundled asset
  Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      final content = await rootBundle.loadString('assets/dictionary.txt');
      _dictionary = content
          .split('\n')
          .map((word) => word.trim().toUpperCase())
          .where((word) => word.isNotEmpty)
          .toSet();

      _isLoaded = true;
    } catch (e) {
      throw DictionaryLoadException('Failed to load dictionary: $e');
    }
  }

  /// Check if a word is in the Scrabble dictionary
  bool isValidWord(String word) {
    if (!_isLoaded) {
      throw StateError('Dictionary not initialized. Call initialize() first.');
    }
    return _dictionary!.contains(word.toUpperCase().trim());
  }

  /// Validate user input during gameplay
  /// Returns true if word is valid (allowed)
  /// Per requirements: words are allowed UNLESS not in dictionary
  bool validateInput(String word) {
    if (word.isEmpty) return false;
    return isValidWord(word);
  }

  /// Get all valid words of a specific length
  List<String> getWordsOfLength(int length) {
    if (!_isLoaded) return [];
    return _dictionary!.where((w) => w.length == length).toList();
  }
}

class DictionaryLoadException implements Exception {
  final String message;
  DictionaryLoadException(this.message);

  @override
  String toString() => message;
}
