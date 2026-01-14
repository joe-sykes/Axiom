import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/firebase/firebase_manager.dart';
import '../models/puzzle.dart';

class CryptogramFirestoreService {
  FirebaseFirestore get _firestore => FirebaseManager.cryptogramFirestore;

  /// Get a random puzzle by difficulty
  Future<CryptogramPuzzle?> getRandomPuzzle({String? difficultyLabel}) async {
    try {
      Query query = _firestore.collection('cryptogram_puzzles');

      if (difficultyLabel != null) {
        query = query.where('difficulty_label', isEqualTo: difficultyLabel);
      }

      // Get count first
      final countSnapshot = await query.count().get();
      final count = countSnapshot.count ?? 0;

      if (count == 0) return null;

      // Get a random document
      final randomIndex = DateTime.now().millisecondsSinceEpoch % count;

      final snapshot = await query.limit(1).get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return CryptogramPuzzle.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      print('Error fetching puzzle: $e');
      return null;
    }
  }

  /// Get today's puzzle by date
  Future<CryptogramPuzzle?> getDailyPuzzle() async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Document ID is the date
      final doc = await _firestore
          .collection('cryptogram_puzzles')
          .doc(dateStr)
          .get();

      if (!doc.exists) {
        print('No puzzle found for $dateStr');
        return null;
      }

      return CryptogramPuzzle.fromMap(
        doc.data()!,
        doc.id,
      );
    } catch (e) {
      print('Error fetching daily puzzle: $e');
      return null;
    }
  }

  /// Get puzzles for archive (past puzzles only)
  Future<List<CryptogramPuzzle>> getArchivePuzzles({int limit = 50}) async {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final snapshot = await _firestore
          .collection('cryptogram_puzzles')
          .where('date', isLessThan: todayStr)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CryptogramPuzzle.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching archive: $e');
      return [];
    }
  }
}
