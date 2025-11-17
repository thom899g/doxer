import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../models/caller_info.dart';
import '../models/cvr_response.dart';
import '../../../utils/gdpr_utils.dart';
import '../../../utils/logger.dart';
import '../../../utils/rate_limiter.dart';

/// Service for looking up caller information from various sources
class LookupService {
  static const String _cvrBaseUrl = 'https://datacvr.virk.dk';
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'DCI-App/1.0 (contact@example.com)';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RateLimiter _rateLimiter = RateLimiter(
    maxRequests: 60,
    timeWindow: Duration(minutes: 1),
  );
  
  /// Look up caller information from multiple sources
  Future<CallerInfo> lookupNumber(
    String phoneNumber, {
    String? hashedNumber,
  }) async {
    final effectiveHashedNumber = hashedNumber ?? 
        GDPRUtils.hashPhoneNumber(phoneNumber);
    
    try {
      // Check rate limiting
      if (!_rateLimiter.canMakeRequest()) {
        Logger.warning('Rate limit exceeded for lookup');
        return CallerInfo.unknown(phoneNumber);
      }
      
      // Try Firestore crowdsourced data first
      final crowdsourcedInfo = await _lookupCrowdsourcedData(
        effectiveHashedNumber,
      );
      
      if (crowdsourcedInfo != null) {
        Logger.info('Found crowdsourced data for $phoneNumber');
        return crowdsourcedInfo;
      }
      
      // Try CVR lookup for business information
      final cvrInfo = await _lookupCVR(phoneNumber);
      if (cvrInfo != null) {
        Logger.info('Found CVR data for $phoneNumber');
        return cvrInfo;
      }
      
      // Try geocoding for location info
      final locationInfo = await _lookupLocation(phoneNumber);
      if (locationInfo != null) {
        Logger.info('Found location data for $phoneNumber');
        return locationInfo;
      }
      
      // Return unknown if no data found
      return CallerInfo.unknown(phoneNumber);
      
    } catch (e) {
      Logger.error('Lookup failed for $phoneNumber', e);
      return CallerInfo.unknown(phoneNumber);
    }
  }
  
  /// Look up crowdsourced data from Firestore
  Future<CallerInfo?> _lookupCrowdsourcedData(String hashedNumber) async {
    try {
      final doc = await _firestore
          .collection('crowdsourced_callers')
          .doc(hashedNumber)
          .get();
          
      if (doc.exists) {
        final data = doc.data()!;
        return CallerInfo(
          phoneNumber: '', // Don't store original number
          hashedNumber: hashedNumber,
          name: data['name'] ?? '',
          companyName: data['company_name'] ?? '',
          address: data['address'] ?? '',
          spamScore: data['spam_score'] ?? 0,
          isSpam: data['is_spam'] ?? false,
          isBusiness: data['is_business'] ?? false,
          confidence: 0.9, // High confidence for crowdsourced data
          source: 'crowdsourced',
          lastUpdated: data['updated_at']?.toDate() ?? DateTime.now(),
        );
      }
    } catch (e) {
      Logger.error('Failed to lookup crowdsourced data', e);
    }
    
    return null;
  }
  
  /// Look up business information from CVR (Danish Business Register)
  Future<CallerInfo?> _lookupCVR(String phoneNumber) async {
    try {
      // Format phone number for CVR search
      final formattedNumber = _formatPhoneNumberForCVR(phoneNumber);
      
      // Search CVR by phone number
      final searchUrl = '$_cvrBaseUrl/api/v1/virksomhed/_search';
      final searchBody = {
        'query': {
          'match': {
            'telefonnummer': formattedNumber,
          },
        },
        'size': 1,
      };
      
      final response = await http.post(
        Uri.parse(searchUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': _userAgent,
        },
        body: json.encode(searchBody),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hits = data['hits']['hits'] as List;
        
        if (hits.isNotEmpty) {
          final companyData = hits[0]['_source'];
          return _parseCVRResponse(companyData, phoneNumber);
        }
      }
    } catch (e) {
      Logger.error('CVR lookup failed', e);
    }
    
    return null;
  }
  
  /// Format phone number for CVR search
  String _formatPhoneNumberForCVR(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Handle Danish numbers without country code
    if (digitsOnly.length == 8 && digitsOnly.startsWith(RegExp(r'[2-9]'))) {
      return '+45$digitsOnly';
    }
    
    return '+$digitsOnly';
  }
  
  /// Parse CVR response into CallerInfo
  CallerInfo _parseCVRResponse(Map<String, dynamic> data, String phoneNumber) {
    final companyName = data['navn'] ?? '';
    final cvrNumber = data['cvrNummer']?.toString() ?? '';
    final address = _formatAddress(data);
    
    return CallerInfo(
      phoneNumber: phoneNumber,
      hashedNumber: GDPRUtils.hashPhoneNumber(phoneNumber),
      name: companyName,
      companyName: companyName,
      cvrNumber: cvrNumber,
      address: address,
      isBusiness: true,
      confidence: 0.95,
      source: 'cvr',
      lastUpdated: DateTime.now(),
    );
  }
  
  /// Format address from CVR data
  String _formatAddress(Map<String, dynamic> data) {
    final address = data['adresse'] ?? {};
    final street = address['vejnavn'] ?? '';
    final number = address['husnummer'] ?? '';
    const city = address['postdistrikt'] ?? '';
    const postalCode = address['postnummer'] ?? '';
    
    return '$street $number, $postalCode $city'.trim();
  }
  
  /// Look up location information using Nominatim (OpenStreetMap)
  Future<CallerInfo?> _lookupLocation(String phoneNumber) async {
    try {
      // Extract area code for Danish numbers
      final areaCode = _extractAreaCode(phoneNumber);
      if (areaCode == null) return null;
      
      // Search for location based on area code
      final searchQuery = 'Denmark phone area code $areaCode';
      final url = '$_nominatimBaseUrl/search?'
          'q=${Uri.encodeComponent(searchQuery)}'
          '&format=json'
          '&countrycodes=dk'
          '&limit=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': _userAgent,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        
        if (data.isNotEmpty) {
          final location = data[0];
          return CallerInfo(
            phoneNumber: phoneNumber,
            hashedNumber: GDPRUtils.hashPhoneNumber(phoneNumber),
            name: 'Ukendt nummer',
            address: location['display_name'] ?? 'Danmark',
            latitude: double.tryParse(location['lat'] ?? ''),
            longitude: double.tryParse(location['lon'] ?? ''),
            isBusiness: false,
            confidence: 0.3,
            source: 'nominatim',
            lastUpdated: DateTime.now(),
          );
        }
      }
    } catch (e) {
      Logger.error('Location lookup failed', e);
    }
    
    return null;
  }
  
  /// Extract area code from Danish phone number
  String? _extractAreaCode(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Danish mobile numbers start with specific prefixes
    if (digitsOnly.length == 8) {
      if (digitsOnly.startsWith('2')) return 'Mobile (Telenor)';
      if (digitsOnly.startsWith('3')) return 'Mobile (Hi3G)';
      if (digitsOnly.startsWith('4')) return 'Mobile (Telia)';
      if (digitsOnly.startsWith('5')) return 'Mobile (TDC)';
      if (digitsOnly.startsWith('6')) return 'Mobile (Telenor)';
      if (digitsOnly.startsWith('7')) return 'Mobile (TDC)';
      if (digitsOnly.startsWith('8')) return 'Mobile (Telia)';
      if (digitsOnly.startsWith('9')) return 'Mobile (Hi3G)';
    }
    
    // Landline area codes
    if (digitsOnly.startsWith('32')) return 'Fyn';
    if (digitsOnly.startsWith('33')) return 'København';
    if (digitsOnly.startsWith('35')) return 'Sjælland';
    if (digitsOnly.startsWith('36')) return 'Jylland';
    if (digitsOnly.startsWith('38')) return 'Jylland';
    if (digitsOnly.startsWith('39')) return 'Jylland';
    if (digitsOnly.startsWith('43')) return 'Sjælland';
    if (digitsOnly.startsWith('44')) return 'Sjælland';
    if (digitsOnly.startsWith('45')) return 'Sjælland';
    if (digitsOnly.startsWith('46')) return 'Sjælland';
    if (digitsOnly.startsWith('47')) return 'Sjælland';
    if (digitsOnly.startsWith('48')) return 'Sjælland';
    if (digitsOnly.startsWith('49')) return 'Sjælland';
    if (digitsOnly.startsWith('53')) return 'Jylland';
    if (digitsOnly.startsWith('54')) return 'Jylland';
    if (digitsOnly.startsWith('55')) return 'Jylland';
    if (digitsOnly.startsWith('56')) return 'Jylland';
    if (digitsOnly.startsWith('57')) return 'Jylland';
    if (digitsOnly.startsWith('58')) return 'Jylland';
    if (digitsOnly.startsWith('59')) return 'Jylland';
    if (digitsOnly.startsWith('63')) return 'Fyn';
    if (digitsOnly.startsWith('64')) return 'Fyn';
    if (digitsOnly.startsWith('65')) return 'Fyn';
    if (digitsOnly.startsWith('66')) return 'Fyn';
    if (digitsOnly.startsWith('67')) return 'Fyn';
    if (digitsOnly.startsWith('68')) return 'Fyn';
    if (digitsOnly.startsWith('69')) return 'Fyn';
    if (digitsOnly.startsWith('70')) return 'Service nummer';
    if (digitsOnly.startsWith('80')) return 'Toll-free';
    if (digitsOnly.startsWith('90')) return 'Premium rate';
    
    return null;
  }
  
  /// Report spam number to crowdsourced database
  Future<void> reportSpam(
    String phoneNumber, {
    required String reason,
    required int spamScore,
  }) async {
    final hashedNumber = GDPRUtils.hashPhoneNumber(phoneNumber);
    
    try {
      await _firestore
          .collection('crowdsourced_callers')
          .doc(hashedNumber)
          .set({
        'spam_score': spamScore,
        'is_spam': true,
        'spam_reports': FieldValue.increment(1),
        'last_spam_report': FieldValue.serverTimestamp(),
        'notes': reason,
        'updated_at': FieldValue.serverTimestamp(),
        'country': 'DK',
      }, SetOptions(merge: true));
      
      Logger.info('Spam report submitted for $phoneNumber');
    } catch (e) {
      Logger.error('Failed to report spam', e);
    }
  }
  
  /// Add caller information to crowdsourced database
  Future<void> addToCrowdsourcedDatabase(
    CallerInfo callerInfo, {
    required bool userConsented,
  }) async {
    if (!userConsented) {
      Logger.info('User has not consented to data sharing');
      return;
    }
    
    try {
      // Rate limit uploads
      if (!_rateLimiter.canMakeRequest()) {
        Logger.warning('Rate limit exceeded for uploads');
        return;
      }
      
      await _firestore
          .collection('crowdsourced_callers')
          .doc(callerInfo.hashedNumber)
          .set({
        'name': callerInfo.name,
        'company_name': callerInfo.companyName,
        'address': callerInfo.address,
        'spam_score': callerInfo.spamScore,
        'is_spam': callerInfo.isSpam,
        'is_business': callerInfo.isBusiness,
        'updated_at': FieldValue.serverTimestamp(),
        'country': 'DK',
      }, SetOptions(merge: true));
      
      Logger.info('Added ${callerInfo.hashedNumber} to crowdsourced database');
    } catch (e) {
      Logger.error('Failed to add to crowdsourced database', e);
    }
  }
}