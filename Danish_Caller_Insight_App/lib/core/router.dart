import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/privacy/screens/privacy_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/manual_lookup/screens/manual_lookup_screen.dart';
import '../features/privacy/services/privacy_service.dart';

/// App routes configuration
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String history = '/history';
  static const String manualLookup = '/manual-lookup';
  static const String notificationSettings = '/notification-settings';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      // Onboarding route
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Home route
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Settings route
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Privacy route
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyScreen(),
      ),
      
      // History route
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      
      // Manual lookup route
      GoRoute(
        path: AppRoutes.manualLookup,
        builder: (context, state) => const ManualLookupScreen(),
      ),
      
      // Notification settings route
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
    
    // Redirect logic for onboarding
    redirect: (context, state) {
      final privacyState = ref.read(privacyServiceProvider);
      
      // If user hasn't completed onboarding, redirect to onboarding
      if (!privacyState.gdprConsentGiven && 
          state.matchedLocation != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }
      
      // If user completed onboarding but tries to access onboarding again
      if (privacyState.gdprConsentGiven && 
          state.matchedLocation == AppRoutes.onboarding) {
        return AppRoutes.home;
      }
      
      return null;
    },
  );
});

// Placeholder screens for routes that aren't implemented yet
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privatliv')),
      body: Center(child: Text('Privatlivsindstillinger')),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Opkaldslog')),
      body: Center(child: Text('Opkaldslog')),
    );
  }
}

class ManualLookupScreen extends StatelessWidget {
  const ManualLookupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manuelt opslag')),
      body: Center(child: Text('Manuelt nummeropslag')),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifikationer')),
      body: Center(child: Text('Notifikationsindstillinger')),
    );
  }
}