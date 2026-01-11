import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/triverse_puzzle.dart';

/// Service for fetching Triverse puzzles from Firestore.
class TriverseService {
  final FirebaseFirestore _firestore;

  TriverseService(this._firestore);

  /// Gets today's date in UTC as a string (YYYY-MM-DD format)
  String _getTodayDateUTC() {
    final now = DateTime.now().toUtc();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Fetches today's Triverse puzzle from Firestore.
  Future<TriverseDaily?> getTodaysPuzzle() async {
    try {
      final today = _getTodayDateUTC();

      final doc =
          await _firestore.collection('triverse_puzzles').doc(today).get();

      if (!doc.exists) {
        return null;
      }

      return TriverseDaily.fromMap({
        'date': today,
        ...doc.data()!,
      });
    } catch (e) {
      throw Exception('Failed to fetch today\'s Triverse puzzle: $e');
    }
  }

  /// Fetches a specific puzzle by date.
  Future<TriverseDaily?> getPuzzleByDate(String date) async {
    try {
      final doc =
          await _firestore.collection('triverse_puzzles').doc(date).get();

      if (!doc.exists) {
        return null;
      }

      return TriverseDaily.fromMap({
        'date': date,
        ...doc.data()!,
      });
    } catch (e) {
      throw Exception('Failed to fetch Triverse puzzle for $date: $e');
    }
  }

  /// Fetches all past puzzles (before today) for the archive.
  Future<List<TriverseDaily>> getArchivePuzzles() async {
    try {
      final today = _getTodayDateUTC();

      // Get all puzzles and filter client-side to avoid index issues
      final querySnapshot = await _firestore
          .collection('triverse_puzzles')
          .get();

      final puzzles = querySnapshot.docs
          .where((doc) => doc.id.compareTo(today) < 0)
          .map((doc) {
            return TriverseDaily.fromMap({
              'date': doc.id,
              ...doc.data(),
            });
          })
          .toList();

      // Sort by date descending
      puzzles.sort((a, b) => b.date.compareTo(a.date));

      return puzzles;
    } catch (e) {
      throw Exception('Failed to fetch archive puzzles: $e');
    }
  }
}
