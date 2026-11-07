import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/admin_question_model.dart';
import '../providers/admin_cms_provider.dart';
import '../core/theme.dart';

class QuestionCmsScreen extends StatelessWidget {
  const QuestionCmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cms = Provider.of<AdminCmsProvider>(context);
    final questions = cms.filteredQuestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question CMS & Catalog'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${cms.allQuestions.length} Total Questions',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AdminTheme.primary,
        onPressed: () => _openQuestionEditor(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Question', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search & Filter Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => cms.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search questions, code, answers...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: AdminTheme.darkSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Questions List
              Expanded(
                child: questions.isEmpty
                    ? const Center(
                        child: Text('No questions found. Click "+ Add Question" or use Bulk Importer.'),
                      )
                    : ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, idx) {
                          final q = questions[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AdminTheme.primary.withAlpha(40),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          q.categoryName,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AdminTheme.primaryLight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withAlpha(40),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          q.difficulty,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined,
                                            size: 18),
                                        onPressed: () =>
                                            _openQuestionEditor(context, question: q),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18, color: AdminTheme.error),
                                        onPressed: () => cms.deleteQuestion(q.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    q.question,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    q.answer,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AdminTheme.darkTextSecondary,
                                    ),
                                  ),
                                  if (q.codeSnippet != null &&
                                      q.codeSnippet!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AdminTheme.darkBackground,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        q.codeSnippet!.split('\n').first,
                                        style: const TextStyle(
                                          fontFamily: 'Courier',
                                          fontSize: 11,
                                          color: Colors.tealAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openQuestionEditor(BuildContext context, {AdminQuestion? question}) {
    showDialog(
      context: context,
      builder: (ctx) => _QuestionEditorDialog(question: question),
    );
  }
}

class _QuestionEditorDialog extends StatefulWidget {
  final AdminQuestion? question;

  const _QuestionEditorDialog({this.question});

  @override
  State<_QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends State<_QuestionEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _qCtrl;
  late TextEditingController _aCtrl;
  late TextEditingController _codeCtrl;
  late TextEditingController _deepDiveCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _tagsCtrl;

  late TextEditingController _optACtrl;
  late TextEditingController _optBCtrl;
  late TextEditingController _optCCtrl;
  late TextEditingController _optDCtrl;

  String _difficulty = 'Medium';
  int _correctIdx = 0;

  @override
  void initState() {
    super.initState();
    final q = widget.question;
    _qCtrl = TextEditingController(text: q?.question ?? '');
    _aCtrl = TextEditingController(text: q?.answer ?? '');
    _codeCtrl = TextEditingController(text: q?.codeSnippet ?? '');
    _deepDiveCtrl = TextEditingController(text: q?.deepDiveExplanation ?? '');
    _categoryCtrl = TextEditingController(text: q?.categoryName ?? 'Data Structures & Algo');
    _tagsCtrl = TextEditingController(text: q?.companyTags.join(', ') ?? 'FAANG, MNC');

    final opts = q?.quizOptions ?? [];
    _optACtrl = TextEditingController(text: opts.isNotEmpty ? opts[0] : '');
    _optBCtrl = TextEditingController(text: opts.length > 1 ? opts[1] : '');
    _optCCtrl = TextEditingController(text: opts.length > 2 ? opts[2] : '');
    _optDCtrl = TextEditingController(text: opts.length > 3 ? opts[3] : '');

    _difficulty = q?.difficulty ?? 'Medium';
    _correctIdx = q?.correctOptionIndex ?? 0;
  }

  @override
  void dispose() {
    _qCtrl.dispose();
    _aCtrl.dispose();
    _codeCtrl.dispose();
    _deepDiveCtrl.dispose();
    _categoryCtrl.dispose();
    _tagsCtrl.dispose();
    _optACtrl.dispose();
    _optBCtrl.dispose();
    _optCCtrl.dispose();
    _optDCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final cms = Provider.of<AdminCmsProvider>(context, listen: false);
    final tags = _tagsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final options = [
      _optACtrl.text.trim(),
      _optBCtrl.text.trim(),
      _optCCtrl.text.trim(),
      _optDCtrl.text.trim(),
    ].where((e) => e.isNotEmpty).toList();

    final id = widget.question?.id ??
        'q_${const Uuid().v4().substring(0, 8)}';

    final updated = AdminQuestion(
      id: id,
      categoryId: _categoryCtrl.text.toLowerCase().replaceAll(' ', '_'),
      categoryName: _categoryCtrl.text.trim(),
      question: _qCtrl.text.trim(),
      answer: _aCtrl.text.trim(),
      codeSnippet: _codeCtrl.text.trim().isNotEmpty ? _codeCtrl.text.trim() : null,
      language: 'dart',
      companyTags: tags.isNotEmpty ? tags : ['FAANG'],
      difficulty: _difficulty,
      deepDiveExplanation: _deepDiveCtrl.text.trim(),
      quizOptions: options,
      correctOptionIndex: _correctIdx,
    );

    cms.saveQuestion(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.question == null ? 'Create New Question' : 'Edit Question',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Category & Difficulty
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _categoryCtrl,
                        decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _difficulty,
                      items: ['Easy', 'Medium', 'Hard'].map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _difficulty = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Question
                TextFormField(
                  controller: _qCtrl,
                  decoration: const InputDecoration(labelText: 'Question Text', border: OutlineInputBorder()),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'Question required' : null,
                ),
                const SizedBox(height: 12),

                // Answer
                TextFormField(
                  controller: _aCtrl,
                  decoration: const InputDecoration(labelText: 'Concise Answer', border: OutlineInputBorder()),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Answer required' : null,
                ),
                const SizedBox(height: 12),

                // Code Snippet
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Code Snippet (optional)',
                    border: OutlineInputBorder(),
                    hintText: '// Code example...',
                  ),
                  maxLines: 3,
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
                ),
                const SizedBox(height: 12),

                // Tags
                TextFormField(
                  controller: _tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Company Tags (comma separated)',
                    border: OutlineInputBorder(),
                    hintText: 'FAANG, MNC, FinTech, Startup',
                  ),
                ),
                const SizedBox(height: 12),

                // Deep dive
                TextFormField(
                  controller: _deepDiveCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Interviewer Deep Dive Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Multiple Choice Options
                const Text('Mock Quiz Options (A, B, C, D)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(controller: _optACtrl, decoration: const InputDecoration(labelText: 'Option A', border: OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 6),
                TextField(controller: _optBCtrl, decoration: const InputDecoration(labelText: 'Option B', border: OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 6),
                TextField(controller: _optCCtrl, decoration: const InputDecoration(labelText: 'Option C', border: OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 6),
                TextField(controller: _optDCtrl, decoration: const InputDecoration(labelText: 'Option D', border: OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Text('Correct Option Index (0=A, 1=B, 2=C, 3=D): '),
                    DropdownButton<int>(
                      value: _correctIdx,
                      items: [0, 1, 2, 3].map((i) {
                        return DropdownMenuItem(value: i, child: Text(String.fromCharCode(65 + i)));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _correctIdx = v);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Question'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
