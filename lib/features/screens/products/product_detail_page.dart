import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/services/cart_service.dart';
import 'package:zonix/models/product.dart';
import 'package:zonix/models/cart_item.dart';
import 'package:zonix/models/restaurant.dart';
import 'package:zonix/features/services/restaurant_service.dart';
import 'package:zonix/features/screens/restaurants/restaurant_details_page.dart';
import 'package:zonix/features/utils/network_image_with_fallback.dart';
import 'package:logger/logger.dart';

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

class ProductDetailPage extends StatefulWidget {
  final Product product;
  
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final Logger logger = Logger();
  int _quantity = 1;
  bool _isLoading = false;
  late Future<Restaurant?> _restaurantFuture;
  Restaurant? _restaurant;

  @override
  void initState() {
    super.initState();
    _restaurantFuture = _loadRestaurant();
  }

  Future<Restaurant?> _loadRestaurant() async {
    if (widget.product.commerceId == null) return null;
    
    try {
      final restaurantService = RestaurantService();
      return await restaurantService.fetchRestaurantDetails2(widget.product.commerceId!);
    } catch (e, stack) {
      logger.e('Error loading restaurant', error: e, stackTrace: stack);
      return null;
    }
  }

  void _navigateToRestaurant() async {
    if (_restaurant == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailsPage(
            commerceId: _restaurant!.id,
            nombreLocal: _restaurant!.nombreLocal,
            direccion: _restaurant!.direccion ?? '',
            telefono: _restaurant!.telefono ?? '',
            abierto: _restaurant!.abierto ?? false,
            horario: _restaurant!.horario,
            logoUrl: _restaurant!.logoUrl,
          ),
        ),
      );
    } catch (e) {
      logger.e('Navigation error', error: e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final double total = (widget.product.price) * _quantity;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.darkGray
          : ZonixColors.lightGray,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ZonixColors.darkGray
            : ZonixColors.primaryBlue,
        elevation: 0,
        title: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isTablet = screenWidth > 600;
            final fontSize = isTablet ? 24.0 : 20.0;
            
            return Text(
              'Detalles del producto',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
                letterSpacing: 0.5,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
              children: [
                Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ZonixColors.darkGray
                      : ZonixColors.white,
                  shadowColor: ZonixColors.primaryBlue.withOpacity(0.15),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: _buildProductImage(),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ZonixColors.darkGray
                      : ZonixColors.white,
                  shadowColor: ZonixColors.primaryBlue.withOpacity(0.15),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildProductInfo(total, context),
                  ),
                ),
              ],
            ),
            _buildBottomControls(cartService, context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ProductImage(
      imageUrl: widget.product.image,
      productName: widget.product.name,
      width: double.infinity,
      height: 250,
      borderRadius: BorderRadius.circular(16),
    );
  }



  Widget _buildProductInfo(double total, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ZonixColors.white
                      : ZonixColors.darkGray,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              _buildRestaurantInfo(context),
              const SizedBox(height: 8),
              _buildDescription(context),
            ],
          ),
        ),
        _buildPrice(total, context),
      ],
    );
  }

  Widget _buildRestaurantInfo(BuildContext context) {
    return FutureBuilder<Restaurant?>(
      future: _restaurantFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Text(
            'Tienda no disponible',
            style: TextStyle(
              color: ZonixColors.mediumGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          );
        }

        _restaurant = snapshot.data;
        
        return GestureDetector(
          onTap: _isLoading ? null : _navigateToRestaurant,
          child: Text(
            _restaurant?.nombreLocal ?? 'Tienda desconocida',
            style: TextStyle(
              color: ZonixColors.primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark
                ? ZonixColors.white
                : ZonixColors.darkGray,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.product.description ?? 'Sin descripción',
          style: TextStyle(
            fontSize: 16, 
            color: ZonixColors.mediumGray,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPrice(double total, BuildContext context) {
    return Text(
      '\u20a1${total.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: ZonixColors.successGreen,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildBottomControls(CartService cartService, BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            _buildQuantitySelector(context),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZonixColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: ZonixColors.primaryBlue.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  cartService.addToCart(CartItem(
                    id: widget.product.id,
                    nombre: widget.product.name,
                    precio: widget.product.price,
                    quantity: _quantity,
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Producto añadido al carrito'),
                      backgroundColor: ZonixColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add_shopping_cart, 
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Añadir al carrito', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ZonixColors.darkGray
            : ZonixColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ZonixColors.mediumGray.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ZonixColors.primaryBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove, 
              color: _quantity > 1 
                  ? ZonixColors.primaryBlue 
                  : ZonixColors.mediumGray,
            ),
            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$_quantity', 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ZonixColors.white
                    : ZonixColors.darkGray,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add, 
              color: ZonixColors.primaryBlue,
            ),
            onPressed: () => setState(() => _quantity++),
          ),
        ],
      ),
    );
  }

}