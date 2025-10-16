class StoreModel {
  final int id;
  final int profileId;
  final String businessName;
  final String? businessType;
  final String? image;
  final String? phone;
  final String? rif;
  final String? bankAccount;
  final bool isVerified;
  final bool open;
  final List<String>? paymentMethods;
  final Map<String, dynamic>? schedule;
  final int? productsCount;
  final Map<String, dynamic>? statistics;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StoreModel({
    required this.id,
    required this.profileId,
    required this.businessName,
    this.businessType,
    this.image,
    this.phone,
    this.rif,
    this.bankAccount,
    required this.isVerified,
    required this.open,
    this.paymentMethods,
    this.schedule,
    this.productsCount,
    this.statistics,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? 0,
      profileId: json['profile_id'] ?? 0,
      businessName: json['business_name'] ?? '',
      businessType: json['business_type'],
      image: json['image'],
      phone: json['phone'],
      rif: json['rif'],
      bankAccount: json['bank_account'],
      isVerified: json['is_verified'] ?? false,
      open: json['open'] ?? false,
      paymentMethods: json['payment_methods'] != null
          ? List<String>.from(json['payment_methods'])
          : null,
      schedule: json['schedule'],
      productsCount: json['products_count'],
      statistics: json['statistics'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
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
      'products_count': productsCount,
      'statistics': statistics,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helpers
  String get displayName => businessName;

  String get statusText => open ? 'Abierta' : 'Cerrada';

  String get businessTypeLabel {
    switch (businessType) {
      case 'retail':
        return 'Al Detal';
      case 'wholesale':
        return 'Mayorista';
      case 'both':
        return 'Detal y Mayor';
      case 'dropshipping':
        return 'Dropshipping';
      case 'preorder':
        return 'Pre-órdenes';
      default:
        return 'General';
    }
  }

  String? get imageUrl {
    if (image == null || image!.isEmpty) return null;
    if (image!.startsWith('http')) return image;
    // Si es una ruta relativa, construir URL completa
    return image;
  }
}
