import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puzzle.dart';

class CryptixFirestoreService {
  final FirebaseFirestore _firestore;
  static const String _puzzlesCollection = 'puzzles';

  CryptixFirestoreService(this._firestore);

  CollectionReference<Map<String, dynamic>> get _puzzlesRef =>
      _firestore.collection(_puzzlesCollection);

  Future<void> enableOfflinePersistence() async {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Future<CryptixPuzzle?> getPuzzleByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _puzzlesRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CryptixPuzzle.fromFirestore(snapshot.docs.first);
  }

  Future<CryptixPuzzle?> getTodaysPuzzle() async {
    return getPuzzleByDate(DateTime.now());
  }

  Future<List<CryptixPuzzle>> getAllPuzzles() async {
    final snapshot = await _puzzlesRef
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => CryptixPuzzle.fromFirestore(doc)).toList();
  }

  Future<List<CryptixPuzzle>> getPastPuzzles() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final snapshot = await _puzzlesRef
        .where('date', isLessThan: Timestamp.fromDate(startOfToday))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => CryptixPuzzle.fromFirestore(doc)).toList();
  }

  Future<CryptixPuzzle?> getPuzzleByUid(int uid) async {
    final snapshot = await _puzzlesRef
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CryptixPuzzle.fromFirestore(snapshot.docs.first);
  }

  Stream<CryptixPuzzle?> watchTodaysPuzzle() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _puzzlesRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return CryptixPuzzle.fromFirestore(snapshot.docs.first);
    });
  }
}
