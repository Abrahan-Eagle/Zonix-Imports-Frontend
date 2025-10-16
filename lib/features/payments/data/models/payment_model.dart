class PaymentModel {
  final int id;
  final int orderId;
  final String method;
  final double amount;
  final String status;
  final String? reference;
  final String? externalId;
  final String currency;
  final String? processedAt;
  final String? receiptUrl;
  final String? failureReason;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amount,
    required this.status,
    this.reference,
    this.externalId,
    required this.currency,
    this.processedAt,
    this.receiptUrl,
    this.failureReason,
    this.metadata,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int? ?? 0,
      method: json['method'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      reference: json['reference'] as String?,
      externalId: json['external_id'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      processedAt: json['processed_at'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      failureReason: json['failure_reason'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'method': method,
      'amount': amount,
      'status': status,
      if (reference != null) 'reference': reference,
      if (externalId != null) 'external_id': externalId,
      'currency': currency,
      if (processedAt != null) 'processed_at': processedAt,
      if (receiptUrl != null) 'receipt_url': receiptUrl,
      if (failureReason != null) 'failure_reason': failureReason,
      if (metadata != null) 'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'succeeded':
        return 'Exitoso';
      case 'failed':
        return 'Fallido';
      case 'refunded':
        return 'Reembolsado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String get methodLabel {
    switch (method) {
      case 'stripe':
        return 'Tarjeta';
      case 'paypal':
        return 'PayPal';
      case 'binance':
        return 'Binance Pay';
      case 'pago_movil':
        return 'Pago Móvil';
      case 'zelle':
        return 'Zelle';
      default:
        return method;
    }
  }

  String get amountFormatted {
    return '\$${amount.toStringAsFixed(2)}';
  }

  bool get isPending {
    return status == 'pending';
  }

  bool get isSucceeded {
    return status == 'succeeded';
  }

  bool get isFailed {
    return status == 'failed';
  }

  bool get isRefunded {
    return status == 'refunded';
  }

  bool get isManual {
    return method == 'pago_movil' || method == 'zelle';
  }
}

