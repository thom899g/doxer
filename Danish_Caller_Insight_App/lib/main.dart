import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_theme.dart';
import 'core/router.dart';
import 'core/providers.dart';
import 'features/call_detection/services/call_detection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Activate Firebase App Check for security
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
  
  // Initialize analytics
  final analytics = FirebaseAnalytics.instance;
  await analytics.logAppOpen();
  
  // Initialize call detection service
  final callDetectionService = CallDetectionService();
  await callDetectionService.initialize();
  
  runApp(
    ProviderScope(
      child: DanishCallerInsightApp(
        analytics: analytics,
        callDetectionService: callDetectionService,
      ),
    ),
  );
}

class DanishCallerInsightApp extends ConsumerWidget {
  final FirebaseAnalytics analytics;
  final CallDetectionService callDetectionService;
  
  const DanishCallerInsightApp({
    required this.analytics,
    required this.callDetectionService,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Danish Caller Insight',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      
      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('da', ''),
      ],
      
      // Analytics observer
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}