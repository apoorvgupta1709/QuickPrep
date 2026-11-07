import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'core/error_boundary.dart';
import 'providers/question_provider.dart';
import 'providers/user_gamification_provider.dart';
import 'providers/leitner_provider.dart';
import 'providers/audio_commute_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Production-Ready Checklist Item 8: Custom error boundary (Zero red screens)
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return CustomErrorWidget(errorDetails: errorDetails);
  };

  runApp(const QuickPrepApp());
}

class QuickPrepApp extends StatelessWidget {
  const QuickPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => UserGamificationProvider()),
        ChangeNotifierProvider(create: (_) => LeitnerProvider()),
        ChangeNotifierProvider(create: (_) => AudioCommuteProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
