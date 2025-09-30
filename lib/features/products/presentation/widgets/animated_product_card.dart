import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';

/// Widget de tarjeta de producto con animaciones y micro-interacciones
class AnimatedProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onAddToFavorites;
  final bool isFavorite;

  const AnimatedProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onAddToFavorites,
    this.isFavorite = false,
  });

  @override
  State<AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _favoriteController;
  late AnimationController _addToCartController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _favoriteAnimation;
  late Animation<double> _addToCartAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Animación de escala para hover y tap
    _scaleController = AnimationController(
      duration: UIConstants.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: UIConstants.curveEaseOut,
    ));

    // Animación de favoritos
    _favoriteController = AnimationController(
      duration: UIConstants.animationNormal,
      vsync: this,
    );
    _favoriteAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: UIConstants.curveBounceOut,
    ));

    // Animación de agregar al carrito
    _addToCartController = AnimationController(
      duration: UIConstants.animationFast,
      vsync: this,
    );
    _addToCartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _addToCartController,
      curve: UIConstants.curveEaseOut,
    ));

    if (widget.isFavorite) {
      _favoriteController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _favoriteController.dispose();
    _addToCartController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
  }

  void _onFavoriteTap() {
    if (widget.isFavorite) {
      _favoriteController.reverse();
    } else {
      _favoriteController.forward();
    }
    widget.onAddToFavorites?.call();
  }

  void _onAddToCartTap() {
    _addToCartController.forward().then((_) {
      _addToCartController.reverse();
    });
    widget.onAddToCart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _favoriteAnimation,
        _addToCartAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: _getCardWidth(screenWidth),
            constraints: BoxConstraints(
              maxHeight: _getMaxCardHeight(screenWidth),
            ),
            child: Card(
              elevation: _isPressed
                  ? UIConstants.elevationLG
                  : UIConstants.elevationSM,
              color: isDark ? UIConstants.cardBgDark : UIConstants.cardBgLight,
              shadowColor:
                  isDark ? Colors.black54 : UIConstants.gray.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusMD),
              ),
              child: InkWell(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                borderRadius: BorderRadius.circular(UIConstants.radiusMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAnimatedImageSection(context, screenWidth, isDark),
                    Expanded(
                      child: _buildContentSection(context, isDark),
                    ),
                    _buildAnimatedActionSection(context, isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedImageSection(
      BuildContext context, double screenWidth, bool isDark) {
    final imageHeight = _getImageHeight(screenWidth);

    return Container(
      height: imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(UIConstants.radiusMD),
          topRight: Radius.circular(UIConstants.radiusMD),
        ),
        color: isDark ? UIConstants.grayDark : UIConstants.grayLight,
      ),
      child: Stack(
        children: [
          // Imagen del producto con animación de entrada
          AnimatedOpacity(
            opacity: 1.0,
            duration: UIConstants.animationNormal,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(UIConstants.radiusMD),
                topRight: Radius.circular(UIConstants.radiusMD),
              ),
              child: widget.product.primaryImage.isNotEmpty
                  ? Image.network(
                      widget.product.primaryImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildImagePlaceholder(isDark);
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImageError(isDark),
                    )
                  : _buildImagePlaceholder(isDark),
            ),
          ),

          // Badges con animación de entrada
          Positioned(
            top: UIConstants.spacingSM,
            left: UIConstants.spacingSM,
            child: AnimatedSlide(
              offset: const Offset(0, -1),
              duration: UIConstants.animationNormal,
              child: _buildBadges(isDark),
            ),
          ),

          // Botón de favoritos con animación
          Positioned(
            top: UIConstants.spacingSM,
            right: UIConstants.spacingSM,
            child: AnimatedBuilder(
              animation: _favoriteAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_favoriteAnimation.value * 0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black54 : Colors.white70)
                          .withOpacity(0.9),
                      borderRadius:
                          BorderRadius.circular(UIConstants.radiusCircle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: UIConstants.animationFast,
                        child: Icon(
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          key: ValueKey(widget.isFavorite),
                          color: widget.isFavorite
                              ? UIConstants.error
                              : UIConstants.error,
                          size: UIConstants.iconSizeSM,
                        ),
                      ),
                      onPressed: _onFavoriteTap,
                      padding: const EdgeInsets.all(UIConstants.spacingXS),
                      constraints: const BoxConstraints(
                        minWidth: UIConstants.iconSizeSM,
                        minHeight: UIConstants.iconSizeSM,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Overlay de agregar al carrito
          AnimatedBuilder(
            animation: _addToCartAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _addToCartAnimation.value,
                  duration: UIConstants.animationFast,
                  child: Container(
                    decoration: BoxDecoration(
                      color: UIConstants.success.withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(UIConstants.radiusMD),
                        topRight: Radius.circular(UIConstants.radiusMD),
                      ),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: _addToCartAnimation.value,
                        child: const Icon(
                          Icons.check_circle,
                          color: UIConstants.white,
                          size: UIConstants.iconSizeXL,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingSM,
        vertical: UIConstants.spacingXS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nombre del producto con animación de entrada
          AnimatedSlide(
            offset: const Offset(0, 0.5),
            duration: UIConstants.animationNormal,
            child: Text(
              widget.product.name,
              style: TextStyle(
                fontSize: UIConstants.fontSizeSM,
                fontWeight: UIConstants.fontWeightMedium,
                color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: UIConstants.spacingXS),

          // Modalidad con animación de entrada
          AnimatedSlide(
            offset: const Offset(0, 0.5),
            duration: UIConstants.animationNormal,
            child: Text(
              widget.product.modalityText,
              style: TextStyle(
                fontSize: UIConstants.fontSizeXS,
                color: isDark ? Colors.white70 : UIConstants.textSecondary,
                fontWeight: UIConstants.fontWeightNormal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: UIConstants.spacingXS),

          // Precio con animación de entrada
          AnimatedSlide(
            offset: const Offset(0, 0.5),
            duration: UIConstants.animationNormal,
            child: _buildPriceSection(isDark),
          ),

          const SizedBox(height: UIConstants.spacingXS),

          // Estado de stock con animación de entrada
          AnimatedSlide(
            offset: const Offset(0, 0.5),
            duration: UIConstants.animationNormal,
            child: _buildStockStatus(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedActionSection(BuildContext context, bool isDark) {
    return AnimatedSlide(
      offset: const Offset(0, 1),
      duration: UIConstants.animationNormal,
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingSM),
        child: SizedBox(
          width: double.infinity,
          height: UIConstants.heightButton / 1.5,
          child: ElevatedButton(
            onPressed: widget.product.inStock ? _onAddToCartTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.product.inStock
                  ? UIConstants.primaryBlue
                  : UIConstants.gray,
              foregroundColor: UIConstants.white,
              elevation: UIConstants.elevationXS,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusSM),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: UIConstants.animationFast,
                  child: Icon(
                    widget.product.inStock
                        ? Icons.add_shopping_cart
                        : Icons.block,
                    key: ValueKey(widget.product.inStock),
                    size: UIConstants.iconSizeSM,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingXS),
                Text(
                  widget.product.inStock ? 'Agregar' : 'Agotado',
                  style: const TextStyle(
                    fontSize: UIConstants.fontSizeSM,
                    fontWeight: UIConstants.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Precio principal con animación de entrada
        AnimatedSlide(
          offset: const Offset(0, 0.3),
          duration: UIConstants.animationNormal,
          child: Text(
            widget.product.formattedFinalPrice,
            style: TextStyle(
              fontSize: UIConstants.fontSizeMD,
              fontWeight: UIConstants.fontWeightBold,
              color: isDark ? UIConstants.textWhite : UIConstants.primaryBlue,
            ),
          ),
        ),

        // Precio con descuento si aplica
        if (widget.product.hasWholesalePrice) ...[
          const SizedBox(height: UIConstants.spacingXS / 2),
          AnimatedSlide(
            offset: const Offset(0, 0.3),
            duration: UIConstants.animationNormal,
            child: Row(
              children: [
                Text(
                  'Antes: ${widget.product.formattedPrice}',
                  style: TextStyle(
                    fontSize: UIConstants.fontSizeXS,
                    color: isDark ? Colors.white60 : UIConstants.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockStatus(bool isDark) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: UIConstants.animationFast,
          child: Icon(
            widget.product.inStock ? Icons.check_circle : Icons.cancel,
            key: ValueKey(widget.product.inStock),
            size: UIConstants.iconSizeXS,
            color: widget.product.inStock
                ? UIConstants.success
                : UIConstants.error,
          ),
        ),
        const SizedBox(width: UIConstants.spacingXS),
        Text(
          widget.product.stockStatus,
          style: TextStyle(
            fontSize: UIConstants.fontSizeXS,
            color: widget.product.inStock
                ? UIConstants.success
                : UIConstants.error,
            fontWeight: UIConstants.fontWeightMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.product.hasWholesalePrice)
          AnimatedSlide(
            offset: const Offset(-1, 0),
            duration: UIConstants.animationNormal,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingSM,
                vertical: UIConstants.spacingXS,
              ),
              decoration: BoxDecoration(
                color: UIConstants.success,
                borderRadius: BorderRadius.circular(UIConstants.radiusXS),
                boxShadow: [
                  BoxShadow(
                    color: UIConstants.success.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Ahorro ${widget.product.savingsPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: UIConstants.white,
                  fontSize: UIConstants.fontSizeXS,
                  fontWeight: UIConstants.fontWeightBold,
                ),
              ),
            ),
          ),
        if (!widget.product.inStock)
          AnimatedSlide(
            offset: const Offset(-1, 0),
            duration: UIConstants.animationNormal,
            child: Container(
              margin: const EdgeInsets.only(top: UIConstants.spacingXS),
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingSM,
                vertical: UIConstants.spacingXS,
              ),
              decoration: BoxDecoration(
                color: UIConstants.error,
                borderRadius: BorderRadius.circular(UIConstants.radiusXS),
                boxShadow: [
                  BoxShadow(
                    color: UIConstants.error.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Agotado',
                style: TextStyle(
                  color: UIConstants.white,
                  fontSize: UIConstants.fontSizeXS,
                  fontWeight: UIConstants.fontWeightBold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      color: isDark ? UIConstants.grayDark : UIConstants.grayLight,
      child: Icon(
        Icons.image_outlined,
        size: UIConstants.iconSizeXL,
        color: isDark ? UIConstants.textLight : UIConstants.gray,
      ),
    );
  }

  Widget _buildImageError(bool isDark) {
    return Container(
      color: isDark ? UIConstants.grayDark : UIConstants.grayLight,
      child: Icon(
        Icons.broken_image_outlined,
        size: UIConstants.iconSizeXL,
        color: isDark ? UIConstants.error : UIConstants.error,
      ),
    );
  }

  // Helper methods para responsive design
  double _getCardWidth(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return (screenWidth - 48) / 2;
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return (screenWidth - 64) / 3;
    } else if (screenWidth < UIConstants.breakpointDesktop) {
      return (screenWidth - 80) / 4;
    } else {
      return (screenWidth - 96) / 5;
    }
  }

  double _getImageHeight(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return 100.0;
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return 120.0;
    } else {
      return 140.0;
    }
  }

  double _getMaxCardHeight(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return 280.0;
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return 300.0;
    } else {
      return 320.0;
    }
  }
}
