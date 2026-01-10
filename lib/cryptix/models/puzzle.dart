import 'package:cloud_firestore/cloud_firestore.dart';

class CryptixPuzzle {
  final int uid;
  final DateTime date;
  final String clue;
  final String answer;
  final int length;
  final String definitionSegment;

  CryptixPuzzle({
    required this.uid,
    required this.date,
    required this.clue,
    required this.answer,
    required this.length,
    required this.definitionSegment,
  });

  factory CryptixPuzzle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CryptixPuzzle(
      uid: data['uid'] as int,
      date: (data['date'] as Timestamp).toDate(),
      clue: data['clue'] as String,
      answer: (data['answer'] as String).toUpperCase(),
      length: data['length'] as int,
      definitionSegment: data['definitionSegment'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'date': Timestamp.fromDate(date),
      'clue': clue,
      'answer': answer.toUpperCase(),
      'length': length,
      'definitionSegment': definitionSegment,
    };
  }

  bool get isDoubleDefinition => definitionSegment.contains('/');

  List<String> get definitions => definitionSegment.split('/');

  bool matchesDefinitionInClue() {
    if (isDoubleDefinition) return false;
    return clue.toLowerCase().contains(definitionSegment.toLowerCase());
  }

  @override
  String toString() => 'CryptixPuzzle(uid: $uid, date: $date, clue: $clue)';
}
