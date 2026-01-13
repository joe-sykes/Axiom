import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Service for validating words against the Scrabble dictionary
class DictionaryService {
  Set<String>? _dictionary;
  bool _isLoaded = false;
  bool _isLoading = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  /// Whether the dictionary has been loaded
  bool get isLoaded => _isLoaded;

  /// Number of words in the dictionary
  int get wordCount => _dictionary?.length ?? 0;

  /// Load dictionary from bundled asset with retry logic
  Future<void> initialize() async {
    if (_isLoaded) return;
    if (_isLoading) {
      // Wait for ongoing load to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }

    _isLoading = true;

    try {
      final content = await rootBundle.loadString('assets/dictionary.txt');
      _dictionary = content
          .split('\n')
          .map((word) => word.trim().toUpperCase())
          .where((word) => word.isNotEmpty)
          .toSet();

      _isLoaded = true;
      _retryCount = 0;
      debugPrint('Dictionary loaded: ${_dictionary!.length} words');
    } catch (e) {
      debugPrint('Dictionary load failed (attempt ${_retryCount + 1}): $e');
      _retryCount++;

      if (_retryCount < _maxRetries) {
        _isLoading = false;
        // Retry after a short delay
        await Future.delayed(Duration(milliseconds: 100 * _retryCount));
        return initialize();
      }

      throw DictionaryLoadException('Failed to load dictionary after $_maxRetries attempts: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Ensure dictionary is loaded, with retry if needed
  Future<bool> ensureLoaded() async {
    if (_isLoaded) return true;

    try {
      _retryCount = 0; // Reset retry count for fresh attempt
      await initialize();
      return _isLoaded;
    } catch (e) {
      debugPrint('ensureLoaded failed: $e');
      return false;
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
