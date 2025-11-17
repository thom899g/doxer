import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Logger utility for the app
class Logger {
  static const String _name = 'DanishCallerInsight';
  
  /// Log info message
  static void info(String message) {
    if (kDebugMode) {
      developer.log('ℹ️ $message', name: _name);
    }
  }
  
  /// Log warning message
  static void warning(String message) {
    if (kDebugMode) {
      developer.log('⚠️ $message', name: _name);
    }
  }
  
  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        '❌ $message${error != null ? '\nError: $error' : ''}',
        name: _name,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Log debug message
  static void debug(String message) {
    if (kDebugMode) {
      developer.log('🐛 $message', name: _name);
    }
  }
  
  /// Log API request
  static void apiRequest(String method, String url, [Map<String, dynamic>? params]) {
    if (kDebugMode) {
      developer.log(
        '🌐 API Request: $method $url${params != null ? '\nParams: $params' : ''}',
        name: _name,
      );
    }
  }
  
  /// Log API response
  static void apiResponse(String url, int statusCode, [dynamic response]) {
    if (kDebugMode) {
      final statusEmoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      developer.log(
        '$statusEmoji API Response: $url\nStatus: $statusCode${response != null ? '\nResponse: ${response.toString().substring(0, 200)}...' : ''}',
        name: _name,
      );
    }
  }
}