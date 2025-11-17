import 'dart:async';

/// Rate limiter utility to prevent API abuse
class RateLimiter {
  final int maxRequests;
  final Duration timeWindow;
  final List<DateTime> _requests = [];
  
  RateLimiter({
    required this.maxRequests,
    required this.timeWindow,
  });
  
  /// Check if a request can be made
  bool canMakeRequest() {
    final now = DateTime.now();
    
    // Remove old requests outside the time window
    _requests.removeWhere((requestTime) {
      return now.difference(requestTime) > timeWindow;
    });
    
    // Check if we're within the limit
    return _requests.length < maxRequests;
  }
  
  /// Record a request
  void recordRequest() {
    if (canMakeRequest()) {
      _requests.add(DateTime.now());
    }
  }
  
  /// Get remaining requests in current window
  int get remainingRequests {
    final now = DateTime.now();
    
    // Remove old requests
    _requests.removeWhere((requestTime) {
      return now.difference(requestTime) > timeWindow;
    });
    
    return maxRequests - _requests.length;
  }
  
  /// Get time until next request can be made
  Duration? get timeUntilNextRequest {
    if (canMakeRequest()) {
      return null;
    }
    
    final now = DateTime.now();
    final oldestRequest = _requests.first;
    final timeUntilWindowReset = timeWindow - now.difference(oldestRequest);
    
    return timeUntilWindowReset.isNegative ? Duration.zero : timeUntilWindowReset;
  }
  
  /// Reset all requests
  void reset() {
    _requests.clear();
  }
  
  /// Get current request count in window
  int get currentRequestCount {
    final now = DateTime.now();
    
    // Remove old requests
    _requests.removeWhere((requestTime) {
      return now.difference(requestTime) > timeWindow;
    });
    
    return _requests.length;
  }
}