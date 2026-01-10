class CryptixUserStats {
  final int currentStreak;
  final int bestStreak;
  final int totalSolved;
  final int totalScore;
  final DateTime? lastPlayedDate;

  const CryptixUserStats({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalSolved = 0,
    this.totalScore = 0,
    this.lastPlayedDate,
  });

  double get averageScore => totalSolved > 0 ? totalScore / totalSolved : 0;

  CryptixUserStats copyWith({
    int? currentStreak,
    int? bestStreak,
    int? totalSolved,
    int? totalScore,
    DateTime? lastPlayedDate,
  }) {
    return CryptixUserStats(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalSolved: totalSolved ?? this.totalSolved,
      totalScore: totalScore ?? this.totalScore,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalSolved': totalSolved,
      'totalScore': totalScore,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
    };
  }

  factory CryptixUserStats.fromJson(Map<String, dynamic> json) {
    return CryptixUserStats(
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalSolved: json['totalSolved'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'] as String)
          : null,
    );
  }
}
