import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';

/// Widget para mostrar una tarjeta de producto
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
    return Card(
      elevation: 2,
      shadowColor: UIConstants.gray.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusMD),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.radiusMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageSection(context),
            Expanded(
              child: _buildContentSection(context),
            ),
            _buildActionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      height: UIConstants.productImageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(UIConstants.radiusMD),
          topRight: Radius.circular(UIConstants.radiusMD),
        ),
        color: UIConstants.grayLight,
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
                      return _buildImagePlaceholder();
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImageError(),
                  )
                : _buildImagePlaceholder(),
          ),

          // Badges superpuestos
          Positioned(
            top: UIConstants.spacingSM,
            left: UIConstants.spacingSM,
            child: _buildBadges(),
          ),

          // Botón de favoritos
          Positioned(
            top: UIConstants.spacingSM,
            right: UIConstants.spacingSM,
            child: _buildFavoriteButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: UIConstants.grayLight,
      child: const Icon(
        Icons.image_outlined,
        size: UIConstants.iconSizeXL,
        color: UIConstants.gray,
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: UIConstants.grayLight,
      child: const Icon(
        Icons.broken_image_outlined,
        size: UIConstants.iconSizeXL,
        color: UIConstants.error,
      ),
    );
  }

  Widget _buildBadges() {
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
              color: UIConstants.gray,
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

  Widget _buildFavoriteButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UIConstants.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          )
        ],
      ),
      child: IconButton(
        onPressed: onAddToFavorites,
        icon: const Icon(
          Icons.favorite_border,
          color: UIConstants.gray,
          size: UIConstants.iconSizeSM,
        ),
        constraints: const BoxConstraints(
          minWidth: UIConstants.iconSizeMD + UIConstants.spacingSM,
          minHeight: UIConstants.iconSizeMD + UIConstants.spacingSM,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nombre del producto
          Flexible(
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: UIConstants.fontSizeSM,
                fontWeight: UIConstants.fontWeightMedium,
                color: UIConstants.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: UIConstants.spacingXS),

          // Modalidad
          Text(
            product.modalityText,
            style: const TextStyle(
              fontSize: UIConstants.fontSizeXS,
              color: UIConstants.textSecondary,
              fontWeight: UIConstants.fontWeightNormal,
            ),
          ),

          const SizedBox(height: UIConstants.spacingSM),

          // Precio
          _buildPriceSection(),

          const SizedBox(height: UIConstants.spacingXS),

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
          product.formattedFinalPrice,
          style: const TextStyle(
            fontSize: UIConstants.fontSizeMD,
            fontWeight: UIConstants.fontWeightBold,
            color: UIConstants.primaryBlue,
          ),
        ),

        // Precio original (si hay precio mayorista)
        if (product.hasWholesalePrice) ...[
          const SizedBox(width: UIConstants.spacingXS),
          Text(
            product.formattedPrice,
            style: const TextStyle(
              fontSize: UIConstants.fontSizeXS,
              color: UIConstants.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockStatus() {
    Color statusColor;
    IconData statusIcon;

    if (!product.available) {
      statusColor = UIConstants.gray;
      statusIcon = Icons.block;
    } else if (product.stock <= 0) {
      statusColor = UIConstants.error;
      statusIcon = Icons.inventory_2_outlined;
    } else if (product.stock <= 5) {
      statusColor = UIConstants.warning;
      statusIcon = Icons.warning_amber_outlined;
    } else {
      statusColor = UIConstants.success;
      statusIcon = Icons.check_circle_outline;
    }

    return Row(
      children: [
        Icon(
          statusIcon,
          size: UIConstants.iconSizeXS,
          color: statusColor,
        ),
        const SizedBox(width: UIConstants.spacingXS),
        Text(
          product.stockStatus,
          style: TextStyle(
            fontSize: UIConstants.fontSizeXS,
            color: statusColor,
            fontWeight: UIConstants.fontWeightMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: UIConstants.spacingSM,
        right: UIConstants.spacingSM,
        bottom: UIConstants.spacingSM,
      ),
      child: Row(
        children: [
          // Rating no disponible en el modelo actual
          // TODO: Implementar rating cuando esté disponible en el backend
          const Spacer(),

          // Botón de agregar al carrito
          SizedBox(
            height: UIConstants.heightButton * 0.7,
            child: ElevatedButton(
              onPressed: product.inStock ? onAddToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: UIConstants.primaryBlue,
                foregroundColor: UIConstants.white,
                disabledBackgroundColor: UIConstants.grayMedium,
                disabledForegroundColor: UIConstants.gray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusSM),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingMD),
              ),
              child: const Icon(
                Icons.add_shopping_cart_outlined,
                size: UIConstants.iconSizeSM,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
