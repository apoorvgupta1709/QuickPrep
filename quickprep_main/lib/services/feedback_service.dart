import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FlaggedQuestionReport {
  final String id;
  final String questionId;
  final String questionTitle;
  final String issueType; // 'Typo in Question', 'Incorrect Answer', 'Code Bug', 'Other'
  final String userComment;
  final DateTime createdAt;
  final String status; // 'pending', 'resolved'

  FlaggedQuestionReport({
    required this.id,
    required this.questionId,
    required this.questionTitle,
    required this.issueType,
    required this.userComment,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question_id': questionId,
        'question_title': questionTitle,
        'issue_type': issueType,
        'user_comment': userComment,
        'created_at': createdAt.toIso8601String(),
        'status': status,
      };

  factory FlaggedQuestionReport.fromJson(Map<String, dynamic> json) =>
      FlaggedQuestionReport(
        id: json['id'] as String,
        questionId: json['question_id'] as String,
        questionTitle: json['question_title'] as String? ?? '',
        issueType: json['issue_type'] as String,
        userComment: json['user_comment'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        status: json['status'] as String? ?? 'pending',
      );
}

class FeedbackService {
  static const String _storageKey = 'quickprep_flagged_reports';

  static Future<bool> submitReport({
    required String questionId,
    required String questionTitle,
    required String issueType,
    required String userComment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingReports = prefs.getStringList(_storageKey) ?? [];

      final report = FlaggedQuestionReport(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        questionId: questionId,
        questionTitle: questionTitle,
        issueType: issueType,
        userComment: userComment,
        createdAt: DateTime.now(),
      );

      existingReports.add(jsonEncode(report.toJson()));
      await prefs.setStringList(_storageKey, existingReports);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<FlaggedQuestionReport>> getSavedReports() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_storageKey) ?? [];
    return list
        .map((e) => FlaggedQuestionReport.fromJson(jsonDecode(e)))
        .toList();
  }
}
