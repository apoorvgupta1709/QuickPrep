import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_flagged_provider.dart';
import '../providers/admin_cms_provider.dart';
import '../models/flagged_report_model.dart';
import '../core/theme.dart';

class FlaggedReviewerScreen extends StatelessWidget {
  const FlaggedReviewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flaggedProvider = Provider.of<AdminFlaggedProvider>(context);
    final reports = flaggedProvider.reports;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flagged Question & Typo Reviewer'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: flaggedProvider.pendingCount > 0
                      ? AdminTheme.error.withAlpha(40)
                      : AdminTheme.success.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${flaggedProvider.pendingCount} Pending Reports',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: flaggedProvider.pendingCount > 0
                        ? AdminTheme.error
                        : AdminTheme.success,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: reports.isEmpty
            ? const Center(child: Text('No flagged questions reported.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (context, idx) {
                  final report = reports[idx];
                  final isPending = report.status == 'pending';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPending
                                      ? AdminTheme.error.withAlpha(30)
                                      : AdminTheme.success.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  report.issueType.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isPending
                                        ? AdminTheme.error
                                        : AdminTheme.success,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isPending ? 'Pending Review' : 'Resolved',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isPending
                                      ? Colors.amber
                                      : AdminTheme.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: Colors.grey),
                                onPressed: () =>
                                    flaggedProvider.deleteReport(report.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            report.questionTitle.isNotEmpty
                                ? report.questionTitle
                                : 'Question ID: ${report.questionId}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AdminTheme.darkBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'User feedback: "${report.userComment}"',
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  _findAndEditQuestion(context, report);
                                },
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit Question in CMS'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPending
                                      ? AdminTheme.success
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  if (isPending) {
                                    flaggedProvider.resolveReport(report.id);
                                  } else {
                                    flaggedProvider.reopenReport(report.id);
                                  }
                                },
                                icon: Icon(
                                  isPending ? Icons.check : Icons.refresh,
                                  size: 16,
                                ),
                                label: Text(isPending
                                    ? 'Mark Resolved'
                                    : 'Reopen Report'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _findAndEditQuestion(BuildContext context, FlaggedReport report) {
    final cms = Provider.of<AdminCmsProvider>(context, listen: false);
    final match = cms.allQuestions
        .where((q) =>
            q.id == report.questionId || q.question == report.questionTitle)
        .toList();

    if (match.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found question "${match.first.question}" in catalog.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question was not found in catalog or was already deleted.'),
        ),
      );
    }
  }
}
