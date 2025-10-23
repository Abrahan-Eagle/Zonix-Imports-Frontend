class AddressModel {
  final int? id;
  final int profileId;
  final int cityId;
  final String street;
  final String houseNumber;
  final String? addressLine2;
  final String? reference;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String status; // 'completeData', 'incompleteData', 'notverified'
  final bool isDefault;

  // Relaciones
  final String? cityName;
  final String? stateName;

  AddressModel({
    this.id,
    required this.profileId,
    required this.cityId,
    required this.street,
    required this.houseNumber,
    this.addressLine2,
    this.reference,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.status = 'notverified',
    this.isDefault = false,
    this.cityName,
    this.stateName,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      profileId: json['profile_id'] is int
          ? json['profile_id']
          : int.parse(json['profile_id'].toString()),
      cityId: json['city_id'] is int
          ? json['city_id']
          : int.parse(json['city_id'].toString()),
      street: json['street'],
      houseNumber: json['house_number'],
      addressLine2: json['address_line2'],
      reference: json['reference'],
      postalCode: json['postal_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      status: json['status'] ?? 'notverified',
      isDefault: json['is_default'] ?? false,
      cityName: json['city_name'],
      stateName: json['state_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'city_id': cityId,
      'street': street,
      'house_number': houseNumber,
      'address_line2': addressLine2,
      'reference': reference,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'is_default': isDefault,
    };
  }

  AddressModel copyWith({
    int? id,
    int? profileId,
    int? cityId,
    String? street,
    String? houseNumber,
    String? addressLine2,
    String? reference,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? status,
    bool? isDefault,
    String? cityName,
    String? stateName,
  }) {
    return AddressModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      cityId: cityId ?? this.cityId,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      addressLine2: addressLine2 ?? this.addressLine2,
      reference: reference ?? this.reference,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      isDefault: isDefault ?? this.isDefault,
      cityName: cityName ?? this.cityName,
      stateName: stateName ?? this.stateName,
    );
  }
}
