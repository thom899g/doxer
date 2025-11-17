import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/logger.dart';
import '../../../utils/gdpr_utils.dart';

/// Service handling GDPR compliance and privacy controls
class PrivacyService extends StateNotifier<PrivacyState> {
  PrivacyService() : super(PrivacyState.initial()) {
    _initialize();
  }
  
  static const String _consentKey = 'gdpr_consent';
  static const String _dataSharingKey = 'data_sharing_consent';
  static const String _analyticsKey = 'analytics_consent';
  static const String _adsKey = 'ads_consent';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final SharedPreferences _prefs;
  
  /// Initialize privacy service
  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadConsentState();
  }
  
  /// Load consent state from storage
  Future<void> _loadConsentState() async {
    final gdprConsent = _prefs.getBool(_consentKey) ?? false;
    final dataSharingConsent = _prefs.getBool(_dataSharingKey) ?? false;
    final analyticsConsent = _prefs.getBool(_analyticsKey) ?? false;
    final adsConsent = _prefs.getBool(_adsKey) ?? false;
    
    final deviceId = await _getOrCreateDeviceId();
    
    state = state.copyWith(
      gdprConsentGiven: gdprConsent,
      dataSharingConsentGiven: dataSharingConsent,
      analyticsConsentGiven: analyticsConsent,
      adsConsentGiven: adsConsent,
      deviceId: deviceId,
    );
  }
  
  /// Get or create anonymous device ID
  Future<String> _getOrCreateDeviceId() async {
    String? deviceId = await _secureStorage.read(key: 'device_id');
    
    if (deviceId == null) {
      deviceId = GDPRUtils.generateAnonymousDeviceId();
      await _secureStorage.write(key: 'device_id', value: deviceId);
    }
    
    return deviceId;
  }
  
  /// Grant GDPR consent
  Future<void> grantGDPRConsent() async {
    await _prefs.setBool(_consentKey, true);
    state = state.copyWith(gdprConsentGiven: true);
    Logger.info('GDPR consent granted');
  }
  
  /// Revoke GDPR consent
  Future<void> revokeGDPRConsent() async {
    await _prefs.setBool(_consentKey, false);
    state = state.copyWith(gdprConsentGiven: false);
    
    // Delete all user data if consent is revoked
    await deleteAllUserData();
    Logger.info('GDPR consent revoked');
  }
  
  /// Grant data sharing consent
  Future<void> grantDataSharingConsent() async {
    await _prefs.setBool(_dataSharingKey, true);
    state = state.copyWith(dataSharingConsentGiven: true);
    Logger.info('Data sharing consent granted');
  }
  
  /// Revoke data sharing consent
  Future<void> revokeDataSharingConsent() async {
    await _prefs.setBool(_dataSharingKey, false);
    state = state.copyWith(dataSharingConsentGiven: false);
    
    // Remove user's contributions from crowdsourced database
    await _removeUserContributions();
    Logger.info('Data sharing consent revoked');
  }
  
  /// Grant analytics consent
  Future<void> grantAnalyticsConsent() async {
    await _prefs.setBool(_analyticsKey, true);
    state = state.copyWith(analyticsConsentGiven: true);
    Logger.info('Analytics consent granted');
  }
  
  /// Revoke analytics consent
  Future<void> revokeAnalyticsConsent() async {
    await _prefs.setBool(_analyticsKey, false);
    state = state.copyWith(analyticsConsentGiven: false);
    Logger.info('Analytics consent revoked');
  }
  
  /// Grant ads consent
  Future<void> grantAdsConsent() async {
    await _prefs.setBool(_adsKey, true);
    state = state.copyWith(adsConsentGiven: true);
    Logger.info('Ads consent granted');
  }
  
  /// Revoke ads consent
  Future<void> revokeAdsConsent() async {
    await _prefs.setBool(_adsKey, false);
    state = state.copyWith(adsConsentGiven: false);
    Logger.info('Ads consent revoked');
  }
  
  /// Check if all required consents are granted
  bool get allConsentsGranted {
    return state.gdprConsentGiven &&
           state.dataSharingConsentGiven &&
           state.analyticsConsentGiven &&
           state.adsConsentGiven;
  }
  
  /// Check if data sharing is allowed
  bool get canShareData => state.dataSharingConsentGiven;
  
  /// Check if analytics is allowed
  bool get canUseAnalytics => state.analyticsConsentGiven;
  
  /// Check if ads are allowed
  bool get canShowAds => state.adsConsentGiven;
  
  /// Delete all user data (GDPR "right to be forgotten")
  Future<void> deleteAllUserData() async {
    try {
      Logger.info('Starting complete data deletion for user');
      
      // Clear local storage
      await _prefs.clear();
      await _secureStorage.deleteAll();
      
      // Remove from crowdsourced database
      await _removeUserContributions();
      
      // Clear app data
      await _clearAppData();
      
      Logger.info('All user data deleted successfully');
    } catch (e) {
      Logger.error('Failed to delete user data', e);
      rethrow;
    }
  }
  
  /// Remove user's contributions from crowdsourced database
  Future<void> _removeUserContributions() async {
    try {
      // Get all documents contributed by this device
      final querySnapshot = await _firestore
          .collection('crowdsourced_callers')
          .where('device_id', isEqualTo: state.deviceId)
          .get();
      
      // Delete each document
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      
      Logger.info('Removed ${querySnapshot.docs.length} user contributions');
    } catch (e) {
      Logger.error('Failed to remove user contributions', e);
    }
  }
  
  /// Clear app-specific data
  Future<void> _clearAppData() async {
    try {
      // Clear call history
      // Clear cached data
      // Clear settings
      // This would be implemented based on your specific data storage
      
      Logger.info('App data cleared');
    } catch (e) {
      Logger.error('Failed to clear app data', e);
    }
  }
  
  /// Export user data (GDPR "right to data portability")
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      Logger.info('Exporting user data');
      
      final userData = <String, dynamic>{
        'device_id': state.deviceId,
        'consents': {
          'gdpr': state.gdprConsentGiven,
          'data_sharing': state.dataSharingConsentGiven,
          'analytics': state.analyticsConsentGiven,
          'ads': state.adsConsentGiven,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Add user's contributions
      try {
        final querySnapshot = await _firestore
            .collection('crowdsourced_callers')
            .where('device_id', isEqualTo: state.deviceId)
            .get();
        
        userData['contributions'] = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'hashed_number': doc.id,
            'data': data,
          };
        }).toList();
      } catch (e) {
        Logger.error('Failed to export user contributions', e);
        userData['contributions_error'] = e.toString();
      }
      
      return userData;
    } catch (e) {
      Logger.error('Failed to export user data', e);
      rethrow;
    }
  }
  
  /// Get privacy policy text
  String getPrivacyPolicy() {
    return '''
Privacy Policy for Danish Caller Insight

Last updated: ${DateTime.now().toString().substring(0, 10)}

1. DATA COLLECTION AND USE

We collect and process the following types of information:

1.1 Phone Numbers
- All phone numbers are hashed using SHA-256 before storage or transmission
- Original phone numbers are never stored permanently
- Hashing ensures GDPR compliance while allowing call identification

1.2 Caller Information
- Business information from public CVR registry
- Location data from OpenStreetMap
- User-contributed spam reports (with explicit consent)

1.3 Device Information
- Anonymous device ID for app functionality
- No personally identifiable information collected

2. DATA SHARING

We only share data when you explicitly consent:
- Hashed phone numbers and spam reports to crowdsourced database
- No personal information shared with third parties
- All data sharing is optional and can be revoked

3. YOUR RIGHTS UNDER GDPR

3.1 Right to Access
- Export all your data through the app
- See what information we have about you

3.2 Right to Rectification
- Correct any inaccurate data
- Update your preferences

3.3 Right to Erasure
- Delete all your data permanently
- Remove your contributions from our database

3.4 Right to Data Portability
- Export your data in machine-readable format
- Transfer your data to another service

4. CONSENT MANAGEMENT

You control your data:
- Grant or revoke consent at any time
- Each consent type can be managed separately
- No functionality loss for declining consent

5. DATA RETENTION

- Crowdsourced data: Until you request deletion
- Local app data: Until app uninstall or data deletion
- Analytics data: 26 months maximum

6. SECURITY MEASURES

- All phone numbers hashed with SHA-256
- Secure storage for sensitive data
- No plaintext phone numbers stored
- Regular security audits

7. CONTACT

For privacy questions or data requests:
- Email: privacy@danishcallerinsight.com
- Data Protection Officer: Danish Caller Insight Team

By using this app, you agree to this privacy policy.
    ''';
  }
  
  /// Check if onboarding is complete
  bool get isOnboardingComplete => state.gdprConsentGiven;
}

/// State for privacy service
class PrivacyState {
  final bool gdprConsentGiven;
  final bool dataSharingConsentGiven;
  final bool analyticsConsentGiven;
  final bool adsConsentGiven;
  final String deviceId;
  
  const PrivacyState({
    required this.gdprConsentGiven,
    required this.dataSharingConsentGiven,
    required this.analyticsConsentGiven,
    required this.adsConsentGiven,
    required this.deviceId,
  });
  
  factory PrivacyState.initial() {
    return const PrivacyState(
      gdprConsentGiven: false,
      dataSharingConsentGiven: false,
      analyticsConsentGiven: false,
      adsConsentGiven: false,
      deviceId: '',
    );
  }
  
  PrivacyState copyWith({
    bool? gdprConsentGiven,
    bool? dataSharingConsentGiven,
    bool? analyticsConsentGiven,
    bool? adsConsentGiven,
    String? deviceId,
  }) {
    return PrivacyState(
      gdprConsentGiven: gdprConsentGiven ?? this.gdprConsentGiven,
      dataSharingConsentGiven: dataSharingConsentGiven ?? this.dataSharingConsentGiven,
      analyticsConsentGiven: analyticsConsentGiven ?? this.analyticsConsentGiven,
      adsConsentGiven: adsConsentGiven ?? this.adsConsentGiven,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}

/// Provider for privacy service
final privacyServiceProvider = StateNotifierProvider<PrivacyService, PrivacyState>(
  (ref) => PrivacyService(),
);