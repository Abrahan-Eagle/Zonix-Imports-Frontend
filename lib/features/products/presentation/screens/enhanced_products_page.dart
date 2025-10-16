import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../providers/product_provider.dart';
import '../widgets/product_list.dart';
import '../widgets/advanced_filters.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../widgets/breadcrumbs.dart';
import 'product_detail_page.dart';

/// Página principal de productos con filtros y wishlist
class EnhancedProductsPage extends StatefulWidget {
  const EnhancedProductsPage({super.key});

  @override
  State<EnhancedProductsPage> createState() => _EnhancedProductsPageState();
}

class _EnhancedProductsPageState extends State<EnhancedProductsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<CategoryModel> _breadcrumbPath = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      productProvider.refresh();
      productProvider.loadWishlist();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? UIConstants.backgroundDark : UIConstants.grayLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildBreadcrumbs(context, isDark),
            _buildTabBar(context, isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllProductsTab(),
                  _buildFeaturedProductsTab(),
                  _buildWishlistTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, isDark),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context, bool isDark) {
    if (_breadcrumbPath.isEmpty) return const SizedBox.shrink();

    return Breadcrumbs(
      breadcrumbPath: _breadcrumbPath,
      onCategoryTap: (category) {
        // Navegar a categoría específica
        final productProvider = context.read<ProductProvider>();
        productProvider.applyFilters(categoryId: category.id);
        setState(() {
          _breadcrumbPath = [category];
        });
      },
      onHomeTap: () {
        final productProvider = context.read<ProductProvider>();
        productProvider.clearFilters();
        setState(() {
          _breadcrumbPath.clear();
        });
      },
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? UIConstants.cardBgDark : UIConstants.white,
      child: TabBar(
        controller: _tabController,
        labelColor: UIConstants.primaryBlue,
        unselectedLabelColor:
            isDark ? UIConstants.textLight : UIConstants.textSecondary,
        indicatorColor: UIConstants.primaryBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Todos'),
          Tab(text: 'Destacados'),
          Tab(text: 'Favoritos'),
        ],
      ),
    );
  }

  Widget _buildAllProductsTab() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return _buildLoadingState();
        }

        if (productProvider.error != null) {
          return _buildErrorState(productProvider.error!);
        }

        if (productProvider.products.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => productProvider.refresh(),
          child: ProductList(
            products: productProvider.products,
            onProductTap: _navigateToProductDetail,
            onAddToCart: (product) => _addToCart(product),
            onAddToFavorites: (product) => _toggleWishlist(product),
            onLoadMore: productProvider.hasMoreProducts
                ? productProvider.loadMoreProducts
                : null,
            isLoadingMore: productProvider.isLoadingMore,
          ),
        );
      },
    );
  }

  Widget _buildFeaturedProductsTab() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return _buildLoadingState();
        }

        if (productProvider.error != null) {
          return _buildErrorState(productProvider.error!);
        }

        if (productProvider.featuredProducts.isEmpty) {
          return _buildEmptyFeaturedState();
        }

        return RefreshIndicator(
          onRefresh: () => productProvider.loadFeaturedProducts(),
          child: ProductList(
            products: productProvider.featuredProducts,
            onProductTap: _navigateToProductDetail,
            onAddToCart: (product) => _addToCart(product),
            onAddToFavorites: (product) => _toggleWishlist(product),
          ),
        );
      },
    );
  }

  Widget _buildWishlistTab() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.wishlist.isEmpty) {
          return _buildEmptyWishlistState();
        }

        return RefreshIndicator(
          onRefresh: () => productProvider.loadWishlist(),
          child: ProductList(
            products: productProvider.wishlist,
            onProductTap: _navigateToProductDetail,
            onAddToCart: (product) => _addToCart(product),
            onAddToFavorites: (product) => _toggleWishlist(product),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, bool isDark) {
    return FloatingActionButton.extended(
      onPressed: () => _showAdvancedFiltersDialog(context, isDark),
      backgroundColor: UIConstants.primaryBlue,
      foregroundColor: UIConstants.white,
      icon: const Icon(Icons.filter_list),
      label: const Text('Filtros'),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: UIConstants.primaryBlue),
          SizedBox(height: UIConstants.spacingMD),
          Text('Cargando productos...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: UIConstants.iconSizeXL,
              color: UIConstants.error,
            ),
            const SizedBox(height: UIConstants.spacingMD),
            Text(
              'Error al cargar productos',
              style: TextStyle(
                fontSize: UIConstants.fontSizeLG,
                fontWeight: UIConstants.fontWeightBold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSM),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: UIConstants.textSecondary,
              ),
            ),
            const SizedBox(height: UIConstants.spacingLG),
            ElevatedButton(
              onPressed: () {
                final productProvider = context.read<ProductProvider>();
                productProvider.refresh();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: UIConstants.iconSizeXL,
              color: UIConstants.textSecondary,
            ),
            const SizedBox(height: UIConstants.spacingMD),
            Text(
              'No hay productos disponibles',
              style: TextStyle(
                fontSize: UIConstants.fontSizeLG,
                fontWeight: UIConstants.fontWeightBold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSM),
            const Text(
              'Intenta ajustar los filtros o busca algo diferente',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFeaturedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: UIConstants.iconSizeXL,
              color: UIConstants.textSecondary,
            ),
            const SizedBox(height: UIConstants.spacingMD),
            Text(
              'No hay productos destacados',
              style: TextStyle(
                fontSize: UIConstants.fontSizeLG,
                fontWeight: UIConstants.fontWeightBold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSM),
            const Text(
              'Los productos destacados aparecerán aquí cuando estén disponibles',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWishlistState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: UIConstants.iconSizeXL,
              color: UIConstants.textSecondary,
            ),
            const SizedBox(height: UIConstants.spacingMD),
            Text(
              'Tu lista de deseos está vacía',
              style: TextStyle(
                fontSize: UIConstants.fontSizeLG,
                fontWeight: UIConstants.fontWeightBold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSM),
            const Text(
              'Agrega productos a tu lista de deseos tocando el corazón',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAdvancedFiltersDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFilters(
        onClose: () => Navigator.pop(context),
        onApply: () {
          Navigator.pop(context);
          final productProvider = context.read<ProductProvider>();
          productProvider.refresh();
        },
      ),
    );
  }

  void _navigateToProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  Future<void> _toggleWishlist(ProductModel product) async {
    final productProvider = context.read<ProductProvider>();
    final success = await productProvider.toggleWishlist(product);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Producto ${productProvider.wishlist.any((p) => p.id == product.id) ? "agregado a" : "removido de"} favoritos'
                : 'Error al actualizar favoritos',
          ),
          backgroundColor: success ? UIConstants.success : UIConstants.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    // Mostrar dialog para seleccionar modalidad y cantidad
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddToCartDialog(product: product),
    );

    if (result != null) {
      final cartProvider = context.read<CartProvider>();
      final success = await cartProvider.addItem(
        productId: product.id,
        quantity: result['quantity'] as int,
        modality: result['modality'] as String,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '${product.name} agregado al carrito'
                  : cartProvider.error ?? 'Error al agregar al carrito',
            ),
            backgroundColor: success ? UIConstants.success : UIConstants.error,
            duration: const Duration(seconds: 2),
            action: success
                ? SnackBarAction(
                    label: 'Ver Carrito',
                    textColor: Colors.white,
                    onPressed: () {
                      // Cambiar a tab del carrito (index 1)
                      DefaultTabController.of(context).animateTo(0);
                      // Nota: necesitarás ajustar según tu navegación
                    },
                  )
                : null,
          ),
        );
      }
    }
  }
}

/// Dialog para agregar producto al carrito
class _AddToCartDialog extends StatefulWidget {
  final ProductModel product;

  const _AddToCartDialog({required this.product});

  @override
  State<_AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<_AddToCartDialog> {
  int _quantity = 1;
  String _modality = 'retail';

  @override
  Widget build(BuildContext context) {
    final minQuantity = _modality == 'wholesale' 
        ? (widget.product.minWholesaleQuantity ?? 1) 
        : 1;
    
    // Asegurar que la cantidad sea al menos la mínima
    if (_quantity < minQuantity) {
      _quantity = minQuantity;
    }

    return AlertDialog(
      title: const Text('Agregar al Carrito'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del producto
            Text(
              widget.product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Selector de modalidad
            const Text('Modalidad:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _modality,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _getAvailableModalities(),
              onChanged: (value) {
                setState(() {
                  _modality = value!;
                  // Ajustar cantidad si cambió a mayorista
                  if (_modality == 'wholesale') {
                    final min = widget.product.minWholesaleQuantity ?? 1;
                    if (_quantity < min) {
                      _quantity = min;
                    }
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Información de precio
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Precio:'),
                  Text(
                    '\$${_getCurrentPrice().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selector de cantidad
            const Text('Cantidad:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _quantity > minQuantity
                      ? () => setState(() => _quantity--)
                      : null,
                ),
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _quantity < widget.product.stock
                      ? () => setState(() => _quantity++)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock: ${widget.product.stock}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            if (_modality == 'wholesale' && widget.product.minWholesaleQuantity != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Cantidad mínima: ${widget.product.minWholesaleQuantity}',
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ),

            const SizedBox(height: 16),

            // Subtotal
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '\$${(_getCurrentPrice() * _quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context, {
              'quantity': _quantity,
              'modality': _modality,
            });
          },
          icon: const Icon(Icons.shopping_cart),
          label: const Text('Agregar'),
        ),
      ],
    );
  }

  double _getCurrentPrice() {
    if (_modality == 'wholesale' && widget.product.wholesalePrice != null) {
      return widget.product.wholesalePrice!;
    }
    return widget.product.basePrice;
  }

  List<DropdownMenuItem<String>> _getAvailableModalities() {
    final items = <DropdownMenuItem<String>>[];

    // Retail siempre disponible
    items.add(const DropdownMenuItem(
      value: 'retail',
      child: Text('🔵 Detal'),
    ));

    // Wholesale si está configurado
    if (widget.product.wholesalePrice != null) {
      items.add(const DropdownMenuItem(
        value: 'wholesale',
        child: Text('🟢 Mayor'),
      ));
    }

    // Preorder si está configurado
    if (widget.product.modality == 'preorder') {
      items.add(const DropdownMenuItem(
        value: 'preorder',
        child: Text('🟠 Pre-orden'),
      ));
    }

    return items;
  }
}
