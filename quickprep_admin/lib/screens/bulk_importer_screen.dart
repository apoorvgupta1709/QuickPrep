import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/csv_importer_service.dart';
import '../models/admin_question_model.dart';
import '../providers/admin_cms_provider.dart';
import '../core/theme.dart';

class BulkImporterScreen extends StatefulWidget {
  const BulkImporterScreen({super.key});

  @override
  State<BulkImporterScreen> createState() => _BulkImporterScreenState();
}

class _BulkImporterScreenState extends State<BulkImporterScreen> {
  final TextEditingController _textController = TextEditingController();
  List<AdminQuestion> _parsedQuestions = [];
  List<String> _parseErrors = [];
  bool _isCsv = true;

  @override
  void initState() {
    super.initState();
    _textController.text = CsvImporterService.generateSampleCsv();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _parseContent() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste CSV or JSON content first.')),
      );
      return;
    }

    final result = _isCsv
        ? CsvImporterService.parseCsv(text)
        : CsvImporterService.parseJson(text);

    setState(() {
      _parsedQuestions = result.importedQuestions;
      _parseErrors = result.errors;
    });

    if (result.importedQuestions.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully parsed ${result.importedQuestions.length} questions! Review below.'),
          backgroundColor: AdminTheme.success,
        ),
      );
    }
  }

  void _commitImport() async {
    if (_parsedQuestions.isEmpty) return;

    final cms = Provider.of<AdminCmsProvider>(context, listen: false);
    final count = await cms.bulkImportQuestions(_parsedQuestions);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Imported $count new questions into QuickPrep question bank!'),
          backgroundColor: AdminTheme.success,
        ),
      );
      setState(() {
        _parsedQuestions = [];
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk CSV / JSON Importer'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AdminTheme.primary,
                        child: Icon(Icons.file_upload, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bulk Import Question Banks',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Import 100s of flashcards, code snippets, and multiple choice questions in a single operation via CSV or JSON.',
                              style: TextStyle(fontSize: 12.5, color: AdminTheme.darkTextSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.darkSurfaceElevated,
                        ),
                        onPressed: () {
                          setState(() {
                            _textController.text = CsvImporterService.generateSampleCsv();
                            _isCsv = true;
                          });
                        },
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Load Sample CSV'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Format selector
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('CSV Format'),
                    selected: _isCsv,
                    onSelected: (val) {
                      if (val) setState(() => _isCsv = true);
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('JSON Format'),
                    selected: !_isCsv,
                    onSelected: (val) {
                      if (val) setState(() => _isCsv = false);
                    },
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _parseContent,
                    icon: const Icon(Icons.checklist, size: 18),
                    label: const Text('Validate & Parse'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Raw Text Input Box
              TextField(
                controller: _textController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: _isCsv
                      ? 'Paste CSV text with columns: category_id, category_name, question, answer, code_snippet, ...'
                      : 'Paste JSON array: [ {"category_id": "dsa", "question": "...", "answer": "..."} ]',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AdminTheme.darkSurface,
                ),
                style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
              ),

              if (_parseErrors.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminTheme.error.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AdminTheme.error),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Parsing Errors:',
                        style: TextStyle(color: AdminTheme.error, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ..._parseErrors.map((e) => Text('• $e', style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Parsed Questions Preview Table
              if (_parsedQuestions.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preview Parsed Questions (${_parsedQuestions.length} Ready)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.success),
                      onPressed: _commitImport,
                      icon: const Icon(Icons.cloud_upload, color: Colors.white),
                      label: Text(
                        'Commit Import (${_parsedQuestions.length} Questions)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ..._parsedQuestions.map((q) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(q.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        'Category: ${q.categoryName} • Tags: ${q.companyTags.join(", ")} • Diff: ${q.difficulty}',
                        style: TextStyle(fontSize: 12, color: AdminTheme.darkTextSecondary),
                      ),
                      trailing: const Icon(Icons.check_circle, color: AdminTheme.success, size: 20),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
