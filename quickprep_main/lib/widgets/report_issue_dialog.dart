import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/feedback_service.dart';
import '../core/theme.dart';

class ReportIssueDialog extends StatefulWidget {
  final Question question;

  const ReportIssueDialog({super.key, required this.question});

  @override
  State<ReportIssueDialog> createState() => _ReportIssueDialogState();
}

class _ReportIssueDialogState extends State<ReportIssueDialog> {
  String _selectedIssue = 'Typo in Question';
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _issueOptions = [
    'Typo in Question',
    'Incorrect Answer',
    'Syntax Error in Code',
    'Explanation Needs Clarification',
    'Other Issue',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _isSubmitting = true);
    final success = await FeedbackService.submitReport(
      questionId: widget.question.id,
      questionTitle: widget.question.question,
      issueType: _selectedIssue,
      userComment: _commentController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Thank you! Your feedback was sent to the QuickPrep team.'
                : 'Failed to record report. Please try again.',
          ),
          backgroundColor: success ? AppTheme.success : AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.flag_outlined, color: AppTheme.error),
          SizedBox(width: 8),
          Text('Report Typo or Issue', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question: "${widget.question.question}"',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            const Text(
              'What issue did you encounter?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            ..._issueOptions.map((opt) {
              return RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(opt, style: const TextStyle(fontSize: 13)),
                value: opt,
                groupValue: _selectedIssue,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedIssue = val);
                },
              );
            }),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Additional Details (optional)',
                hintText: 'e.g. Correct code snippet should be...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit Report'),
        ),
      ],
    );
  }
}
