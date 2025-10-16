import 'package:flutter/material.dart';
import '../../data/models/cart_summary_model.dart';

class CartSummaryWidget extends StatelessWidget {
  final CartSummaryModel summary;
  final VoidCallback onCheckout;

  const CartSummaryWidget({
    super.key,
    required this.summary,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow('Subtotal (${summary.itemsCount} items)', summary.subtotalFormatted),
            _buildRow('Envío', summary.shippingFormatted),
            if (summary.hasDiscount)
              _buildRow('Descuento', '-${summary.discountFormatted}', color: Colors.green),
            const Divider(height: 24),
            _buildRow('Total', summary.totalFormatted, isBold: true, fontSize: 20),
            const SizedBox(height: 16),

            // Botón checkout
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onCheckout,
                icon: const Icon(Icons.payment),
                label: const Text(
                  'Continuar al Pago',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {
    bool isBold = false,
    double fontSize = 16,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: color ?? const Color(0xFF1E40AF),
            ),
          ),
        ],
      ),
    );
  }
}

