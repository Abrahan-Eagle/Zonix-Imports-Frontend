import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/product_list.dart';

/// Página de detalle de un producto
class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _imagePageController;
  int _currentImageIndex = 0;
  int _selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _imagePageController = PageController();
    
    // Cargar productos relacionados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      productProvider.loadRelatedProducts(widget.product.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.grayLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProductInfo(),
                _buildProductDetails(),
                _buildRelatedProducts(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: UIConstants.white,
      foregroundColor: UIConstants.textPrimary,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImageCarousel(),
      ),
      actions: [
        IconButton(
          onPressed: _shareProduct,
          icon: const Icon(Icons.share),
        ),
        IconButton(
          onPressed: _toggleFavorite,
          icon: const Icon(Icons.favorite_border),
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.product.allImages;
    
    if (images.isEmpty) {
      return Container(
        color: UIConstants.grayLight,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: UIConstants.iconSizeXL,
            color: UIConstants.gray,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _imagePageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Image.network(
              images[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: UIConstants.grayLight,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: UIConstants.grayLight,
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: UIConstants.iconSizeXL,
                  color: UIConstants.error,
                ),
              ),
            );
          },
        ),
        
        // Indicadores de página
        if (images.length > 1)
          Positioned(
            bottom: UIConstants.spacingMD,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? UIConstants.white
                        : UIConstants.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Container(
      color: UIConstants.white,
      padding: const EdgeInsets.all(UIConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del producto
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: UIConstants.fontSizeTitle,
              fontWeight: UIConstants.fontWeightBold,
              color: UIConstants.textPrimary,
            ),
          ),
          
          const SizedBox(height: UIConstants.spacingSM),
          
          // Marca y SKU
          Row(
            children: [
              Text(
                widget.product.brand,
                style: const TextStyle(
                  fontSize: UIConstants.fontSizeMD,
                  color: UIConstants.textSecondary,
                  fontWeight: UIConstants.fontWeightMedium,
                ),
              ),
              const SizedBox(width: UIConstants.spacingMD),
              Text(
                'SKU: ${widget.product.sku}',
                style: const TextStyle(
                  fontSize: UIConstants.fontSizeSM,
                  color: UIConstants.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: UIConstants.spacingMD),
          
          // Precio
          _buildPriceSection(),
          
          const SizedBox(height: UIConstants.spacingMD),
          
          // Rating y reviews
          if (widget.product.rating != null)
            Row(
              children: [
                _buildRatingStars(widget.product.rating!),
                const SizedBox(width: UIConstants.spacingSM),
                Text(
                  '(${widget.product.reviewCount ?? 0} reseñas)',
                  style: const TextStyle(
                    color: UIConstants.textSecondary,
                    fontSize: UIConstants.fontSizeSM,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: UIConstants.spacingMD),
          
          // Estado del stock
          _buildStockStatus(),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        // Precio actual
        Text(
          widget.product.formattedDiscountPrice,
          style: const TextStyle(
            fontSize: UIConstants.fontSizeTitle,
            fontWeight: UIConstants.fontWeightBold,
            color: UIConstants.primaryBlue,
          ),
        ),
        
        // Precio original (si hay descuento)
        if (widget.product.hasDiscount) ...[
          const SizedBox(width: UIConstants.spacingSM),
          Text(
            widget.product.formattedPrice,
            style: const TextStyle(
              fontSize: UIConstants.fontSizeMD,
              color: UIConstants.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: UIConstants.spacingSM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingSM,
              vertical: UIConstants.spacingXS,
            ),
            decoration: BoxDecoration(
              color: UIConstants.error,
              borderRadius: BorderRadius.circular(UIConstants.radiusXS),
            ),
            child: Text(
              '-${widget.product.discountPercentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: UIConstants.white,
                fontSize: UIConstants.fontSizeXS,
                fontWeight: UIConstants.fontWeightBold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        final starRating = index + 1;
        return Icon(
          starRating <= rating
              ? Icons.star
              : starRating - rating < 1
                  ? Icons.star_half
                  : Icons.star_border,
          size: UIConstants.iconSizeSM,
          color: UIConstants.warning,
        );
      }),
    );
  }

  Widget _buildStockStatus() {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (!widget.product.isActive) {
      statusColor = UIConstants.gray;
      statusIcon = Icons.block;
      statusText = 'No disponible';
    } else if (widget.product.stock <= 0) {
      statusColor = UIConstants.error;
      statusIcon = Icons.inventory_2_outlined;
      statusText = 'Agotado';
    } else if (widget.product.stock <= 5) {
      statusColor = UIConstants.warning;
      statusIcon = Icons.warning_amber_outlined;
      statusText = 'Últimas ${widget.product.stock} unidades';
    } else {
      statusColor = UIConstants.success;
      statusIcon = Icons.check_circle_outline;
      statusText = 'En stock (${widget.product.stock} disponibles)';
    }

    return Container(
          padding: const EdgeInsets.all(UIConstants.spacingSM),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusSM),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: UIConstants.iconSizeSM),
          const SizedBox(width: UIConstants.spacingSM),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: UIConstants.fontWeightMedium,
              fontSize: UIConstants.fontSizeSM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Container(
      margin: const EdgeInsets.only(top: UIConstants.spacingSM),
      color: UIConstants.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: UIConstants.primaryBlue,
            unselectedLabelColor: UIConstants.textSecondary,
            indicatorColor: UIConstants.primaryBlue,
            tabs: const [
              Tab(text: 'Descripción'),
              Tab(text: 'Especificaciones'),
              Tab(text: 'Reviews'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(),
                _buildSpecificationsTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingMD),
      child: SingleChildScrollView(
        child: Text(
          widget.product.description,
          style: const TextStyle(
            fontSize: UIConstants.fontSizeMD,
            color: UIConstants.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    final specs = widget.product.specifications;
    
    if (specs == null || specs.isEmpty) {
      return const Center(
        child: Text(
          'No hay especificaciones disponibles',
          style: TextStyle(color: UIConstants.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(UIConstants.spacingMD),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        final key = specs.keys.elementAt(index);
        final value = specs[key];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.spacingMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  key.toString(),
                  style: const TextStyle(
                    fontWeight: UIConstants.fontWeightMedium,
                    color: UIConstants.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    color: UIConstants.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return const Center(
      child: Text(
        'Funcionalidad de reviews próximamente',
        style: TextStyle(color: UIConstants.textSecondary),
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.relatedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(top: UIConstants.spacingSM),
          child: ProductHorizontalList(
            title: 'Productos relacionados',
            products: provider.relatedProducts,
            onProductTap: (product) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
            onAddToCart: (product) => _addToCart(),
            onAddToFavorites: (product) => _addToFavorites(),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: UIConstants.white,
      padding: const EdgeInsets.all(UIConstants.spacingMD),
      child: SafeArea(
        child: Row(
          children: [
            // Selector de cantidad
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: UIConstants.grayMedium),
                borderRadius: BorderRadius.circular(UIConstants.radiusSM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _selectedQuantity > 1 ? _decreaseQuantity : null,
                    icon: const Icon(Icons.remove),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingMD),
                    child: Text(
                      _selectedQuantity.toString(),
                      style: const TextStyle(
                        fontSize: UIConstants.fontSizeMD,
                        fontWeight: UIConstants.fontWeightMedium,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectedQuantity < widget.product.stock ? _increaseQuantity : null,
                    icon: const Icon(Icons.add),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: UIConstants.spacingMD),
            
            // Botón agregar al carrito
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.product.inStock ? _addToCartFromDetail : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  widget.product.inStock 
                      ? 'Agregar al carrito'
                      : 'No disponible',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIConstants.primaryBlue,
                  foregroundColor: UIConstants.white,
                  disabledBackgroundColor: UIConstants.grayMedium,
                  disabledForegroundColor: UIConstants.gray,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusMD),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMD),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _decreaseQuantity() {
    if (_selectedQuantity > 1) {
      setState(() {
        _selectedQuantity--;
      });
    }
  }

  void _increaseQuantity() {
    if (_selectedQuantity < widget.product.stock) {
      setState(() {
        _selectedQuantity++;
      });
    }
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} agregado al carrito'),
        backgroundColor: UIConstants.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToCartFromDetail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedQuantity} x ${widget.product.name} agregado al carrito'),
        backgroundColor: UIConstants.success,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: UIConstants.white,
          onPressed: () {
            // TODO: Navegar al carrito
          },
        ),
      ),
    );
  }

  void _addToFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} agregado a favoritos'),
        backgroundColor: UIConstants.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareProduct() {
    // TODO: Implementar compartir producto
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de compartir próximamente'),
        backgroundColor: UIConstants.info,
      ),
    );
  }

  void _toggleFavorite() {
    // TODO: Implementar toggle de favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de favoritos próximamente'),
        backgroundColor: UIConstants.info,
      ),
    );
  }
}
