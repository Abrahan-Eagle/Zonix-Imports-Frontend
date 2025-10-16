class CartSummaryModel {
  final int itemsCount;
  final double subtotal;
  final double shipping;
  final double discount;
  final double total;

  CartSummaryModel({
    required this.itemsCount,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.total,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      itemsCount: json['items_count'] ?? 0,
      subtotal: double.parse(json['subtotal']?.toString() ?? '0'),
      shipping: double.parse(json['shipping']?.toString() ?? '0'),
      discount: double.parse(json['discount']?.toString() ?? '0'),
      total: double.parse(json['total']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items_count': itemsCount,
      'subtotal': subtotal,
      'shipping': shipping,
      'discount': discount,
      'total': total,
    };
  }

  bool get hasDiscount => discount > 0;
  bool get hasShipping => shipping > 0;
  bool get isEmpty => itemsCount == 0;

  String get totalFormatted => '\$${total.toStringAsFixed(2)}';
  String get subtotalFormatted => '\$${subtotal.toStringAsFixed(2)}';
  String get shippingFormatted => '\$${shipping.toStringAsFixed(2)}';
  String get discountFormatted => '\$${discount.toStringAsFixed(2)}';
}

