import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/shared/widgets/custom_card.dart';
import 'package:zonix/shared/widgets/card_header.dart';
import 'package:zonix/shared/widgets/list_item_tile.dart';
import 'package:zonix/shared/widgets/status_badge.dart';

class OrdersCard extends StatelessWidget {
  const OrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos dummy para demostración
    final orders = _getDummyOrders();

    return CustomCard(
      child: Column(
        children: [
          CardHeader(
            title: 'Mis Órdenes',
            action: ElevatedButton(
              onPressed: () => _viewAllOrders(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ver Todo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (orders.isEmpty)
            _buildEmptyState(context)
          else
            ...orders.take(3).map((order) => ListItemTile(
                  title: 'Orden #${order['id']}',
                  subtitle:
                      '${order['products']} productos • \$${order['total']} • ${order['date']}',
                  badge: StatusBadge(
                    text: _getStatusText(order['status']),
                    color: _getStatusColor(order['status']),
                  ),
                  onTap: () => _viewOrder(context, order['id']),
                )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes órdenes',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyOrders() {
    return [
      {
        'id': '1001',
        'products': 3,
        'total': '150.00',
        'date': '15/10/2025',
        'status': 'delivered',
      },
      {
        'id': '1002',
        'products': 1,
        'total': '75.00',
        'date': '20/10/2025',
        'status': 'on_way',
      },
      {
        'id': '1003',
        'products': 2,
        'total': '200.00',
        'date': '22/10/2025',
        'status': 'pending_payment',
      },
    ];
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending_payment':
        return 'Pendiente Pago';
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
        return 'Desconocido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_payment':
        return AppColors.blue;
      case 'paid':
        return AppColors.green;
      case 'preparing':
        return AppColors.orange;
      case 'on_way':
        return AppColors.yellow;
      case 'delivered':
        return AppColors.green;
      case 'cancelled':
        return AppColors.red;
      default:
        return AppColors.gray;
    }
  }

  void _viewAllOrders(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirigiendo a página de órdenes...')),
    );
  }

  void _viewOrder(BuildContext context, String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ver detalle de orden #$orderId')),
    );
  }
}
