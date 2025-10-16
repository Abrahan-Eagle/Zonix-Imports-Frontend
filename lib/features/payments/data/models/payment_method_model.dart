class PaymentMethodModel {
  final String id;
  final String name;
  final String type;
  final String icon;
  final bool enabled;
  final List<String> currencies;
  final bool? requiresReceipt;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.enabled,
    required this.currencies,
    this.requiresReceipt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      enabled: json['enabled'] as bool? ?? false,
      currencies: (json['currencies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      requiresReceipt: json['requires_receipt'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'enabled': enabled,
      'currencies': currencies,
      if (requiresReceipt != null) 'requires_receipt': requiresReceipt,
    };
  }

  bool get isCard {
    return type == 'card';
  }

  bool get isDigitalWallet {
    return type == 'digital_wallet';
  }

  bool get isCrypto {
    return type == 'crypto';
  }

  bool get isBankTransfer {
    return type == 'bank_transfer';
  }

  bool get isManual {
    return requiresReceipt == true;
  }

  String get currenciesText {
    return currencies.join(', ');
  }
}

