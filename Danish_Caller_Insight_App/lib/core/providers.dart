import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/privacy/services/privacy_service.dart';
import '../features/monetization/services/monetization_service.dart';
import '../features/history/services/history_service.dart';

/// Global app providers
final appProviders = [
  // Privacy and GDPR
  privacyServiceProvider,
  
  // Monetization
  monetizationServiceProvider,
  
  // History
  historyServiceProvider,
];

/// Provider for app initialization status
final appInitializationProvider = Provider<bool>((ref) {
  final privacyState = ref.watch(privacyServiceProvider);
  final monetizationState = ref.watch(monetizationServiceProvider);
  
  // App is initialized when GDPR consent is given
  return privacyState.gdprConsentGiven;
});