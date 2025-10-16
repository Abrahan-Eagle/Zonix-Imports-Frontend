import 'package:zonix/features/checkout/data/models/address_model.dart';
import 'package:zonix/features/products/data/models/product_model.dart';

class OrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final String modality;
  final String deliveryType;
  final double subtotal;
  final double discountTotal;
  final double shippingTotal;
  final double total;
  final String? estimatedDelivery;
  final AddressModel? shippingAddress;
  final AddressModel? billingAddress;
  final CommerceMinimal? commerce;
  final List<OrderItemModel> items;
  final String? notes;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.modality,
    required this.deliveryType,
    required this.subtotal,
    required this.discountTotal,
    required this.shippingTotal,
    required this.total,
    this.estimatedDelivery,
    this.shippingAddress,
    this.billingAddress,
    this.commerce,
    required this.items,
    this.notes,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      modality: json['modality'] as String,
      deliveryType: json['delivery_type'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      discountTotal: (json['discount_total'] as num).toDouble(),
      shippingTotal: (json['shipping_total'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      estimatedDelivery: json['estimated_delivery'] as String?,
      shippingAddress: json['shipping_address'] != null
          ? AddressModel.fromJson(json['shipping_address'] as Map<String, dynamic>)
          : null,
      billingAddress: json['billing_address'] != null
          ? AddressModel.fromJson(json['billing_address'] as Map<String, dynamic>)
          : null,
      commerce: json['commerce'] != null
          ? CommerceMinimal.fromJson(json['commerce'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'modality': modality,
      'delivery_type': deliveryType,
      'subtotal': subtotal,
      'discount_total': discountTotal,
      'shipping_total': shippingTotal,
      'total': total,
      'estimated_delivery': estimatedDelivery,
      if (shippingAddress != null) 'shipping_address': shippingAddress!.toJson(),
      if (billingAddress != null) 'billing_address': billingAddress!.toJson(),
      if (commerce != null) 'commerce': commerce!.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending_payment':
        return 'Pendiente de Pago';
      case 'partially_paid':
        return 'Parcialmente Pagado';
      case 'paid':
        return 'Pagado';
      case 'preparing':
        return 'Preparando';
      case 'on_way':
        return 'En Camino';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String get deliveryTypeLabel {
    return deliveryType == 'pickup' ? 'Retiro en Tienda' : 'Envío a Domicilio';
  }

  String get totalFormatted {
    return '\$${total.toStringAsFixed(2)}';
  }

  bool get isPendingPayment {
    return status == 'pending_payment';
  }

  bool get isDelivered {
    return status == 'delivered';
  }

  bool get isCancelled {
    return status == 'cancelled';
  }
}

class OrderItemModel {
  final int id;
  final ProductMinimal product;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      product: ProductMinimal.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }
}

class ProductMinimal {
  final int id;
  final String name;
  final String? image;

  ProductMinimal({
    required this.id,
    required this.name,
    this.image,
  });

  factory ProductMinimal.fromJson(Map<String, dynamic> json) {
    return ProductMinimal(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (image != null) 'image': image,
    };
  }
}

class CommerceMinimal {
  final int id;
  final String name;

  CommerceMinimal({
    required this.id,
    required this.name,
  });

  factory CommerceMinimal.fromJson(Map<String, dynamic> json) {
    return CommerceMinimal(
      id: json['id'] as int,
      name: json['name'] as String? ?? json['business_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

