import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/product_list.dart';
import 'product_detail_page.dart';
import 'product_search_page.dart';

/// Página principal de productos con catálogo y filtros
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> with TickerProviderStateMixin {
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
    return Scaffold(
      backgroundColor: UIConstants.grayLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoriesFilter(),
          _buildTabBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Catálogo',
        style: TextStyle(
          color: UIConstants.textPrimary,
          fontWeight: UIConstants.fontWeightBold,
        ),
      ),
      backgroundColor: UIConstants.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () => _showFiltersDialog(),
          icon: const Icon(
            Icons.tune,
            color: UIConstants.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () => _navigateToSearch(),
          icon: const Icon(
            Icons.search,
            color: UIConstants.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: UIConstants.white,
      padding: const EdgeInsets.all(UIConstants.spacingSM),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          prefixIcon: const Icon(Icons.search, color: UIConstants.gray),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear, color: UIConstants.gray),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMD),
            borderSide: const BorderSide(color: UIConstants.grayMedium),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMD),
            borderSide: const BorderSide(color: UIConstants.primaryBlue, width: 2),
          ),
          contentPadding: const EdgeInsets.all(UIConstants.spacingSM),
        ),
        onSubmitted: (value) => _navigateToSearch(query: value),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildCategoriesFilter() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (!provider.hasCategories) {
          return const SizedBox.shrink();
        }

        return Container(
          color: UIConstants.white,
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingSM),
            itemCount: provider.mainCategories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(
                  'Todos',
                  provider.selectedCategoryId == null,
                  () => provider.applyFilters(categoryId: null),
                );
              }

              final category = provider.mainCategories[index - 1];
              final isSelected = provider.selectedCategoryId == category.id;
              
              return _buildCategoryChip(
                category.name,
                isSelected,
                () => provider.applyFilters(categoryId: category.id),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: UIConstants.spacingSM),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: UIConstants.primaryBlue.withOpacity(0.2),
        checkmarkColor: UIConstants.primaryBlue,
        labelStyle: TextStyle(
          color: isSelected ? UIConstants.primaryBlue : UIConstants.textSecondary,
          fontWeight: isSelected ? UIConstants.fontWeightMedium : UIConstants.fontWeightNormal,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: UIConstants.white,
      child: TabBar(
        controller: _tabController,
        labelColor: UIConstants.primaryBlue,
        unselectedLabelColor: UIConstants.textSecondary,
        indicatorColor: UIConstants.primaryBlue,
        labelStyle: const TextStyle(fontWeight: UIConstants.fontWeightMedium),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
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

  void _addToFavorites(ProductModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado a favoritos'),
        backgroundColor: UIConstants.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltersBottomSheet(),
    );
  }

  Widget _buildFiltersBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: UIConstants.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(UIConstants.radiusLG),
          topRight: Radius.circular(UIConstants.radiusLG),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: UIConstants.spacingMD,
          right: UIConstants.spacingMD,
          top: UIConstants.spacingMD,
          bottom: MediaQuery.of(context).viewInsets.bottom + UIConstants.spacingMD,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltersHeader(),
            const SizedBox(height: UIConstants.spacingMD),
            _buildSortOptions(),
            const SizedBox(height: UIConstants.spacingMD),
            _buildStockFilter(),
            const SizedBox(height: UIConstants.spacingLG),
            _buildFiltersActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filtros',
          style: TextStyle(
            fontSize: UIConstants.fontSizeLG,
            fontWeight: UIConstants.fontWeightBold,
            color: UIConstants.textPrimary,
          ),
        ),
        Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return TextButton(
              onPressed: () {
                provider.clearFilters();
                Navigator.pop(context);
              },
              child: const Text(
                'Limpiar',
                style: TextStyle(color: UIConstants.primaryBlue),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ordenar por',
              style: TextStyle(
                fontSize: UIConstants.fontSizeMD,
                fontWeight: UIConstants.fontWeightMedium,
                color: UIConstants.textPrimary,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSM),
            Wrap(
              spacing: UIConstants.spacingSM,
              children: [
                _buildSortChip('Nombre', 'name', provider),
                _buildSortChip('Precio', 'price', provider),
                _buildSortChip('Popularidad', 'popularity', provider),
                _buildSortChip('Más recientes', 'created_at', provider),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortChip(String label, String value, ProductProvider provider) {
    final isSelected = provider.selectedSort == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        provider.applyFilters(sortBy: value);
      },
      selectedColor: UIConstants.primaryBlue.withOpacity(0.2),
      checkmarkColor: UIConstants.primaryBlue,
    );
  }

  Widget _buildStockFilter() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disponibilidad',
              style: TextStyle(
                fontSize: UIConstants.fontSizeMD,
                fontWeight: UIConstants.fontWeightMedium,
                color: UIConstants.textPrimary,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSM),
            CheckboxListTile(
              title: const Text('Solo productos en stock'),
              value: provider.inStockOnly ?? false,
              onChanged: (value) {
                provider.applyFilters(inStockOnly: value);
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltersActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: UIConstants.gray),
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
}
