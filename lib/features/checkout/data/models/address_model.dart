class AddressModel {
  final int id;
  final int profileId;
  final CityModel city;
  final String street;
  final String houseNumber;
  final String? addressLine2;
  final String? reference;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String status;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    required this.profileId,
    required this.city,
    required this.street,
    required this.houseNumber,
    this.addressLine2,
    this.reference,
    this.postalCode,
    this.latitude,
    this.longitude,
    required this.status,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      profileId: json['profile_id'] as int? ?? 0,
      city: CityModel.fromJson(json['city'] as Map<String, dynamic>),
      street: json['street'] as String,
      houseNumber: json['house_number'] as String,
      addressLine2: json['address_line_2'] as String?,
      reference: json['reference'] as String?,
      postalCode: json['postal_code'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      status: json['status'] as String? ?? 'notverified',
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'city': city.toJson(),
      'street': street,
      'house_number': houseNumber,
      'address_line_2': addressLine2,
      'reference': reference,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'is_default': isDefault,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get fullAddress {
    final parts = <String>[];
    
    parts.add('$street $houseNumber');
    
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      parts.add(addressLine2!);
    }
    
    parts.add('${city.name}, ${city.state?.name ?? ''}');
    
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add('CP: $postalCode');
    }
    
    return parts.join(', ');
  }

  String get shortAddress {
    return '$street $houseNumber, ${city.name}';
  }
}

class CityModel {
  final int id;
  final String name;
  final StateModel? state;

  CityModel({
    required this.id,
    required this.name,
    this.state,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      state: json['state'] != null
          ? StateModel.fromJson(json['state'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (state != null) 'state': state!.toJson(),
    };
  }
}

class StateModel {
  final int id;
  final String name;

  StateModel({
    required this.id,
    required this.name,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

