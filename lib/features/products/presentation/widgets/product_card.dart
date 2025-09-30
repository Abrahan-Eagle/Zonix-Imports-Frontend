import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';

/// Widget de tarjeta de producto reutilizable y responsive
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onAddToFavorites;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onAddToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calcular dimensiones responsive
    final cardWidth = _getCardWidth(screenWidth);
    final imageHeight = _getImageHeight(screenWidth);

    return Card(
      elevation: UIConstants.elevationSM,
      color: isDark ? UIConstants.cardBgDark : UIConstants.cardBgLight,
      shadowColor: isDark ? Colors.black54 : UIConstants.gray.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusMD),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.radiusMD),
        child: Container(
          width: cardWidth,
          constraints: BoxConstraints(
            maxHeight: _getMaxCardHeight(screenWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImageSection(context, imageHeight, isDark),
              Expanded(
                child: _buildContentSection(context, isDark),
              ),
              _buildActionSection(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Calcular ancho de tarjeta responsive
  double _getCardWidth(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return (screenWidth - 48) / 2; // 2 columnas en móvil
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return (screenWidth - 64) / 3; // 3 columnas en tablet pequeño
    } else if (screenWidth < UIConstants.breakpointDesktop) {
      return (screenWidth - 80) / 4; // 4 columnas en tablet grande
    } else {
      return (screenWidth - 96) / 5; // 5 columnas en desktop
    }
  }

  /// Calcular altura de imagen responsive
  double _getImageHeight(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return 100.0; // Móvil
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return 120.0; // Tablet pequeño
    } else {
      return 140.0; // Tablet grande y desktop
    }
  }

  /// Calcular altura máxima de tarjeta responsive
  double _getMaxCardHeight(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return 280.0; // Móvil - aumentado para evitar overflow
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return 300.0; // Tablet pequeño - aumentado
    } else {
      return 320.0; // Tablet grande y desktop - aumentado
    }
  }

  Widget _buildImageSection(
      BuildContext context, double imageHeight, bool isDark) {
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
          // Imagen del producto
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(UIConstants.radiusMD),
              topRight: Radius.circular(UIConstants.radiusMD),
            ),
            child: product.primaryImage.isNotEmpty
                ? Image.network(
                    product.primaryImage,
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

          // Badges superpuestos
          Positioned(
            top: UIConstants.spacingSM,
            left: UIConstants.spacingSM,
            child: _buildBadges(isDark),
          ),

          // Botón de favoritos
          Positioned(
            top: UIConstants.spacingSM,
            right: UIConstants.spacingSM,
            child: _buildFavoriteButton(context, isDark),
          ),
        ],
      ),
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

  Widget _buildBadges(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.hasWholesalePrice)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingSM,
              vertical: UIConstants.spacingXS,
            ),
            decoration: BoxDecoration(
              color: UIConstants.success,
              borderRadius: BorderRadius.circular(UIConstants.radiusXS),
            ),
            child: Text(
              'Ahorro ${product.savingsPercentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: UIConstants.white,
                fontSize: UIConstants.fontSizeXS,
                fontWeight: UIConstants.fontWeightBold,
              ),
            ),
          ),
        if (!product.inStock)
          Container(
            margin: const EdgeInsets.only(top: UIConstants.spacingXS),
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingSM,
              vertical: UIConstants.spacingXS,
            ),
            decoration: BoxDecoration(
              color: UIConstants.error,
              borderRadius: BorderRadius.circular(UIConstants.radiusXS),
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
      ],
    );
  }

  Widget _buildFavoriteButton(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black54 : Colors.white70,
        borderRadius: BorderRadius.circular(UIConstants.radiusCircle),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.favorite_border,
          color: UIConstants.error,
          size: UIConstants.iconSizeSM,
        ),
        onPressed: onAddToFavorites,
        padding: const EdgeInsets.all(UIConstants.spacingXS),
        constraints: const BoxConstraints(
          minWidth: UIConstants.iconSizeSM,
          minHeight: UIConstants.iconSizeSM,
        ),
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
          // Nombre del producto
          Text(
            product.name,
            style: TextStyle(
              fontSize: UIConstants.fontSizeSM,
              fontWeight: UIConstants.fontWeightMedium,
              color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: UIConstants.spacingXS),

          // Modalidad
          Text(
            product.modalityText,
            style: TextStyle(
              fontSize: UIConstants.fontSizeXS,
              color: isDark ? Colors.white70 : UIConstants.textSecondary,
              fontWeight: UIConstants.fontWeightNormal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: UIConstants.spacingXS),

          // Precio
          _buildPriceSection(isDark),

          const SizedBox(height: UIConstants.spacingXS),

          // Estado de stock
          _buildStockStatus(isDark),
        ],
      ),
    );
  }

  Widget _buildPriceSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Precio principal
        Text(
          product.formattedFinalPrice,
          style: TextStyle(
            fontSize: UIConstants.fontSizeMD,
            fontWeight: UIConstants.fontWeightBold,
            color: isDark ? UIConstants.textWhite : UIConstants.primaryBlue,
          ),
        ),

        // Precio con descuento si aplica
        if (product.hasWholesalePrice) ...[
          const SizedBox(height: UIConstants.spacingXS / 2),
          Row(
            children: [
              Text(
                'Antes: ${product.formattedPrice}',
                style: TextStyle(
                  fontSize: UIConstants.fontSizeXS,
                  color: isDark ? Colors.white60 : UIConstants.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStockStatus(bool isDark) {
    return Row(
      children: [
        Icon(
          product.inStock ? Icons.check_circle : Icons.cancel,
          size: UIConstants.iconSizeXS,
          color: product.inStock ? UIConstants.success : UIConstants.error,
        ),
        const SizedBox(width: UIConstants.spacingXS),
        Text(
          product.stockStatus,
          style: TextStyle(
            fontSize: UIConstants.fontSizeXS,
            color: product.inStock ? UIConstants.success : UIConstants.error,
            fontWeight: UIConstants.fontWeightMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingSM),
      child: SizedBox(
        width: double.infinity,
        height: UIConstants.heightButton / 1.5,
        child: ElevatedButton(
          onPressed: product.inStock ? onAddToCart : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                product.inStock ? UIConstants.primaryBlue : UIConstants.gray,
            foregroundColor: UIConstants.white,
            elevation: UIConstants.elevationXS,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusSM),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                product.inStock ? Icons.add_shopping_cart : Icons.block,
                size: UIConstants.iconSizeSM,
              ),
              const SizedBox(width: UIConstants.spacingXS),
              Text(
                product.inStock ? 'Agregar' : 'Agotado',
                style: const TextStyle(
                  fontSize: UIConstants.fontSizeSM,
                  fontWeight: UIConstants.fontWeightMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
