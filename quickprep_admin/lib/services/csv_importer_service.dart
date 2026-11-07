import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../models/admin_question_model.dart';
import '../core/constants.dart';

class CsvImportResult {
  final List<AdminQuestion> importedQuestions;
  final List<String> errors;

  CsvImportResult({
    required this.importedQuestions,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
}

class CsvImporterService {
  static const _uuid = Uuid();

  static CsvImportResult parseCsv(String csvContent) {
    final List<AdminQuestion> questions = [];
    final List<String> errors = [];

    try {
      final rows = csv.decode(csvContent);

      if (rows.isEmpty) {
        errors.add('CSV document is empty.');
        return CsvImportResult(importedQuestions: [], errors: errors);
      }

      // Check header
      final headerRow = rows.first.map((e) => e.toString().trim()).toList();
      final hasCategoryCol = headerRow.contains('category_id');
      final startIndex = hasCategoryCol ? 1 : 0;

      for (int i = startIndex; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
          continue;
        }

        try {
          if (row.length < 4) {
            errors.add('Row ${i + 1}: Insufficient columns. Minimum required: category, question, answer.');
            continue;
          }

          final catId = row[0].toString().trim();
          final catName = row.length > 1 ? row[1].toString().trim() : 'General';
          final qText = row.length > 2 ? row[2].toString().trim() : '';
          final aText = row.length > 3 ? row[3].toString().trim() : '';
          final code = row.length > 4 ? row[4].toString().trim() : null;
          final lang = row.length > 5 ? row[5].toString().trim() : null;
          final tags = row.length > 6
              ? row[6].toString().split('|').map((e) => e.trim()).toList()
              : ['FAANG', 'MNC'];
          final diff = row.length > 7 ? row[7].toString().trim() : 'Medium';
          final deepDive = row.length > 8 ? row[8].toString().trim() : '';

          final optA = row.length > 9 ? row[9].toString().trim() : '';
          final optB = row.length > 10 ? row[10].toString().trim() : '';
          final optC = row.length > 11 ? row[11].toString().trim() : '';
          final optD = row.length > 12 ? row[12].toString().trim() : '';

          final List<String> options = [];
          if (optA.isNotEmpty) options.add(optA);
          if (optB.isNotEmpty) options.add(optB);
          if (optC.isNotEmpty) options.add(optC);
          if (optD.isNotEmpty) options.add(optD);

          int correctIdx = 0;
          if (row.length > 13) {
            correctIdx = int.tryParse(row[13].toString().trim()) ?? 0;
          }

          if (qText.isEmpty || aText.isEmpty) {
            errors.add('Row ${i + 1}: Question or answer is empty.');
            continue;
          }

          questions.add(
            AdminQuestion(
              id: 'q_${_uuid.v4().substring(0, 8)}',
              categoryId: catId.isNotEmpty ? catId : 'general',
              categoryName: catName.isNotEmpty ? catName : 'General',
              question: qText,
              answer: aText,
              codeSnippet: (code != null && code.isNotEmpty) ? code : null,
              language: (lang != null && lang.isNotEmpty) ? lang : 'dart',
              companyTags: tags,
              difficulty: diff.isNotEmpty ? diff : 'Medium',
              deepDiveExplanation: deepDive,
              quizOptions: options,
              correctOptionIndex: correctIdx,
            ),
          );
        } catch (e) {
          errors.add('Row ${i + 1} parse error: $e');
        }
      }
    } catch (e) {
      errors.add('Failed to parse CSV: $e');
    }

    return CsvImportResult(importedQuestions: questions, errors: errors);
  }

  static CsvImportResult parseJson(String jsonContent) {
    final List<AdminQuestion> questions = [];
    final List<String> errors = [];

    try {
      final decoded = jsonDecode(jsonContent);
      if (decoded is List) {
        for (var item in decoded) {
          if (item is Map<String, dynamic>) {
            final id = item['id'] ?? 'q_${_uuid.v4().substring(0, 8)}';
            item['id'] = id;
            questions.add(AdminQuestion.fromJson(item));
          }
        }
      } else {
        errors.add('JSON root must be an array of questions.');
      }
    } catch (e) {
      errors.add('Invalid JSON syntax: $e');
    }

    return CsvImportResult(importedQuestions: questions, errors: errors);
  }

  static String generateSampleCsv() {
    return '''${AdminConstants.csvHeader}
dsa,Data Structures & Algo,"What is an Inverted Index?","An index data structure storing a mapping from words to their locations in a document collection. Used by Elasticsearch.","// Inverted index map\\nMap<String, Set<int>> index = {};",dart,FAANG|FinTech,Medium,"Enables full text search in O(1) term lookup.",Hash Table,Inverted Index,Binary Tree,Bloom Filter,1
system_design,System Design,"Explain Cache Invalidation Strategies.","Purge (direct deletion), Refresh (cache reload), and TTL (expiration timestamp).","redis.expire('user:101', 3600);",dart,FAANG|Startup,Hard,"Cache invalidation is notoriously one of the hardest problems in distributed systems.",TTL and Purge,Only Write-Through,Rebooting Redis,None,0''';
  }
}
