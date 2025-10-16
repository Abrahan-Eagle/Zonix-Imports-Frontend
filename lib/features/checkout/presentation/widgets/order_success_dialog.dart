import 'package:flutter/material.dart';
import 'package:zonix/features/checkout/data/models/order_model.dart';

class OrderSuccessDialog extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onViewOrder;
  final VoidCallback onContinueShopping;

  const OrderSuccessDialog({
    super.key,
    required this.order,
    required this.onViewOrder,
    required this.onContinueShopping,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon de éxito
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            // Título
            const Text(
              '¡Orden Creada!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Número de orden
            Text(
              order.orderNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            // Información
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Estado', order.statusLabel),
                  const Divider(height: 16),
                  _buildInfoRow('Total', order.totalFormatted),
                  if (order.estimatedDelivery != null) ...[
                    const Divider(height: 16),
                    _buildInfoRow('Entrega estimada', order.estimatedDelivery!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onContinueShopping,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Seguir Comprando'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Ver Orden'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

