import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';
import 'product_card.dart';

/// Widget para mostrar una lista de productos en grid responsive
class ProductList extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreProducts;
  final String? error;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;
  final Function(ProductModel)? onProductTap;
  final Function(ProductModel)? onAddToCart;
  final Function(ProductModel)? onAddToFavorites;

  const ProductList({
    super.key,
    required this.products,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreProducts = true,
    this.error,
    this.onLoadMore,
    this.onRefresh,
    this.onProductTap,
    this.onAddToCart,
    this.onAddToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading && products.isEmpty) {
      return _buildLoadingState(isDark);
    }

    if (error != null && products.isEmpty) {
      return _buildErrorState(isDark);
    }

    if (products.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return _buildProductGrid(context, isDark);
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                const AlwaysStoppedAnimation<Color>(UIConstants.primaryBlue),
            backgroundColor:
                isDark ? UIConstants.grayDark : UIConstants.grayLight,
          ),
          const SizedBox(height: UIConstants.spacingMD),
          Text(
            'Cargando productos...',
            style: TextStyle(
              color: isDark ? UIConstants.textWhite : UIConstants.textSecondary,
              fontSize: UIConstants.fontSizeMD,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMD),
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
              error ?? 'Error al cargar productos',
              style: TextStyle(
                color: UIConstants.error,
                fontSize: UIConstants.fontSizeMD,
                fontWeight: UIConstants.fontWeightMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingMD),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIConstants.primaryBlue,
                foregroundColor: UIConstants.white,
                elevation: UIConstants.elevationSM,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMD),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: UIConstants.iconSizeXL,
              color: isDark ? UIConstants.textLight : UIConstants.gray,
            ),
            const SizedBox(height: UIConstants.spacingMD),
            Text(
              'No se encontraron productos',
              style: TextStyle(
                color:
                    isDark ? UIConstants.textWhite : UIConstants.textSecondary,
                fontSize: UIConstants.fontSizeMD,
                fontWeight: UIConstants.fontWeightMedium,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSM),
            Text(
              'Intenta ajustar tus filtros de búsqueda',
              style: TextStyle(
                color: isDark ? Colors.white70 : UIConstants.textSecondary,
                fontSize: UIConstants.fontSizeSM,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final childAspectRatio = _getChildAspectRatio(screenWidth);

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      color: UIConstants.primaryBlue,
      backgroundColor:
          isDark ? UIConstants.cardBgDark : UIConstants.cardBgLight,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              hasMoreProducts &&
              !isLoadingMore) {
            onLoadMore?.call();
          }
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(_getPadding(screenWidth)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: _getSpacing(screenWidth),
                  mainAxisSpacing: _getSpacing(screenWidth),
                ),
                itemCount: products.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == products.length) {
                    return _buildLoadMoreIndicator(isDark);
                  }

                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => onProductTap?.call(product),
                    onAddToCart: () => onAddToCart?.call(product),
                    onAddToFavorites: () => onAddToFavorites?.call(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isDark) {
    return Card(
      color: isDark ? UIConstants.cardBgDark : UIConstants.cardBgLight,
      elevation: UIConstants.elevationXS,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingMD),
          child: CircularProgressIndicator(
            valueColor:
                const AlwaysStoppedAnimation<Color>(UIConstants.primaryBlue),
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }

  /// Calcular número de columnas responsive
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return 2; // 2 columnas en móvil
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return 3; // 3 columnas en tablet pequeño
    } else if (screenWidth < UIConstants.breakpointDesktop) {
      return 4; // 4 columnas en tablet grande
    } else {
      return 5; // 5 columnas en desktop
    }
  }

  /// Calcular aspect ratio responsive
  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return 0.58; // Más alto en móvil para evitar overflow
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return 0.62; // Intermedio en tablet pequeño
    } else {
      return 0.65; // Más alto en pantallas grandes
    }
  }

  /// Calcular padding responsive
  double _getPadding(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.spacingSM; // Menos padding en móvil
    } else {
      return UIConstants.spacingMD; // Más padding en pantallas grandes
    }
  }

  /// Calcular spacing responsive
  double _getSpacing(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.spacingSM; // Menos espacio en móvil
    } else {
      return UIConstants.spacingMD; // Más espacio en pantallas grandes
    }
  }
}

/// Widget para mostrar una lista horizontal de productos responsive
class ProductHorizontalList extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final String title;
  final VoidCallback? onSeeAll;
  final Function(ProductModel)? onProductTap;
  final Function(ProductModel)? onAddToCart;
  final Function(ProductModel)? onAddToFavorites;

  const ProductHorizontalList({
    super.key,
    required this.products,
    required this.title,
    this.isLoading = false,
    this.error,
    this.onSeeAll,
    this.onProductTap,
    this.onAddToCart,
    this.onAddToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, isDark),
        const SizedBox(height: UIConstants.spacingSM),
        SizedBox(
          height: _getListHeight(screenWidth),
          child: _buildProductList(context, isDark, screenWidth),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(_getHeaderPadding(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: _getTitleFontSize(context),
                fontWeight: UIConstants.fontWeightBold,
                color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'Ver todo',
                style: TextStyle(
                  color: UIConstants.primaryBlue,
                  fontWeight: UIConstants.fontWeightMedium,
                  fontSize: _getButtonFontSize(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductList(
      BuildContext context, bool isDark, double screenWidth) {
    if (isLoading) {
      return _buildLoadingList(context, isDark, screenWidth);
    }

    if (error != null) {
      return _buildErrorList(isDark);
    }

    if (products.isEmpty) {
      return _buildEmptyList(isDark);
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: _getListPadding(screenWidth)),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          width: _getItemWidth(screenWidth),
          margin: EdgeInsets.only(right: _getItemMargin(screenWidth)),
          child: ProductCard(
            product: product,
            onTap: () => onProductTap?.call(product),
            onAddToCart: () => onAddToCart?.call(product),
            onAddToFavorites: () => onAddToFavorites?.call(product),
          ),
        );
      },
    );
  }

  Widget _buildLoadingList(
      BuildContext context, bool isDark, double screenWidth) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: _getListPadding(screenWidth)),
      itemCount: _getLoadingItemsCount(screenWidth),
      itemBuilder: (context, index) {
        return Container(
          width: _getItemWidth(screenWidth),
          margin: EdgeInsets.only(right: _getItemMargin(screenWidth)),
          child: Card(
            color: isDark ? UIConstants.cardBgDark : UIConstants.cardBgLight,
            elevation: UIConstants.elevationXS,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(
                    UIConstants.primaryBlue),
                strokeWidth: 2.0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorList(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: UIConstants.error,
            size: UIConstants.iconSizeLG,
          ),
          const SizedBox(height: UIConstants.spacingSM),
          Text(
            error ?? 'Error al cargar',
            style: TextStyle(
              color: UIConstants.error,
              fontSize: UIConstants.fontSizeSM,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyList(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: isDark ? UIConstants.textLight : UIConstants.gray,
            size: UIConstants.iconSizeLG,
          ),
          const SizedBox(height: UIConstants.spacingSM),
          Text(
            'No hay productos disponibles',
            style: TextStyle(
              color: isDark ? UIConstants.textWhite : UIConstants.textSecondary,
              fontSize: UIConstants.fontSizeSM,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Calcular altura de lista responsive
  double _getListHeight(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return 220.0; // Más bajo en móvil
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return 240.0; // Intermedio en tablet pequeño
    } else {
      return 260.0; // Más alto en pantallas grandes
    }
  }

  /// Calcular padding del header responsive
  double _getHeaderPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.spacingSM;
    } else {
      return UIConstants.spacingMD;
    }
  }

  /// Calcular tamaño de fuente del título responsive
  double _getTitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.fontSizeMD;
    } else {
      return UIConstants.fontSizeLG;
    }
  }

  /// Calcular tamaño de fuente del botón responsive
  double _getButtonFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.fontSizeSM;
    } else {
      return UIConstants.fontSizeMD;
    }
  }

  /// Calcular padding de lista responsive
  double _getListPadding(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.spacingSM;
    } else {
      return UIConstants.spacingMD;
    }
  }

  /// Calcular ancho de item responsive
  double _getItemWidth(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return 160.0; // Más estrecho en móvil
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return 180.0; // Intermedio en tablet pequeño
    } else {
      return 200.0; // Más ancho en pantallas grandes
    }
  }

  /// Calcular margin de item responsive
  double _getItemMargin(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.spacingSM;
    } else {
      return UIConstants.spacingMD;
    }
  }

  /// Calcular número de items de carga responsive
  int _getLoadingItemsCount(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return 2; // Menos items en móvil
    } else if (screenWidth < UIConstants.breakpointTablet) {
      return 3; // Intermedio en tablet pequeño
    } else {
      return 4; // Más items en pantallas grandes
    }
  }
}
