class PhoneModel {
  final int? id;
  final int profileId;
  final String operatorCode; // '0412', '0414', etc.
  final String countryCode; // '+58'
  final String number; // '1234567'
  final bool isPrimary;
  final bool isActive;

  PhoneModel({
    this.id,
    required this.profileId,
    required this.operatorCode,
    required this.countryCode,
    required this.number,
    this.isPrimary = false,
    this.isActive = true,
  });

  // Getter para número completo
  String get fullNumber => '$countryCode $operatorCode-$number';

  factory PhoneModel.fromJson(Map<String, dynamic> json) {
    return PhoneModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      profileId: json['profile_id'] is int
          ? json['profile_id']
          : int.parse(json['profile_id'].toString()),
      operatorCode: json['operator_code'],
      countryCode: json['country_code'] ?? '+58',
      number: json['number'],
      isPrimary: json['is_primary'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'operator_code': operatorCode,
      'country_code': countryCode,
      'number': number,
      'is_primary': isPrimary,
      'is_active': isActive,
    };
  }

  PhoneModel copyWith({
    int? id,
    int? profileId,
    String? operatorCode,
    String? countryCode,
    String? number,
    bool? isPrimary,
    bool? isActive,
  }) {
    return PhoneModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      operatorCode: operatorCode ?? this.operatorCode,
      countryCode: countryCode ?? this.countryCode,
      number: number ?? this.number,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
    );
  }
}
