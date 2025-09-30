import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';
import 'product_card.dart';

/// Widget para mostrar una lista de productos en grid
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
  final int crossAxisCount;
  final double childAspectRatio;

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
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return _buildLoadingState();
    }

    if (error != null && products.isEmpty) {
      return _buildErrorState();
    }

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return _buildProductGrid();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(UIConstants.primaryBlue),
          ),
          SizedBox(height: UIConstants.spacingMD),
          Text(
            'Cargando productos...',
            style: TextStyle(
              color: UIConstants.textSecondary,
              fontSize: UIConstants.fontSizeMD,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: UIConstants.iconSizeXL,
            color: UIConstants.error,
          ),
          const SizedBox(height: UIConstants.spacingMD),
          Text(
            error ?? 'Error al cargar productos',
            style: const TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: UIConstants.iconSizeXL,
            color: UIConstants.gray,
          ),
          SizedBox(height: UIConstants.spacingMD),
          Text(
            'No se encontraron productos',
            style: TextStyle(
              color: UIConstants.textSecondary,
              fontSize: UIConstants.fontSizeMD,
              fontWeight: UIConstants.fontWeightMedium,
            ),
          ),
          SizedBox(height: UIConstants.spacingSM),
          Text(
            'Intenta ajustar tus filtros de búsqueda',
            style: TextStyle(
              color: UIConstants.textSecondary,
              fontSize: UIConstants.fontSizeSM,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      color: UIConstants.primaryBlue,
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
                padding: const EdgeInsets.all(UIConstants.spacingSM),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: UIConstants.spacingSM,
                  mainAxisSpacing: UIConstants.spacingSM,
                ),
                itemCount: products.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == products.length) {
                    return _buildLoadMoreIndicator();
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

  Widget _buildLoadMoreIndicator() {
    return const Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingMD),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(UIConstants.primaryBlue),
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar una lista horizontal de productos
class ProductHorizontalList extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final String title;
  final VoidCallback? onSeeAll;
  final Function(ProductModel)? onProductTap;
  final Function(ProductModel)? onAddToCart;
  final Function(ProductModel)? onAddToFavorites;
  final double height;

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
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: UIConstants.spacingSM),
        SizedBox(
          height: height,
          child: _buildProductList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingSM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: UIConstants.fontSizeLG,
              fontWeight: UIConstants.fontWeightBold,
              color: UIConstants.textPrimary,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  color: UIConstants.primaryBlue,
                  fontWeight: UIConstants.fontWeightMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (isLoading) {
      return _buildLoadingList();
    }

    if (error != null) {
      return _buildErrorList();
    }

    if (products.isEmpty) {
      return _buildEmptyList();
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingSM),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          width: 180,
          margin: const EdgeInsets.only(right: UIConstants.spacingSM),
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

  Widget _buildLoadingList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingSM),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: 180,
          margin: const EdgeInsets.only(right: UIConstants.spacingSM),
          child: const Card(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(UIConstants.primaryBlue),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: UIConstants.error,
          ),
          const SizedBox(height: UIConstants.spacingSM),
          Text(
            error ?? 'Error al cargar',
            style: const TextStyle(color: UIConstants.error),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyList() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: UIConstants.gray,
          ),
          SizedBox(height: UIConstants.spacingSM),
          Text(
            'No hay productos disponibles',
            style: TextStyle(color: UIConstants.textSecondary),
          ),
        ],
      ),
    );
  }
}
