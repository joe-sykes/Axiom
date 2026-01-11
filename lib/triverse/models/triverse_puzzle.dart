import 'triverse_question.dart';

/// Represents a daily Triverse puzzle containing 7 questions.
class TriverseDaily {
  final String date;
  final List<String> categories;
  final List<TriverseQuestion> questions;

  const TriverseDaily({
    required this.date,
    required this.categories,
    required this.questions,
  });

  factory TriverseDaily.fromMap(Map<String, dynamic> map) {
    return TriverseDaily(
      date: map['date'] as String? ?? '',
      categories: (map['categories'] as List<dynamic>?)
              ?.map((c) => c.toString())
              .toList() ??
          [],
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => TriverseQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  int get questionCount => questions.length;

  String get categoriesDisplay => categories.join(' • ');
}
