import 'dart:convert';
import 'package:crypto/crypto.dart';

/// GDPR-compliant phone number hashing utility
/// All phone numbers are hashed using SHA-256 before storage or transmission
class GDPRUtils {
  /// Hash a phone number using SHA-256 for GDPR compliance
  /// Removes all non-digit characters except '+' before hashing
  static String hashPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    
    // Normalize phone number - keep only digits and '+'
    final normalized = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Convert to bytes and hash
    final bytes = utf8.encode(normalized);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }
  
  /// Validate Danish phone number format
  static bool isValidDanishNumber(String phoneNumber) {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Danish numbers: 8 digits, starting with 2, 4, 6, 8, or 9
    // Can be prefixed with country code (+45 or 0045)
    final danishPattern = RegExp(r'^(\+45|0045)?[2-9]\d{7}$');
    
    return danishPattern.hasMatch(phoneNumber);
  }
  
  /// Anonymize IP address for analytics
  static String anonymizeIp(String ipAddress) {
    if (ipAddress.isEmpty) return '';
    
    // Remove last octet for IPv4
    if (ipAddress.contains('.')) {
      final parts = ipAddress.split('.');
      if (parts.length >= 4) {
        return '${parts[0]}.${parts[1]}.${parts[2]}.0';
      }
    }
    
    // Remove last group for IPv6
    if (ipAddress.contains(':')) {
      final parts = ipAddress.split(':');
      if (parts.length >= 4) {
        return parts.sublist(0, parts.length - 1).join(':') + ':0000';
      }
    }
    
    return ipAddress;
  }
  
  /// Generate a unique but anonymous device identifier
  static String generateAnonymousDeviceId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = now.toString().split('').reversed.join();
    final combined = '$now$random';
    
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    
    // Return first 16 characters for brevity
    return digest.toString().substring(0, 16);
  }
}