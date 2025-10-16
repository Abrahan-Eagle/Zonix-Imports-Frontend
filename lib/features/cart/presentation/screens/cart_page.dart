import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_widget.dart';
import '../widgets/empty_cart_widget.dart';
import '../../data/models/cart_item_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => _showClearCartDialog(context),
                tooltip: 'Limpiar carrito',
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          // Loading
          if (provider.isLoading && provider.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (provider.error != null && provider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadCart(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Empty
          if (provider.isEmpty) {
            return const EmptyCartWidget();
          }

          // Success con items
          return Column(
            children: [
              // Lista de productos
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final item = provider.items[index];
                      return CartItemCard(
                        item: item,
                        onIncrement: () => provider.incrementQuantity(item.id),
                        onDecrement: () => provider.decrementQuantity(item.id),
                        onRemove: () => _showRemoveDialog(context, item),
                      );
                    },
                  ),
                ),
              ),

              // Resumen fijo al fondo
              if (provider.summary != null)
                CartSummaryWidget(
                  summary: provider.summary!,
                  onCheckout: () => _navigateToCheckout(context),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, CartItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${item.product.name}" del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().removeItem(item.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar carrito'),
        content: const Text('¿Eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(BuildContext context) {
    // TODO: Navegar a checkout cuando esté implementado
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checkout próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

