class CommerceModel {
  final int? id;
  final int profileId;
  final String? businessName;
  final String? businessType;
  final String? image;
  final String? phone;
  final String? rif;
  final String? bankAccount;
  final bool isVerified;
  final bool open;
  final List<String>? paymentMethods; // ['stripe', 'paypal', 'pago_movil']
  final Map<String, dynamic>? schedule;

  CommerceModel({
    this.id,
    required this.profileId,
    this.businessName,
    this.businessType,
    this.image,
    this.phone,
    this.rif,
    this.bankAccount,
    this.isVerified = false,
    this.open = true,
    this.paymentMethods,
    this.schedule,
  });

  factory CommerceModel.fromJson(Map<String, dynamic> json) {
    return CommerceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      profileId: json['profile_id'] is int
          ? json['profile_id']
          : int.parse(json['profile_id'].toString()),
      businessName: json['business_name'],
      businessType: json['business_type'],
      image: json['image'],
      phone: json['phone'],
      rif: json['rif'],
      bankAccount: json['bank_account'],
      isVerified: json['is_verified'] ?? false,
      open: json['open'] ?? true,
      paymentMethods: json['payment_methods'] != null
          ? List<String>.from(json['payment_methods'])
          : null,
      schedule: json['schedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'business_name': businessName,
      'business_type': businessType,
      'image': image,
      'phone': phone,
      'rif': rif,
      'bank_account': bankAccount,
      'is_verified': isVerified,
      'open': open,
      'payment_methods': paymentMethods,
      'schedule': schedule,
    };
  }

  CommerceModel copyWith({
    int? id,
    int? profileId,
    String? businessName,
    String? businessType,
    String? image,
    String? phone,
    String? rif,
    String? bankAccount,
    bool? isVerified,
    bool? open,
    List<String>? paymentMethods,
    Map<String, dynamic>? schedule,
  }) {
    return CommerceModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      rif: rif ?? this.rif,
      bankAccount: bankAccount ?? this.bankAccount,
      isVerified: isVerified ?? this.isVerified,
      open: open ?? this.open,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      schedule: schedule ?? this.schedule,
    );
  }
}
