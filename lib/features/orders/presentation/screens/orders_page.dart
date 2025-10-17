import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<OrderProvider>().loadOrders();
        },
        child: Consumer<OrderProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar pedidos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => provider.loadOrders(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (provider.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay pedidos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tus pedidos aparecerán aquí',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Ir a Productos'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(order['status']),
                      child: Icon(
                        _getStatusIcon(order['status']),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      order['order_number'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          _getStatusLabel(order['status']),
                          style: TextStyle(
                            color: _getStatusColor(order['status']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: \$${order['total']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (order['created_at'] != null)
                          Text(
                            _formatDate(order['created_at']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(
                            orderId: order['id'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending_payment':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pending_payment':
        return Icons.payment;
      case 'paid':
        return Icons.check_circle;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
        return Icons.money_off;
      default:
        return Icons.info;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'pending_payment':
        return 'Pago pendiente';
      case 'paid':
        return 'Pagado';
      case 'processing':
        return 'En preparación';
      case 'shipped':
        return 'Enviado';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      case 'refunded':
        return 'Reembolsado';
      default:
        return status ?? 'Desconocido';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

