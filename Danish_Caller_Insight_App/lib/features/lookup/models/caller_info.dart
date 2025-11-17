import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing caller information
class CallerInfo {
  final String phoneNumber;
  final String hashedNumber;
  final String name;
  final String companyName;
  final String cvrNumber;
  final String address;
  final double? latitude;
  final double? longitude;
  final int spamScore;
  final bool isSpam;
  final bool isBusiness;
  final double confidence;
  final String source;
  final DateTime lastUpdated;
  
  const CallerInfo({
    required this.phoneNumber,
    required this.hashedNumber,
    this.name = '',
    this.companyName = '',
    this.cvrNumber = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.spamScore = 0,
    this.isSpam = false,
    this.isBusiness = false,
    required this.confidence,
    required this.source,
    required this.lastUpdated,
  });
  
  /// Create unknown caller info
  factory CallerInfo.unknown(String phoneNumber) {
    final hashedNumber = GDPRUtils.hashPhoneNumber(phoneNumber);
    return CallerInfo(
      phoneNumber: phoneNumber,
      hashedNumber: hashedNumber,
      name: 'Ukendt nummer',
      confidence: 0.0,
      source: 'unknown',
      lastUpdated: DateTime.now(),
    );
  }
  
  /// Create from Firestore document
  factory CallerInfo.fromFirestore(
    DocumentSnapshot doc,
    String phoneNumber,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return CallerInfo(
      phoneNumber: phoneNumber,
      hashedNumber: doc.id,
      name: data['name'] ?? '',
      companyName: data['company_name'] ?? '',
      address: data['address'] ?? '',
      spamScore: data['spam_score'] ?? 0,
      isSpam: data['is_spam'] ?? false,
      isBusiness: data['is_business'] ?? false,
      confidence: 0.9,
      source: 'firestore',
      lastUpdated: data['updated_at']?.toDate() ?? DateTime.now(),
    );
  }
  
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'company_name': companyName,
      'address': address,
      'spam_score': spamScore,
      'is_spam': isSpam,
      'is_business': isBusiness,
      'updated_at': Timestamp.now(),
      'country': 'DK',
    };
  }
  
  /// Convert to local database map
  Map<String, dynamic> toMap() {
    return {
      'hashed_number': hashedNumber,
      'name': name,
      'company_name': companyName,
      'cvr_number': cvrNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'spam_score': spamScore,
      'is_spam': isSpam ? 1 : 0,
      'is_business': isBusiness ? 1 : 0,
      'confidence': confidence,
      'source': source,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
  
  /// Create from local database map
  factory CallerInfo.fromMap(Map<String, dynamic> map, String phoneNumber) {
    return CallerInfo(
      phoneNumber: phoneNumber,
      hashedNumber: map['hashed_number'],
      name: map['name'] ?? '',
      companyName: map['company_name'] ?? '',
      cvrNumber: map['cvr_number'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
      spamScore: map['spam_score'] ?? 0,
      isSpam: map['is_spam'] == 1,
      isBusiness: map['is_business'] == 1,
      confidence: map['confidence'] ?? 0.0,
      source: map['source'] ?? 'local',
      lastUpdated: DateTime.parse(map['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  /// Copy with modifications
  CallerInfo copyWith({
    String? phoneNumber,
    String? hashedNumber,
    String? name,
    String? companyName,
    String? cvrNumber,
    String? address,
    double? latitude,
    double? longitude,
    int? spamScore,
    bool? isSpam,
    bool? isBusiness,
    double? confidence,
    String? source,
    DateTime? lastUpdated,
  }) {
    return CallerInfo(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hashedNumber: hashedNumber ?? this.hashedNumber,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      cvrNumber: cvrNumber ?? this.cvrNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      spamScore: spamScore ?? this.spamScore,
      isSpam: isSpam ?? this.isSpam,
      isBusiness: isBusiness ?? this.isBusiness,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
  
  /// Get display name
  String get displayName {
    if (name.isNotEmpty) return name;
    if (companyName.isNotEmpty) return companyName;
    return 'Ukendt nummer';
  }
  
  /// Get spam score as percentage
  String get spamScorePercentage => '$spamScore%';
  
  /// Get spam score color
  Color get spamScoreColor {
    if (spamScore > 80) return Colors.red;
    if (spamScore > 50) return Colors.orange;
    if (spamScore > 20) return Colors.yellow;
    return Colors.green;
  }
  
  /// Check if information is recent (less than 30 days old)
  bool get isRecent {
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    return lastUpdated.isAfter(thirtyDaysAgo);
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CallerInfo &&
        other.hashedNumber == hashedNumber;
  }
  
  @override
  int get hashCode => hashedNumber.hashCode;
  
  @override
  String toString() {
    return 'CallerInfo(hashedNumber: $hashedNumber, name: $name, spamScore: $spamScore)';
  }
}