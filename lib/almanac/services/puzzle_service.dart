import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puzzle.dart';

/// AlmanacPuzzleService - Handles all puzzle-related data fetching
class AlmanacPuzzleService {
  final FirebaseFirestore _firestore;

  AlmanacPuzzleService(this._firestore);

  /// Gets today's date in UTC as a string (YYYY-MM-DD format)
  String _getTodayDateUTC() {
    final now = DateTime.now().toUtc();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Fetches today's puzzle from Firestore
  Future<AlmanacPuzzle?> getTodaysPuzzle() async {
    try {
      final today = _getTodayDateUTC();

      final snapshot = await _firestore
          .collection('puzzles')
          .where('date', isEqualTo: today)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return AlmanacPuzzle.fromMap({
        'id': doc.id,
        ...doc.data(),
      });
    } catch (e) {
      throw Exception('Failed to fetch today\'s puzzle: $e');
    }
  }

  /// Fetches all past puzzles (before today)
  Future<List<AlmanacPuzzle>> getPastPuzzles() async {
    try {
      final today = _getTodayDateUTC();

      final snapshot = await _firestore.collection('puzzles').get();

      final pastPuzzles = snapshot.docs
          .where((doc) {
            final date = doc.data()['date'] as String?;
            return date != null && date.compareTo(today) < 0;
          })
          .map((doc) => AlmanacPuzzle.fromMap({'id': doc.id, ...doc.data()}))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return pastPuzzles;
    } catch (e) {
      throw Exception('Failed to fetch past puzzles: $e');
    }
  }
}
