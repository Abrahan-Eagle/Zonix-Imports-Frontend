import 'package:flutter/material.dart';
import 'package:zonix/features/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/screens/cart/checkout_page.dart';
import 'package:zonix/models/cart_item.dart';

// Paleta de colores profesional
class ZonixColors {
  static const Color primaryBlue = Color(0xFF1E40AF); // Azul profesional
  static const Color secondaryBlue = Color(0xFF3B82F6); // Azul secundario
  static const Color accentBlue = Color(0xFF60A5FA); // Azul de acento
  static const Color darkGray = Color(0xFF1E293B); // Gris oscuro
  static const Color mediumGray = Color(0xFF64748B); // Gris medio
  static const Color lightGray = Color(0xFFF1F5F9); // Gris claro
  static const Color white = Color(0xFFFFFFFF); // Blanco
  static const Color successGreen = Color(0xFF10B981); // Verde éxito
  static const Color warningOrange = Color(0xFFF59E0B); // Naranja advertencia
  static const Color errorRed = Color(0xFFEF4444); // Rojo error
  
  // Colores adicionales para efectos modernos
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color neumorphicLight = Color(0xFFFFFFFF);
  static const Color neumorphicDark = Color(0xFFE0E0E0);
}

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final cartItems = cartService.items;
    final total = cartItems.fold<double>(0, (sum, item) => sum + (item.precio ?? 0) * item.quantity);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ZonixColors.darkGray
            : ZonixColors.lightGray,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    width: double.infinity,
                    child: Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final isTablet = screenWidth > 600;
                        final fontSize = isTablet ? 28.0 : 24.0;
                        
                        return Text(
                          'Carrito',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? ZonixColors.white
                                : ZonixColors.darkGray,
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(1, 0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, right: 24),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ZonixColors.darkGray
                              : ZonixColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: ZonixColors.mediumGray.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: ZonixColors.primaryBlue.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.notifications_none, 
                          size: 24, 
                          color: ZonixColors.mediumGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: ZonixColors.mediumGray.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'El carrito está vacío',
                              style: TextStyle(
                                color: ZonixColors.mediumGray,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Agrega productos para comenzar',
                              style: TextStyle(
                                color: ZonixColors.mediumGray.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: Card(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? ZonixColors.darkGray
                                  : ZonixColors.white,
                              shadowColor: ZonixColors.primaryBlue.withOpacity(0.15),
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        color: ZonixColors.lightGray,
                                        width: 80,
                                        height: 80,
                                        child: Icon(
                                          Icons.shopping_bag, 
                                          size: 40, 
                                          color: ZonixColors.mediumGray.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.nombre,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? ZonixColors.white
                                                  : ZonixColors.darkGray,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Cantidad: ${item.quantity}',
                                            style: TextStyle(
                                              fontSize: 15, 
                                              color: ZonixColors.mediumGray,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '\u20a1${item.precio?.toStringAsFixed(2) ?? '-'}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: ZonixColors.successGreen,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  cartService.decrementQuantity(item);
                                                },
                                                borderRadius: BorderRadius.circular(15),
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: ZonixColors.mediumGray,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: ZonixColors.mediumGray.withOpacity(0.3),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.remove_sharp, 
                                                    size: 18, 
                                                    color: ZonixColors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                '${item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 18, 
                                                  fontWeight: FontWeight.w600, 
                                                  color: Theme.of(context).brightness == Brightness.dark
                                                      ? ZonixColors.white
                                                      : ZonixColors.darkGray,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              InkWell(
                                                onTap: () {
                                                  cartService.removeFromCart(item);
                                                  cartService.addToCart(CartItem(
                                                    id: item.id,
                                                    nombre: item.nombre,
                                                    precio: item.precio,
                                                    quantity: item.quantity + 1,
                                                  ));
                                                },
                                                borderRadius: BorderRadius.circular(15),
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: ZonixColors.primaryBlue,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: ZonixColors.primaryBlue.withOpacity(0.3),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.add, 
                                                    color: ZonixColors.white, 
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete, 
                                                  color: ZonixColors.errorRed,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  cartService.removeFromCart(item);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: const Text('Producto eliminado del carrito'),
                                                      backgroundColor: ZonixColors.errorRed,
                                                      behavior: SnackBarBehavior.floating,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (cartItems.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                  child: Text(
                    'Resumen de orden',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w700, 
                      color: Theme.of(context).brightness == Brightness.dark
                          ? ZonixColors.white
                          : ZonixColors.darkGray,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total Items:',
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.w600, 
                                color: ZonixColors.mediumGray,
                              ),
                            ),
                          ),
                          Text(
                            '${cartItems.length}',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.w700, 
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? ZonixColors.white
                                  : ZonixColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(
                        height: 0.1, 
                        thickness: 1, 
                        color: ZonixColors.mediumGray.withOpacity(0.2),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total a pagar:',
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.w700, 
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? ZonixColors.white
                                    : ZonixColors.darkGray,
                              ),
                            ),
                          ),
                          Text(
                            '\u20a1${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.w700, 
                              color: ZonixColors.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: cartItems.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(24, 13, 24, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZonixColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: ZonixColors.primaryBlue.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CheckoutPage()),
                      );
                    },
                    icon: const Icon(
                      Icons.payment, 
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'Proceder al pago', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
