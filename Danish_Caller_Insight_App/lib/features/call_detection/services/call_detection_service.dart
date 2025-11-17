import 'dart:async';
import 'dart:isolate';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:telephony/telephony.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../lookup/services/lookup_service.dart';
import '../../lookup/models/caller_info.dart';
import '../models/call_event.dart';
import '../../../utils/gdpr_utils.dart';
import '../../../utils/logger.dart';

/// Service for detecting incoming calls and handling call state changes
class CallDetectionService {
  static const String _channelId = 'danish_caller_insight_calls';
  static const String _channelName = 'Call Insights';
  static const String _channelDescription = 'Shows caller information for unknown numbers';
  
  final Telephony _telephony = Telephony.instance;
  final LookupService _lookupService = LookupService();
  
  StreamSubscription<CallEvent>? _callSubscription;
  bool _isInitialized = false;
  
  /// Initialize call detection service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize CallKit for iOS
      await _initializeCallKit();
      
      // Set up telephony listener for Android
      await _setupTelephonyListener();
      
      _isInitialized = true;
      Logger.info('Call detection service initialized');
    } catch (e) {
      Logger.error('Failed to initialize call detection service', e);
    }
  }
  
  /// Initialize CallKit for iOS
  Future<void> _initializeCallKit() async {
    final params = <String, dynamic>{
      'id': 'danish_caller_insight',
      'nameCaller': 'Danish Caller Insight',
      'appName': 'Danish Caller Insight',
      'avatar': '',
      'handle': '',
      'type': 0,
      'duration': 30000,
      'textAccept': 'Acceptér',
      'textDecline': 'Afvis',
      'textMissedCall': 'Missed call',
      'textCallback': 'Call back',
      'android': {
        'isCustomNotification': true,
        'isShowLogo': false,
        'isShowCallID': true,
        'ringtonePath': 'ringtone_default',
        'backgroundColor': '#095D7E',
        'backgroundUrl': '',
        'actionColor': '#4CAF50',
        'incomingCallNotificationChannelName': _channelName,
        'missedCallNotificationChannelName': 'Missed Calls',
      },
      'ios': {
        'iconName': 'AppIcon',
        'handleType': 'generic',
        'supportsVideo': false,
        'maximumCallGroups': 1,
        'maximumCallsPerCallGroup': 1,
        'audioSessionMode': 'default',
        'audioSessionActive': true,
        'audioSessionPreferredSampleRate': 44100.0,
        'audioSessionPreferredIOBufferDuration': 0.005,
      },
    };
    
    await FlutterCallkitIncoming.setup(params);
  }
  
  /// Set up telephony listener for Android
  Future<void> _setupTelephonyListener() async {
    // Request necessary permissions
    final permissionsGranted = await _telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted == null || !permissionsGranted) {
      Logger.warning('Phone permissions not granted');
      return;
    }
    
    // Listen for incoming calls
    _callSubscription = _telephony.listenCallEvent(
      onRinging: (event) => _handleIncomingCall(event),
      onAnswered: (event) => _handleCallAnswered(event),
      onDisconnected: (event) => _handleCallEnded(event),
      onMissedCall: (event) => _handleMissedCall(event),
    );
  }
  
  /// Handle incoming call
  Future<void> _handleIncomingCall(CallEvent event) async {
    if (event.phoneNumber == null) return;
    
    final phoneNumber = event.phoneNumber!;
    Logger.info('Incoming call from: $phoneNumber');
    
    // Check if number is in contacts
    final isInContacts = await _isNumberInContacts(phoneNumber);
    if (isInContacts) {
      Logger.info('Call from known contact, skipping lookup');
      return;
    }
    
    // Hash the phone number for GDPR compliance
    final hashedNumber = GDPRUtils.hashPhoneNumber(phoneNumber);
    
    try {
      // Perform lookup in background
      final callerInfo = await _lookupService.lookupNumber(
        phoneNumber,
        hashedNumber: hashedNumber,
      );
      
      // Show CallKit UI with caller information
      await _showCallKitUI(phoneNumber, callerInfo);
      
      // Auto-reject if spam score is high
      if (callerInfo.spamScore > 80) {
        await _autoRejectCall(phoneNumber, callerInfo);
      }
      
    } catch (e) {
      Logger.error('Failed to lookup caller information', e);
      await _showCallKitUI(phoneNumber, CallerInfo.unknown(phoneNumber));
    }
  }
  
  /// Check if phone number exists in user contacts
  Future<bool> _isNumberInContacts(String phoneNumber) async {
    try {
      final contacts = await ContactsService.getContacts();
      return contacts.any((contact) {
        return contact.phones?.any((phone) {
          return _normalizePhoneNumber(phone.value ?? '') == 
                 _normalizePhoneNumber(phoneNumber);
        }) ?? false;
      });
    } catch (e) {
      Logger.error('Failed to check contacts', e);
      return false;
    }
  }
  
  /// Normalize phone number for comparison
  String _normalizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  }
  
  /// Show CallKit UI with caller information
  Future<void> _showCallKitUI(String phoneNumber, CallerInfo callerInfo) async {
    final params = <String, dynamic>{
      'id': hashedNumber,
      'nameCaller': callerInfo.name.isNotEmpty ? callerInfo.name : 'Ukendt nummer',
      'handle': phoneNumber,
      'type': 0,
      'duration': 30000,
      'extra': {
        'spamScore': callerInfo.spamScore,
        'companyName': callerInfo.companyName,
        'address': callerInfo.address,
        'isBusiness': callerInfo.isBusiness,
      },
      'android': {
        'isCustomNotification': true,
        'isShowLogo': callerInfo.isBusiness,
        'backgroundColor': _getBackgroundColor(callerInfo.spamScore),
      },
    };
    
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
  
  /// Get background color based on spam score
  String _getBackgroundColor(int spamScore) {
    if (spamScore > 80) return '#FF4444'; // Red for high spam
    if (spamScore > 50) return '#FF8800'; // Orange for medium spam
    if (spamScore > 20) return '#FFCC00'; // Yellow for low spam
    return '#095D7E'; // Blue for safe
  }
  
  /// Auto-reject call if spam score is high
  Future<void> _autoRejectCall(String phoneNumber, CallerInfo callerInfo) async {
    Logger.info('Auto-rejecting high spam call: $phoneNumber');
    
    // End the call
    await FlutterCallkitIncoming.endCall(hashedNumber);
    
    // Log to analytics
    final analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(
      name: 'spam_call_rejected',
      parameters: {
        'spam_score': callerInfo.spamScore,
        'is_business': callerInfo.isBusiness,
        'has_company_name': callerInfo.companyName.isNotEmpty,
      },
    );
    
    // Show notification about blocked call
    await _showBlockedCallNotification(phoneNumber, callerInfo);
  }
  
  /// Show notification for blocked call
  Future<void> _showBlockedCallNotification(String phoneNumber, CallerInfo callerInfo) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'blocked_calls',
      'Blokerede opkald',
      channelDescription: 'Notifikationer for automatisk blokerede opkald',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFFF4444),
    );
    
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    await flutterLocalNotificationsPlugin.show(
      phoneNumber.hashCode,
      'Opkald blokeret',
      '${callerInfo.name} ($phoneNumber) blev blokeret pga. høj spam-score (${callerInfo.spamScore}%)',
      platformChannelSpecifics,
    );
  }
  
  /// Handle call answered
  void _handleCallAnswered(CallEvent event) {
    Logger.info('Call answered: ${event.phoneNumber}');
    FlutterCallkitIncoming.endCall(hashedNumber);
  }
  
  /// Handle call ended
  void _handleCallEnded(CallEvent event) {
    Logger.info('Call ended: ${event.phoneNumber}');
    FlutterCallkitIncoming.endCall(hashedNumber);
  }
  
  /// Handle missed call
  void _handleMissedCall(CallEvent event) {
    Logger.info('Missed call: ${event.phoneNumber}');
    FlutterCallkitIncoming.endCall(hashedNumber);
  }
  
  /// Dispose resources
  void dispose() {
    _callSubscription?.cancel();
  }
}