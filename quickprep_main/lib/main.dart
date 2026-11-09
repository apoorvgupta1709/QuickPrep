import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'core/error_boundary.dart';
import 'providers/question_provider.dart';
import 'providers/user_gamification_provider.dart';
import 'providers/leitner_provider.dart';
import 'providers/audio_commute_provider.dart';
import 'providers/monetization_provider.dart';
import 'services/admob_service.dart';
import 'screens/splash_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Production error logging: intercept all Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('QuickPrep Framework Error: ${details.exceptionAsString()}');
    };

    // Intercept platform and asynchronous unhandled errors
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('QuickPrep Platform Error: $error\n$stack');
      return true; // handled, prevent process crash
    };

    // Custom graceful fallback UI for any widget failure
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return CustomErrorWidget(errorDetails: errorDetails);
    };

    // Render app UI immediately
    runApp(const QuickPrepApp());

    // Safely initialize AdMob asynchronously without blocking launch
    try {
      unawaited(AdMobService.initialize());
    } catch (e) {
      debugPrint('AdMob startup notice: $e');
    }
  }, (error, stack) {
    debugPrint('QuickPrep Zone Error: $error\n$stack');
  });
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
        ChangeNotifierProvider(create: (_) => MonetizationProvider()),
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
