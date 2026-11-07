import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_flagged_provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import 'question_cms_screen.dart';
import 'bulk_importer_screen.dart';
import 'flagged_reviewer_screen.dart';
import 'monetization_hub_screen.dart';
import 'razorpay_manager_screen.dart';
import 'broadcast_manager_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    QuestionCmsScreen(),
    BulkImporterScreen(),
    FlaggedReviewerScreen(),
    MonetizationHubScreen(),
    RazorpayManagerScreen(),
    BroadcastManagerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final flaggedProvider = Provider.of<AdminFlaggedProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AdminTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dashboard_customize,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              AdminConstants.appName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 14),
            // Header Branding Attribution
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                AdminConstants.authorAttribution,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // NavigationRail for Web & Desktop
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.library_books_outlined),
                  selectedIcon: Icon(Icons.library_books),
                  label: Text('Questions'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.file_upload_outlined),
                  selectedIcon: Icon(Icons.file_upload),
                  label: Text('Bulk Import'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    label: Text('${flaggedProvider.pendingCount}'),
                    isLabelVisible: flaggedProvider.pendingCount > 0,
                    child: const Icon(Icons.flag_outlined),
                  ),
                  selectedIcon: Badge(
                    label: Text('${flaggedProvider.pendingCount}'),
                    isLabelVisible: flaggedProvider.pendingCount > 0,
                    child: const Icon(Icons.flag),
                  ),
                  label: const Text('Flagged'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.ads_click_outlined),
                  selectedIcon: Icon(Icons.ads_click),
                  label: Text('Monetization'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.payment_outlined),
                  selectedIcon: Icon(Icons.payment),
                  label: Text('Razorpay'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.campaign_outlined),
                  selectedIcon: Icon(Icons.campaign),
                  label: Text('Broadcasts'),
                ),
              ],
            ),
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),

          // Main View Content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (idx) => setState(() => _selectedIndex = idx),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AdminTheme.darkSurface,
              selectedItemColor: AdminTheme.primaryLight,
              unselectedItemColor: AdminTheme.darkTextSecondary,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.library_books),
                  label: 'CMS',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.file_upload),
                  label: 'Import',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('${flaggedProvider.pendingCount}'),
                    isLabelVisible: flaggedProvider.pendingCount > 0,
                    child: const Icon(Icons.flag),
                  ),
                  label: 'Flagged',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.ads_click),
                  label: 'Ads',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.payment),
                  label: 'Pricing',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.campaign),
                  label: 'Broadcasts',
                ),
              ],
            ),
    );
  }
}
