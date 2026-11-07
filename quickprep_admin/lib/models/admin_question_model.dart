class AdminQuestion {
  final String id;
  String categoryId;
  String categoryName;
  String question;
  String answer;
  String? codeSnippet;
  String? language;
  List<String> companyTags;
  String difficulty;
  String deepDiveExplanation;
  List<String> quizOptions;
  int correctOptionIndex;

  AdminQuestion({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.question,
    required this.answer,
    this.codeSnippet,
    this.language,
    required this.companyTags,
    this.difficulty = 'Medium',
    this.deepDiveExplanation = '',
    required this.quizOptions,
    required this.correctOptionIndex,
  });

  factory AdminQuestion.fromJson(Map<String, dynamic> json) {
    return AdminQuestion(
      id: json['id'] as String,
      categoryId: json['category_id'] as String? ?? 'general',
      categoryName: json['category_name'] as String? ?? 'General',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      codeSnippet: json['code_snippet'] as String?,
      language: json['language'] as String?,
      companyTags: (json['company_tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['FAANG', 'MNC'],
      difficulty: json['difficulty'] as String? ?? 'Medium',
      deepDiveExplanation: json['deep_dive_explanation'] as String? ?? '',
      quizOptions: (json['quiz_options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctOptionIndex: json['correct_option_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'question': question,
      'answer': answer,
      'code_snippet': codeSnippet,
      'language': language,
      'company_tags': companyTags,
      'difficulty': difficulty,
      'deep_dive_explanation': deepDiveExplanation,
      'quiz_options': quizOptions,
      'correct_option_index': correctOptionIndex,
    };
  }
}
