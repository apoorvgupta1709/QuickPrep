import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/question_model.dart';
import '../models/category_model.dart';
import '../core/constants.dart';

class PdfExportService {
  static Future<Uint8List> generateCheatSheetPdf({
    required Category category,
    required List<Question> questions,
  }) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#4F46E5'); // Indigo
    final slateDark = PdfColor.fromHex('#1E293B');
    final slateLight = PdfColor.fromHex('#F1F5F9');
    final textMuted = PdfColor.fromHex('#64748B');

    // Take top 6 questions for a clean 1-page high-density summary
    final cheatList = questions.take(6).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '⚡ QuickPrep 1-Page Cheat Sheet',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Category: ${category.name} • Last-Minute Interview Prep',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'HIGH YIELD',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // Questions Grid / High-Density List
              ...cheatList.map((q) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: slateLight,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Question Row
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: pw.BoxDecoration(
                              color: primaryColor,
                              borderRadius: pw.BorderRadius.circular(3),
                            ),
                            child: pw.Text(
                              q.difficulty.toUpperCase(),
                              style: const pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 7,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Expanded(
                            child: pw.Text(
                              q.question,
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                fontWeight: pw.FontWeight.bold,
                                color: slateDark,
                              ),
                            ),
                          ),
                          pw.Text(
                            q.companyTags.take(2).join(', '),
                            style: pw.TextStyle(
                              fontSize: 7.5,
                              color: textMuted,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),

                      // Core takeaway answer
                      pw.Text(
                        q.answer,
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          color: slateDark,
                        ),
                        maxLines: 3,
                      ),

                      if (q.codeSnippet != null && q.codeSnippet!.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(4),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(4),
                            border: pw.Border.all(color: PdfColors.grey200),
                          ),
                          child: pw.Text(
                            q.codeSnippet!.split('\n').take(3).join('\n'),
                            style: const pw.TextStyle(
                              fontSize: 7,
                              color: PdfColors.blueGrey800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              pw.Spacer(),

              // Footer with mandatory branding
              pw.Divider(color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'QuickPrep Interview Suite',
                    style: pw.TextStyle(fontSize: 8, color: textMuted),
                  ),
                  pw.Text(
                    'QuickPrep Interview Revision Sheet',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printOrShareCheatSheet({
    required Category category,
    required List<Question> questions,
  }) async {
    final pdfBytes = await generateCheatSheetPdf(
      category: category,
      questions: questions,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'QuickPrep_${category.name.replaceAll(" ", "_")}_CheatSheet.pdf',
    );
  }
}
