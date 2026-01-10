import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a word ladder puzzle
class Puzzle {
  /// 0-based puzzle index used for date mapping
  final int index;

  /// Complete word ladder from start to end
  final List<String> ladder;

  /// Length of each word in the puzzle
  final int wordLength;

  /// Total number of words in the ladder
  final int stepCount;

  /// When the puzzle was uploaded to Firestore
  final DateTime? createdAt;

  const Puzzle({
    required this.index,
    required this.ladder,
    required this.wordLength,
    required this.stepCount,
    this.createdAt,
  });

  /// First word (given to player)
  String get startWord => ladder.first;

  /// Last word (given to player)
  String get endWord => ladder.last;

  /// All intermediate words (the solution)
  List<String> get solutionMiddle => ladder.sublist(1, ladder.length - 1);

  /// Number of words the player must enter
  int get inputCount => stepCount - 2;

  /// Create from Firestore document
  factory Puzzle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ladder = List<String>.from(data['ladder'] as List);

    return Puzzle(
      index: data['index'] as int,
      ladder: ladder,
      wordLength: data['wordLength'] as int? ?? ladder.first.length,
      stepCount: data['stepCount'] as int? ?? ladder.length,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Create from JSON (for local caching)
  factory Puzzle.fromJson(Map<String, dynamic> json) {
    final ladder = List<String>.from(json['ladder'] as List);

    return Puzzle(
      index: json['index'] as int,
      ladder: ladder,
      wordLength: json['wordLength'] as int? ?? ladder.first.length,
      stepCount: json['stepCount'] as int? ?? ladder.length,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Convert to JSON for local caching
  Map<String, dynamic> toJson() => {
        'index': index,
        'ladder': ladder,
        'wordLength': wordLength,
        'stepCount': stepCount,
        'createdAt': createdAt?.toIso8601String(),
      };

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() => {
        'index': index,
        'ladder': ladder,
        'wordLength': wordLength,
        'stepCount': stepCount,
        'createdAt':
            createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      };

  @override
  String toString() => 'Puzzle($index: $startWord → $endWord)';
}
