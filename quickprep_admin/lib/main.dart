import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'providers/admin_cms_provider.dart';
import 'providers/admin_monetization_provider.dart';
import 'providers/admin_flagged_provider.dart';
import 'providers/admin_broadcast_provider.dart';
import 'screens/admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuickPrepAdminApp());
}

class QuickPrepAdminApp extends StatelessWidget {
  const QuickPrepAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminCmsProvider()),
        ChangeNotifierProvider(create: (_) => AdminMonetizationProvider()),
        ChangeNotifierProvider(create: (_) => AdminFlaggedProvider()),
        ChangeNotifierProvider(create: (_) => AdminBroadcastProvider()),
      ],
      child: MaterialApp(
        title: AdminConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AdminTheme.darkTheme,
        home: const AdminDashboardScreen(),
      ),
    );
  }
}
