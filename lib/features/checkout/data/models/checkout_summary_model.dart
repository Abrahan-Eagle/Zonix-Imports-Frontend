class CheckoutSummaryModel {
  final double subtotal;
  final double shipping;
  final double discount;
  final double total;
  final int itemsCount;

  CheckoutSummaryModel({
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.itemsCount,
  });

  factory CheckoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return CheckoutSummaryModel(
      subtotal: (json['subtotal'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      itemsCount: json['items_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'shipping': shipping,
      'discount': discount,
      'total': total,
      'items_count': itemsCount,
    };
  }

  bool get hasDiscount {
    return discount > 0;
  }

  bool get isEmpty {
    return itemsCount == 0;
  }

  String get subtotalFormatted {
    return '\$${subtotal.toStringAsFixed(2)}';
  }

  String get shippingFormatted {
    return '\$${shipping.toStringAsFixed(2)}';
  }

  String get discountFormatted {
    return '-\$${discount.toStringAsFixed(2)}';
  }

  String get totalFormatted {
    return '\$${total.toStringAsFixed(2)}';
  }

  bool get hasFreeShipping {
    return shipping == 0;
  }

  String get shippingLabel {
    if (hasFreeShipping) {
      return 'Gratis';
    }
    return shippingFormatted;
  }
}

