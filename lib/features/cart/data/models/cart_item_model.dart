import '../../../products/data/models/product_model.dart';

class CartItemModel {
  final int id;
  final int profileId;
  final ProductModel product;
  final int quantity;
  final String modality;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItemModel({
    required this.id,
    required this.profileId,
    required this.product,
    required this.quantity,
    required this.modality,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      profileId: json['profile_id'] ?? 0,
      product: ProductModel.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      modality: json['modality'] ?? 'retail',
      unitPrice: double.parse(json['unit_price']?.toString() ?? '0'),
      subtotal: double.parse(json['subtotal']?.toString() ?? '0'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'product': product.toJson(),
      'quantity': quantity,
      'modality': modality,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helpers
  bool canIncreaseQuantity() {
    if (modality == 'preorder') return true;
    return quantity < product.stock;
  }

  bool canDecreaseQuantity() {
    if (modality == 'wholesale') {
      return quantity > (product.minWholesaleQuantity ?? 1);
    }
    return quantity > 1;
  }

  String get modalityLabel {
    switch (modality) {
      case 'retail':
        return 'Detal';
      case 'wholesale':
        return 'Mayor';
      case 'preorder':
        return 'Pre-orden';
      case 'referral':
        return 'Referido';
      case 'dropshipping':
        return 'Dropshipping';
      default:
        return modality;
    }
  }

  CartItemModel copyWith({
    int? id,
    int? profileId,
    ProductModel? product,
    int? quantity,
    String? modality,
    double? unitPrice,
    double? subtotal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      modality: modality ?? this.modality,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

