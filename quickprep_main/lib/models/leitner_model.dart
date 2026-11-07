class LeitnerCard {
  final String questionId;
  int boxNumber; // 1 to 5
  DateTime nextReviewDate;
  DateTime lastReviewedAt;
  int reviewCount;
  int correctStreak;

  LeitnerCard({
    required this.questionId,
    this.boxNumber = 1,
    required this.nextReviewDate,
    required this.lastReviewedAt,
    this.reviewCount = 0,
    this.correctStreak = 0,
  });

  bool get isDue => DateTime.now().isAfter(nextReviewDate);

  static int getIntervalDays(int box) {
    switch (box) {
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 4;
      case 4:
        return 7;
      case 5:
        return 14;
      default:
        return 1;
    }
  }

  void markCorrect() {
    reviewCount++;
    correctStreak++;
    if (boxNumber < 5) {
      boxNumber++;
    }
    final days = getIntervalDays(boxNumber);
    lastReviewedAt = DateTime.now();
    nextReviewDate = DateTime.now().add(Duration(days: days));
  }

  void markIncorrect() {
    reviewCount++;
    correctStreak = 0;
    boxNumber = 1; // Reset to Box 1 on error
    lastReviewedAt = DateTime.now();
    nextReviewDate = DateTime.now().add(const Duration(days: 1));
  }

  factory LeitnerCard.fromJson(Map<String, dynamic> json) {
    return LeitnerCard(
      questionId: json['question_id'] as String,
      boxNumber: json['box_number'] as int? ?? 1,
      nextReviewDate: DateTime.parse(json['next_review_date'] as String),
      lastReviewedAt: DateTime.parse(json['last_reviewed_at'] as String),
      reviewCount: json['review_count'] as int? ?? 0,
      correctStreak: json['correct_streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'box_number': boxNumber,
      'next_review_date': nextReviewDate.toIso8601String(),
      'last_reviewed_at': lastReviewedAt.toIso8601String(),
      'review_count': reviewCount,
      'correct_streak': correctStreak,
    };
  }
}
