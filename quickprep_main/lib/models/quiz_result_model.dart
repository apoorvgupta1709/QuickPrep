class QuizQuestionReview {
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? codeSnippet;
  final String? explanation;

  QuizQuestionReview({
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.codeSnippet,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        'isCorrect': isCorrect,
        'codeSnippet': codeSnippet,
        'explanation': explanation,
      };
}

class QuizResult {
  final String quizTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTakenSeconds;
  final int xpEarned;
  final DateTime completedAt;
  final List<QuizQuestionReview> reviews;

  QuizResult({
    required this.quizTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTakenSeconds,
    required this.xpEarned,
    required this.completedAt,
    required this.reviews,
  });

  double get accuracyPercentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
}
