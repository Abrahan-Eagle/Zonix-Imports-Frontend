import 'package:flutter/material.dart';
import 'package:zonix/features/checkout/data/models/checkout_summary_model.dart';
import 'package:zonix/features/cart/data/models/cart_item_model.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final List<CartItemModel> items;
  final CheckoutSummaryModel summary;
  final String deliveryType;

  const CheckoutOrderSummary({
    super.key,
    required this.items,
    required this.summary,
    required this.deliveryType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Pedido',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Items
            ...items.map((item) => _buildItemRow(context, item)),
            const Divider(height: 24),
            // Totales
            _buildTotalRow(
              context,
              'Subtotal',
              summary.subtotalFormatted,
              isRegular: true,
            ),
            if (deliveryType == 'delivery') ...[
              const SizedBox(height: 8),
              _buildTotalRow(
                context,
                'Envío',
                summary.hasFreeShipping ? 'Gratis' : summary.shippingFormatted,
                isRegular: true,
                color: summary.hasFreeShipping ? Colors.green : null,
              ),
            ],
            if (summary.hasDiscount) ...[
              const SizedBox(height: 8),
              _buildTotalRow(
                context,
                'Descuento',
                summary.discountFormatted,
                isRegular: true,
                color: Colors.green,
              ),
            ],
            const Divider(height: 24),
            _buildTotalRow(
              context,
              'Total',
              summary.totalFormatted,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '${item.quantity}x',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.product.name,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    String value, {
    bool isRegular = false,
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 20 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isBold ? Theme.of(context).primaryColor : null),
          ),
        ),
      ],
    );
  }
}

