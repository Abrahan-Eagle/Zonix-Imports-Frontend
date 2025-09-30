import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/product_list.dart';
import 'product_detail_page.dart';
import 'product_search_page.dart';

/// Página principal de productos con catálogo y filtros responsive
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      productProvider.refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? UIConstants.backgroundDark : UIConstants.grayLight,
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          _buildSearchBar(context, isDark),
          _buildCategoriesFilter(context, isDark),
          _buildTabBar(context, isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllProductsTab(),
                _buildFeaturedProductsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      title: Text(
        'Catálogo',
        style: TextStyle(
          color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
          fontWeight: UIConstants.fontWeightBold,
          fontSize: _getAppBarTitleSize(screenWidth),
        ),
      ),
      backgroundColor: isDark ? UIConstants.cardBgDark : UIConstants.white,
      elevation: isDark ? UIConstants.elevationXS : UIConstants.elevationNone,
      iconTheme: IconThemeData(
        color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
      ),
      actions: [
        IconButton(
          onPressed: () => _showFiltersDialog(context, isDark),
          icon: Icon(
            Icons.tune,
            color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
            size: _getAppBarIconSize(screenWidth),
          ),
        ),
        IconButton(
          onPressed: () => _navigateToSearch(),
          icon: Icon(
            Icons.search,
            color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
            size: _getAppBarIconSize(screenWidth),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: isDark ? UIConstants.cardBgDark : UIConstants.white,
      padding: EdgeInsets.all(_getSearchBarPadding(screenWidth)),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
          fontSize: _getSearchBarFontSize(screenWidth),
        ),
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white60 : UIConstants.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? UIConstants.textLight : UIConstants.gray,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? UIConstants.textLight : UIConstants.gray,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMD),
            borderSide: BorderSide(
              color: isDark ? UIConstants.grayDark : UIConstants.grayMedium,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMD),
            borderSide: BorderSide(
              color: isDark ? UIConstants.grayDark : UIConstants.grayMedium,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMD),
            borderSide: const BorderSide(
              color: UIConstants.primaryBlue,
              width: 2,
            ),
          ),
          filled: true,
          fillColor:
              isDark ? UIConstants.backgroundDark : UIConstants.grayLight,
          contentPadding: EdgeInsets.all(_getSearchBarPadding(screenWidth)),
        ),
        onSubmitted: (value) => _navigateToSearch(query: value),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildCategoriesFilter(BuildContext context, bool isDark) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (!provider.hasCategories) {
          return const SizedBox.shrink();
        }

        return Container(
          color: isDark ? UIConstants.cardBgDark : UIConstants.white,
          height: _getCategoriesHeight(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
                horizontal: _getCategoriesPadding(context)),
            itemCount: provider.mainCategories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(
                  'Todos',
                  provider.selectedCategoryId == null,
                  () => provider.applyFilters(categoryId: null),
                  isDark,
                  context,
                );
              }

              final category = provider.mainCategories[index - 1];
              final isSelected = provider.selectedCategoryId == category.id;

              return _buildCategoryChip(
                category.name,
                isSelected,
                () => provider.applyFilters(categoryId: category.id),
                isDark,
                context,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: _getCategoryMargin(screenWidth)),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: _getCategoryFontSize(screenWidth),
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: UIConstants.primaryBlue.withOpacity(0.2),
        checkmarkColor: UIConstants.primaryBlue,
        backgroundColor:
            isDark ? UIConstants.backgroundDark : UIConstants.grayLight,
        labelStyle: TextStyle(
          color: isSelected
              ? UIConstants.primaryBlue
              : (isDark ? UIConstants.textWhite : UIConstants.textSecondary),
          fontWeight: isSelected
              ? UIConstants.fontWeightMedium
              : UIConstants.fontWeightNormal,
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? UIConstants.cardBgDark : UIConstants.white,
      child: TabBar(
        controller: _tabController,
        labelColor: UIConstants.primaryBlue,
        unselectedLabelColor:
            isDark ? Colors.white60 : UIConstants.textSecondary,
        indicatorColor: UIConstants.primaryBlue,
        labelStyle: TextStyle(
          fontWeight: UIConstants.fontWeightMedium,
          fontSize: _getTabFontSize(context),
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: UIConstants.fontWeightNormal,
          fontSize: _getTabFontSize(context),
        ),
        tabs: const [
          Tab(text: 'Todos'),
          Tab(text: 'Destacados'),
        ],
      ),
    );
  }

  Widget _buildAllProductsTab() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return ProductList(
          products: provider.products,
          isLoading: provider.isLoading,
          isLoadingMore: provider.isLoadingMore,
          hasMoreProducts: provider.hasMoreProducts,
          error: provider.error,
          onLoadMore: () => provider.loadMoreProducts(),
          onRefresh: () => provider.loadProducts(refresh: true),
          onProductTap: (product) => _navigateToProductDetail(product),
          onAddToCart: (product) => _addToCart(product),
          onAddToFavorites: (product) => _addToFavorites(product),
        );
      },
    );
  }

  Widget _buildFeaturedProductsTab() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return ProductList(
          products: provider.featuredProducts,
          isLoading: provider.isLoading,
          isLoadingMore: false,
          hasMoreProducts: false,
          error: provider.error,
          onRefresh: () => provider.loadFeaturedProducts(),
          onProductTap: (product) => _navigateToProductDetail(product),
          onAddToCart: (product) => _addToCart(product),
          onAddToFavorites: (product) => _addToFavorites(product),
        );
      },
    );
  }

  void _navigateToSearch({String? query}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSearchPage(initialQuery: query),
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

  void _addToCart(ProductModel product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} agregado al carrito',
          style: TextStyle(
            color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
          ),
        ),
        backgroundColor: UIConstants.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusSM),
        ),
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

  void _addToFavorites(ProductModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado a favoritos'),
        backgroundColor: UIConstants.primaryBlue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusSM),
        ),
      ),
    );
  }

  void _showFiltersDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltersBottomSheet(context, isDark),
    );
  }

  Widget _buildFiltersBottomSheet(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? UIConstants.cardBgDark : UIConstants.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(UIConstants.radiusLG),
          topRight: Radius.circular(UIConstants.radiusLG),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: UIConstants.spacingMD,
          right: UIConstants.spacingMD,
          top: UIConstants.spacingMD,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + UIConstants.spacingMD,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltersHeader(context, isDark),
            const SizedBox(height: UIConstants.spacingMD),
            _buildSortOptions(context, isDark),
            const SizedBox(height: UIConstants.spacingMD),
            _buildStockFilter(context, isDark),
            const SizedBox(height: UIConstants.spacingLG),
            _buildFiltersActions(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filtros',
          style: TextStyle(
            fontSize: UIConstants.fontSizeLG,
            fontWeight: UIConstants.fontWeightBold,
            color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
          ),
        ),
        Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return TextButton(
              onPressed: () {
                provider.clearFilters();
                Navigator.pop(context);
              },
              child: Text(
                'Limpiar',
                style: TextStyle(color: UIConstants.primaryBlue),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSortOptions(BuildContext context, bool isDark) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ordenar por',
              style: TextStyle(
                fontSize: UIConstants.fontSizeMD,
                fontWeight: UIConstants.fontWeightMedium,
                color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSM),
            Wrap(
              spacing: UIConstants.spacingSM,
              children: [
                _buildSortChip('Nombre', 'name', provider, isDark),
                _buildSortChip('Precio', 'price', provider, isDark),
                _buildSortChip('Popularidad', 'popularity', provider, isDark),
                _buildSortChip('Más recientes', 'created_at', provider, isDark),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortChip(
      String label, String value, ProductProvider provider, bool isDark) {
    final isSelected = provider.selectedSort == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        provider.applyFilters(sortBy: value);
      },
      selectedColor: UIConstants.primaryBlue.withOpacity(0.2),
      checkmarkColor: UIConstants.primaryBlue,
      backgroundColor:
          isDark ? UIConstants.backgroundDark : UIConstants.grayLight,
      labelStyle: TextStyle(
        color: isSelected
            ? UIConstants.primaryBlue
            : (isDark ? UIConstants.textWhite : UIConstants.textSecondary),
      ),
    );
  }

  Widget _buildStockFilter(BuildContext context, bool isDark) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disponibilidad',
              style: TextStyle(
                fontSize: UIConstants.fontSizeMD,
                fontWeight: UIConstants.fontWeightMedium,
                color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSM),
            CheckboxListTile(
              title: Text(
                'Solo productos en stock',
                style: TextStyle(
                  color:
                      isDark ? UIConstants.textWhite : UIConstants.textPrimary,
                ),
              ),
              value: provider.inStockOnly ?? false,
              onChanged: (value) {
                provider.applyFilters(inStockOnly: value);
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: UIConstants.primaryBlue,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltersActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark ? UIConstants.grayDark : UIConstants.gray,
              ),
              foregroundColor:
                  isDark ? UIConstants.textWhite : UIConstants.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusMD),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: UIConstants.spacingMD),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIConstants.primaryBlue,
              foregroundColor: UIConstants.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusMD),
              ),
            ),
            child: const Text('Aplicar'),
          ),
        ),
      ],
    );
  }

  // ========================================
  // 📱 HELPERS RESPONSIVOS
  // ========================================

  /// Calcular tamaño de título del AppBar responsive
  double _getAppBarTitleSize(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.fontSizeLG;
    } else {
      return UIConstants.fontSizeXL;
    }
  }

  /// Calcular tamaño de iconos del AppBar responsive
  double _getAppBarIconSize(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.iconSizeSM;
    } else {
      return UIConstants.iconSizeMD;
    }
  }

  /// Calcular padding del search bar responsive
  double _getSearchBarPadding(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.spacingSM;
    } else {
      return UIConstants.spacingMD;
    }
  }

  /// Calcular tamaño de fuente del search bar responsive
  double _getSearchBarFontSize(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.fontSizeSM;
    } else {
      return UIConstants.fontSizeMD;
    }
  }

  /// Calcular altura de categorías responsive
  double _getCategoriesHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < UIConstants.breakpointMobile) {
      return 45.0;
    } else {
      return 50.0;
    }
  }

  /// Calcular padding de categorías responsive
  double _getCategoriesPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.spacingSM;
    } else {
      return UIConstants.spacingMD;
    }
  }

  /// Calcular margin de categorías responsive
  double _getCategoryMargin(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.spacingXS;
    } else {
      return UIConstants.spacingSM;
    }
  }

  /// Calcular tamaño de fuente de categorías responsive
  double _getCategoryFontSize(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.fontSizeXS;
    } else {
      return UIConstants.fontSizeSM;
    }
  }

  /// Calcular tamaño de fuente de tabs responsive
  double _getTabFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.fontSizeSM;
    } else {
      return UIConstants.fontSizeMD;
    }
  }
}
