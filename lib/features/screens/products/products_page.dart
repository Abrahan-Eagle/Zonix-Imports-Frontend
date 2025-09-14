import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/services/cart_service.dart';
import 'package:zonix/features/services/product_service.dart';
import 'package:zonix/models/product.dart';
import 'package:zonix/models/cart_item.dart';
import 'package:zonix/features/utils/network_image_with_fallback.dart';
import 'product_detail_page.dart';

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

class ProductsPage extends StatefulWidget {
  final ProductService? productService;
  const ProductsPage({Key? key, this.productService}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = (widget.productService ?? ProductService()).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.darkGray
          : ZonixColors.lightGray,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eliminar dropdown de categorías
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            //   child: _loadingCategories
            //       ? const LinearProgressIndicator()
            //       : DropdownButtonFormField<int>(
            //           value: _selectedCategoryId,
            //           items: [
            //             const DropdownMenuItem<int>(value: null, child: Text('Todas las categorías')),
            //             ..._categories.map((cat) => DropdownMenuItem<int>(
            //                   value: cat['id'],
            //                   child: Text(cat['name']),
            //                 ))
            //           ],
            //           onChanged: (value) {
            //             setState(() {
            //               _selectedCategoryId = value;
            //               _loadProducts();
            //             });
            //           },
            //           decoration: const InputDecoration(labelText: 'Filtrar por categoría'),
            //         ),
            // ),
          
            // Listado de productos en grid moderno
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: ZonixColors.primaryBlue,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Cargando productos...',
                            style: TextStyle(
                              color: ZonixColors.mediumGray,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline, 
                            color: ZonixColors.errorRed, 
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar productos',
                            style: TextStyle(
                              color: ZonixColors.darkGray,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(
                              color: ZonixColors.mediumGray,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _productsFuture = (widget.productService ?? ProductService()).fetchProducts();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ZonixColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: ZonixColors.mediumGray.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay productos disponibles',
                            style: TextStyle(
                              color: ZonixColors.mediumGray,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vuelve más tarde para ver nuevos productos',
                            style: TextStyle(
                              color: ZonixColors.mediumGray.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final products = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 11, 24, 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.85, // Ajustado para más alto
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? ZonixColors.darkGray
                                : ZonixColors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12,
                                color: ZonixColors.primaryBlue.withOpacity(0.1),
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ProductImage(
                                    imageUrl: product.image,
                                    productName: product.name,
                                    width: double.infinity,
                                    height: 90,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? ZonixColors.white
                                          : ZonixColors.darkGray,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '\u20a1${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.w700,
                                    color: ZonixColors.successGreen,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: ZonixColors.primaryBlue,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: ZonixColors.primaryBlue.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.add_shopping_cart, 
                                        color: Colors.white, 
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        cartService.addToCart(CartItem(
                                          id: product.id,
                                          nombre: product.name,
                                          precio: product.price,
                                          quantity: 1,
                                        ));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Producto agregado al carrito'),
                                            backgroundColor: ZonixColors.successGreen,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
