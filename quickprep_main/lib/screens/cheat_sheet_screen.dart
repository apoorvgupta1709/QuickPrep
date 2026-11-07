import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/question_provider.dart';
import '../providers/user_gamification_provider.dart';
import '../providers/monetization_provider.dart';
import '../services/pdf_export_service.dart';
import '../services/admob_service.dart';
import '../services/razorpay_service.dart';
import '../widgets/branding_footer.dart';
import '../widgets/admob_banner_widget.dart';
import '../core/theme.dart';

class CheatSheetScreen extends StatefulWidget {
  const CheatSheetScreen({super.key});

  @override
  State<CheatSheetScreen> createState() => _CheatSheetScreenState();
}

class _CheatSheetScreenState extends State<CheatSheetScreen> {
  Category? _selectedCategory;
  bool _isExporting = false;

  void _downloadPdf(List questions) async {
    if (_selectedCategory == null) return;
    setState(() => _isExporting = true);
    try {
      await PdfExportService.printOrShareCheatSheet(
        category: _selectedCategory!,
        questions: questions.cast(),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showFreeUserPdfUnlockDialog(
    UserGamificationProvider gamification,
    MonetizationProvider monetization,
    List questions,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Export Cheat Sheet'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PDF revision cheat sheets can be unlocked in two ways:',
              style: TextStyle(fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.video_library, color: Colors.amber),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Watch 1 short sponsored ad to export this PDF for free.',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: AppTheme.primaryLight),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Or upgrade to Pro (₹${monetization.proPriceInr} Lifetime) for 100% ad-free instant downloads.',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              AdMobService.showRewardedAd(
                isPro: gamification.isPro,
                config: monetization.config,
                onUserEarnedReward: (reward) {
                  _downloadPdf(questions);
                },
                onFailedOrUnavailable: () {
                  _downloadPdf(questions);
                },
              );
            },
            child: const Text('Watch Ad to Export'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              RazorpayService(context, gamification).openCheckout(
                amountInr: monetization.proPriceInr,
                razorpayKeyId: monetization.config.razorpayKeyId,
              );
            },
            child: Text('Get Pro (₹${monetization.proPriceInr})'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final gamification = Provider.of<UserGamificationProvider>(context);
    final monetization = Provider.of<MonetizationProvider>(context);
    final categories = questionProvider.categories;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }

    final categoryQuestions = _selectedCategory != null
        ? questionProvider.getQuestionsByCategory(_selectedCategory!.id)
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('1-Page Revision Cheat Sheets 📄'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Selector Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: categories.map((Category cat) {
                  final isSelected = _selectedCategory?.id == cat.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Download Action Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCategory?.name ?? 'Category',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${categoryQuestions.length} High-Yield Questions',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _isExporting
                        ? null
                        : () {
                            if (_selectedCategory == null) return;
                            if (gamification.isPro) {
                              _downloadPdf(categoryQuestions);
                            } else {
                              _showFreeUserPdfUnlockDialog(
                                gamification,
                                monetization,
                                categoryQuestions,
                              );
                            }
                          },
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download, size: 18),
                    label: Text(gamification.isPro ? 'Export PDF' : 'Unlock PDF'),
                  ),
                ],
              ),
            ),

            const Divider(),

            // High Yield Questions Preview List
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: categoryQuestions.length,
                itemBuilder: (context, index) {
                  final q = categoryQuestions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppTheme.primary.withAlpha(35),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryLight,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  q.question,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            q.answer,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const AdMobBannerWidget(),
            const BrandingFooter(isSubtle: true),
          ],
        ),
      ),
    );
  }
}
