class FlaggedReport {
  final String id;
  final String questionId;
  final String questionTitle;
  final String issueType;
  final String userComment;
  final DateTime createdAt;
  String status; // 'pending', 'resolved'

  FlaggedReport({
    required this.id,
    required this.questionId,
    required this.questionTitle,
    required this.issueType,
    required this.userComment,
    required this.createdAt,
    this.status = 'pending',
  });

  factory FlaggedReport.fromJson(Map<String, dynamic> json) {
    return FlaggedReport(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      questionTitle: json['question_title'] as String? ?? '',
      issueType: json['issue_type'] as String? ?? 'Typo',
      userComment: json['user_comment'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'question_title': questionTitle,
      'issue_type': issueType,
      'user_comment': userComment,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
