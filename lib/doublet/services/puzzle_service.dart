import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/puzzle.dart';

/// Service for fetching and caching puzzles
class PuzzleService {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  // In-memory cache for current session
  final Map<int, Puzzle> _memoryCache = {};

  PuzzleService(this._firestore, this._prefs);

  /// Fetch puzzle with multi-layer caching
  Future<Puzzle> getPuzzle(int index) async {
    // Layer 1: Memory cache
    if (_memoryCache.containsKey(index)) {
      return _memoryCache[index]!;
    }

    // Layer 2: Disk cache (SharedPreferences)
    final cached = _getFromDiskCache(index);
    if (cached != null) {
      _memoryCache[index] = cached;
      return cached;
    }

    // Layer 3: Firestore
    try {
      final puzzle = await _fetchFromFirestore(index);

      // Populate caches
      _memoryCache[index] = puzzle;
      await _saveToDiskCache(index, puzzle);

      return puzzle;
    } on FirebaseException catch (e) {
      // Network error - try disk cache as fallback (might have expired)
      final cached = _getFromDiskCache(index, ignoreExpiry: true);
      if (cached != null) {
        return cached;
      }
      throw PuzzleLoadException('Unable to load puzzle $index: ${e.message}');
    }
  }

  Puzzle? _getFromDiskCache(int index, {bool ignoreExpiry = false}) {
    final key = '${AppConstants.puzzleCacheKeyPrefix}$index';
    final json = _prefs.getString(key);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(data['_cachedAt'] as String);

      // Check expiry
      if (!ignoreExpiry &&
          DateTime.now().difference(cachedAt) > AppConstants.cacheExpiry) {
        _prefs.remove(key);
        return null;
      }

      return Puzzle.fromJson(data);
    } catch (e) {
      _prefs.remove(key);
      return null;
    }
  }

  Future<void> _saveToDiskCache(int index, Puzzle puzzle) async {
    final key = '${AppConstants.puzzleCacheKeyPrefix}$index';
    final data = puzzle.toJson();
    data['_cachedAt'] = DateTime.now().toIso8601String();
    await _prefs.setString(key, jsonEncode(data));
  }

  Future<Puzzle> _fetchFromFirestore(int index) async {
    final doc = await _firestore
        .collection(AppConstants.puzzlesCollection)
        .doc(index.toString())
        .get();

    if (!doc.exists) {
      throw PuzzleNotFoundException(index);
    }

    return Puzzle.fromFirestore(doc);
  }

  /// Prefetch upcoming puzzles for offline use
  Future<void> prefetchPuzzles(List<int> indices) async {
    for (final index in indices) {
      try {
        if (!_memoryCache.containsKey(index) &&
            _getFromDiskCache(index) == null) {
          await getPuzzle(index);
        }
      } catch (e) {
        // Silently fail prefetch - non-critical
      }
    }
  }

  /// Prefetch today's puzzle and nearby puzzles
  Future<void> prefetchForToday(int todayIndex) async {
    final indices = <int>[];

    // Today + next 7 days
    for (int i = 0; i < 8; i++) {
      indices.add((todayIndex + i) % AppConstants.totalPuzzles);
    }

    await prefetchPuzzles(indices);
  }

  /// Check if puzzle is cached
  bool isCached(int index) {
    return _memoryCache.containsKey(index) ||
        _getFromDiskCache(index) != null;
  }

  /// Clear all cached puzzles
  Future<void> clearCache() async {
    _memoryCache.clear();
    final keys = _prefs
        .getKeys()
        .where((k) => k.startsWith(AppConstants.puzzleCacheKeyPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}

class PuzzleNotFoundException implements Exception {
  final int index;
  PuzzleNotFoundException(this.index);

  @override
  String toString() => 'Puzzle $index not found';
}

class PuzzleLoadException implements Exception {
  final String message;
  PuzzleLoadException(this.message);

  @override
  String toString() => message;
}
