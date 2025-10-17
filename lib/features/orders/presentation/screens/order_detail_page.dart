import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrderDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Pedido'),
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
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
                    'Error al cargar detalle',
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
                    onPressed: () {
                      provider.loadOrderDetails(widget.orderId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.selectedOrder == null) {
            return const Center(
              child: Text('No se encontró el pedido'),
            );
          }

          final order = provider.selectedOrder!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order['order_number'] ?? 'N/A',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildStatusChip(order['status']),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (order['created_at'] != null)
                          Text(
                            'Fecha: ${_formatDate(order['created_at'])}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Items
                _buildSectionTitle('Productos'),
                if (order['items'] != null)
                  ...List.generate(
                    (order['items'] as List).length,
                    (index) {
                      final item = (order['items'] as List)[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: item['product']?['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['product']['image'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image),
                                ),
                          title: Text(
                            item['product']?['name'] ?? 'Producto',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Cantidad: ${item['quantity']} x \$${item['unit_price']}',
                          ),
                          trailing: Text(
                            '\$${item['subtotal']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),

                // Dirección de Envío
                _buildSectionTitle('Dirección de Envío'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order['shipping_address'] != null) ...[
                          Text(
                            order['shipping_address']['street'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${order['shipping_address']['city']}, ${order['shipping_address']['state']}',
                          ),
                          Text(order['shipping_address']['country'] ?? ''),
                        ] else
                          const Text('No especificada'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Resumen de Pago
                _buildSectionTitle('Resumen de Pago'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', '\$${order['subtotal'] ?? '0.00'}'),
                        _buildSummaryRow('Envío', '\$${order['shipping_fee'] ?? '0.00'}'),
                        if (order['discount'] != null && order['discount'] != '0.00')
                          _buildSummaryRow(
                            'Descuento',
                            '-\$${order['discount']}',
                            color: Colors.green,
                          ),
                        const Divider(),
                        _buildSummaryRow(
                          'Total',
                          '\$${order['total']}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pagos
                if (order['payments'] != null && (order['payments'] as List).isNotEmpty) ...[
                  _buildSectionTitle('Pagos'),
                  ...List.generate(
                    (order['payments'] as List).length,
                    (index) {
                      final payment = (order['payments'] as List)[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getPaymentStatusColor(payment['status']),
                            child: Icon(
                              _getPaymentStatusIcon(payment['status']),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            _getPaymentMethodLabel(payment['payment_method']),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${_getPaymentStatusLabel(payment['status'])} - \$${payment['amount']}',
                          ),
                          trailing: Text(
                            payment['currency'] ?? 'USD',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // Botón de Ver Tracking
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navegar a tracking page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ver tracking (próximamente)'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('Ver Tracking del Envío'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    return Chip(
      label: Text(
        _getStatusLabel(status),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: _getStatusColor(status),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
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

  Color _getPaymentStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.money_off;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'completed':
        return 'Completado';
      case 'failed':
        return 'Fallido';
      case 'refunded':
        return 'Reembolsado';
      default:
        return status ?? 'Desconocido';
    }
  }

  String _getPaymentMethodLabel(String? method) {
    switch (method) {
      case 'stripe':
        return 'Stripe (Tarjeta)';
      case 'paypal':
        return 'PayPal';
      case 'binance':
        return 'Binance Pay';
      case 'pago_movil':
        return 'Pago Móvil';
      case 'zelle':
        return 'Zelle';
      default:
        return method ?? 'Método de pago';
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

