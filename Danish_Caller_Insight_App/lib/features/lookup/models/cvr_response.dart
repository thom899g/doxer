/// Model for CVR (Danish Business Register) API response
class CVRResponse {
  final String? cvrNumber;
  final String? name;
  final String? phoneNumber;
  final String? email;
  final Address? address;
  final String? industry;
  final String? status;
  
  const CVRResponse({
    this.cvrNumber,
    this.name,
    this.phoneNumber,
    this.email,
    this.address,
    this.industry,
    this.status,
  });
  
  factory CVRResponse.fromJson(Map<String, dynamic> json) {
    return CVRResponse(
      cvrNumber: json['cvrNummer']?.toString(),
      name: json['navn'],
      phoneNumber: json['telefonnummer'],
      email: json['email'],
      address: json['adresse'] != null 
          ? Address.fromJson(json['adresse'])
          : null,
      industry: json['branche'],
      status: json['status'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'cvrNummer': cvrNumber,
      'navn': name,
      'telefonnummer': phoneNumber,
      'email': email,
      'adresse': address?.toJson(),
      'branche': industry,
      'status': status,
    };
  }
  
  /// Check if the company is active
  bool get isActive => status?.toLowerCase() == 'aktiv';
  
  /// Get formatted company name
  String get formattedName => name ?? 'Ukendt virksomhed';
  
  /// Get industry description
  String get industryDescription {
    if (industry == null) return 'Ingen branche angivet';
    
    // Danish industry code translations
    final industryMap = {
      '01': 'Jordbrug, skovbrug og fiskeri',
      '02': 'Indvinding af råstoffer',
      '03': 'Industri',
      '04': 'Energiforsyning',
      '05': 'Vandforsyning',
      '06': 'Bygge og anlæg',
      '07': 'Handel',
      '08': 'Transport',
      '09': 'Hoteller og restauranter',
      '10': 'Information og kommunikation',
      '11': 'Finansiering og forsikring',
      '12': 'Ejendomshandel',
      '13': 'Videnservice',
      '14': 'Administrative tjenester',
      '15': 'Offentlig administration',
      '16': 'Undervisning',
      '17': 'Sundhedsvæsen',
      '18': 'Kultur og fritid',
      '19': 'Andre serviceydelser',
    };
    
    final industryCode = industry!.substring(0, 2);
    return industryMap[industryCode] ?? industry!;
  }
}

/// Address information from CVR
class Address {
  final String? street;
  final String? houseNumber;
  final String? floor;
  final String? door;
  final String? postalCode;
  final String? city;
  final String? municipality;
  final String? country;
  
  const Address({
    this.street,
    this.houseNumber,
    this.floor,
    this.door,
    this.postalCode,
    this.city,
    this.municipality,
    this.country,
  });
  
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['vejnavn'],
      houseNumber: json['husnummer'],
      floor: json['etage'],
      door: json['sidedoer'],
      postalCode: json['postnummer'],
      city: json['postdistrikt'],
      municipality: json['kommune'],
      country: json['land'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'vejnavn': street,
      'husnummer': houseNumber,
      'etage': floor,
      'sidedoer': door,
      'postnummer': postalCode,
      'postdistrikt': city,
      'kommune': municipality,
      'land': country,
    };
  }
  
  /// Get formatted address
  String get formattedAddress {
    final parts = <String>[];
    
    if (street != null) parts.add(street!);
    if (houseNumber != null) parts.add(houseNumber!);
    if (floor != null) parts.add('${floor!}. sal');
    if (door != null) parts.add('${door!}.');
    
    final addressLine = parts.join(' ');
    final locationParts = <String>[];
    
    if (postalCode != null) locationParts.add(postalCode!);
    if (city != null) locationParts.add(city!);
    
    final locationLine = locationParts.join(' ');
    
    return '$addressLine, $locationLine';
  }
  
  /// Get city and postal code only
  String get cityAndPostal {
    final parts = <String>[];
    if (postalCode != null) parts.add(postalCode!);
    if (city != null) parts.add(city!);
    return parts.join(' ');
  }
}