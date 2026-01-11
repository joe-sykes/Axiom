/// Represents a single trivia question in Triverse.
class TriverseQuestion {
  final String id;
  final String text;
  final String category;
  final List<String> answers;
  final int correctIndex;

  const TriverseQuestion({
    required this.id,
    required this.text,
    required this.category,
    required this.answers,
    required this.correctIndex,
  });

  factory TriverseQuestion.fromMap(Map<String, dynamic> map) {
    return TriverseQuestion(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      category: map['category'] as String? ?? '',
      answers: (map['answers'] as List<dynamic>?)
              ?.map((a) => a.toString())
              .toList() ??
          [],
      correctIndex: map['correctIndex'] as int? ?? 0,
    );
  }

  String get correctAnswer => answers[correctIndex];

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}
