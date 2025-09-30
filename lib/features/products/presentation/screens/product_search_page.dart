import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/product_list.dart';
import 'product_detail_page.dart';

/// Página de búsqueda de productos
class ProductSearchPage extends StatefulWidget {
  final String? initialQuery;

  const ProductSearchPage({
    super.key,
    this.initialQuery,
  });

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _currentQuery = '';
  List<String> _recentSearches = [];
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _currentQuery = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
    
    _loadRecentSearches();
    _loadSuggestions();
    
    // Enfocar el campo de búsqueda automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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
          Expanded(
            child: _buildSearchContent(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Buscar productos',
        style: TextStyle(
          color: UIConstants.textPrimary,
          fontWeight: UIConstants.fontWeightBold,
        ),
      ),
      backgroundColor: UIConstants.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _showFilters,
          icon: const Icon(
            Icons.tune,
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Buscar productos, marcas, categorías...',
                prefixIcon: const Icon(Icons.search, color: UIConstants.gray),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
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
              onSubmitted: _performSearch,
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: UIConstants.spacingSM),
          ElevatedButton(
            onPressed: () => _performSearch(_searchController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIConstants.primaryBlue,
              foregroundColor: UIConstants.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusMD),
              ),
              padding: const EdgeInsets.all(UIConstants.spacingSM),
            ),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (_currentQuery.isEmpty) {
          return _buildSearchSuggestions();
        }

        if (provider.isLoading && provider.searchResults.isEmpty) {
          return _buildLoadingState();
        }

        if (provider.searchError != null && provider.searchResults.isEmpty) {
          return _buildErrorState(provider.searchError!);
        }

        if (provider.searchResults.isEmpty) {
          return _buildNoResultsState();
        }

        return _buildSearchResults(provider);
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionTitle('Búsquedas recientes'),
            const SizedBox(height: UIConstants.spacingSM),
            _buildRecentSearches(),
            const SizedBox(height: UIConstants.spacingLG),
          ],
          _buildSectionTitle('Sugerencias'),
          const SizedBox(height: UIConstants.spacingSM),
          _buildSuggestions(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: UIConstants.fontSizeLG,
        fontWeight: UIConstants.fontWeightBold,
        color: UIConstants.textPrimary,
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Wrap(
      spacing: UIConstants.spacingSM,
      runSpacing: UIConstants.spacingSM,
      children: _recentSearches.map((search) {
        return _buildSearchChip(
          search,
          () => _performSearch(search),
          Icons.history,
        );
      }).toList(),
    );
  }

  Widget _buildSuggestions() {
    return Wrap(
      spacing: UIConstants.spacingSM,
      runSpacing: UIConstants.spacingSM,
      children: _suggestions.map((suggestion) {
        return _buildSearchChip(
          suggestion,
          () => _performSearch(suggestion),
          Icons.trending_up,
        );
      }).toList(),
    );
  }

  Widget _buildSearchChip(String label, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.radiusLG),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingMD,
          vertical: UIConstants.spacingSM,
        ),
        decoration: BoxDecoration(
          color: UIConstants.white,
          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
          border: Border.all(color: UIConstants.grayMedium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: UIConstants.iconSizeSM,
              color: UIConstants.textSecondary,
            ),
            const SizedBox(width: UIConstants.spacingXS),
            Text(
              label,
              style: const TextStyle(
                color: UIConstants.textPrimary,
                fontSize: UIConstants.fontSizeSM,
              ),
            ),
          ],
        ),
      ),
    );
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
            'Buscando productos...',
            style: TextStyle(
              color: UIConstants.textSecondary,
              fontSize: UIConstants.fontSizeMD,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
            error,
            style: const TextStyle(
              color: UIConstants.error,
              fontSize: UIConstants.fontSizeMD,
              fontWeight: UIConstants.fontWeightMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingMD),
          ElevatedButton.icon(
            onPressed: () => _performSearch(_searchController.text),
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

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: UIConstants.iconSizeXL,
            color: UIConstants.gray,
          ),
          const SizedBox(height: UIConstants.spacingMD),
          const Text(
            'No se encontraron productos',
            style: TextStyle(
              color: UIConstants.textSecondary,
              fontSize: UIConstants.fontSizeMD,
              fontWeight: UIConstants.fontWeightMedium,
            ),
          ),
          const SizedBox(height: UIConstants.spacingSM),
          Text(
            'Intenta con otros términos de búsqueda',
            style: const TextStyle(
              color: UIConstants.textSecondary,
              fontSize: UIConstants.fontSizeSM,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingLG),
          ElevatedButton.icon(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar búsqueda'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIConstants.primaryBlue,
              foregroundColor: UIConstants.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ProductProvider provider) {
    return Column(
      children: [
        // Header con resultados
        Container(
          color: UIConstants.white,
          padding: const EdgeInsets.all(UIConstants.spacingSM),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${provider.searchResults.length} resultado${provider.searchResults.length != 1 ? 's' : ''} para "$_currentQuery"',
                  style: const TextStyle(
                    color: UIConstants.textSecondary,
                    fontSize: UIConstants.fontSizeSM,
                  ),
                ),
              ),
              TextButton(
                onPressed: _showFilters,
                child: const Text('Filtros'),
              ),
            ],
          ),
        ),
        
        // Lista de productos
        Expanded(
          child: ProductList(
            products: provider.searchResults,
            isLoading: provider.isLoading,
            error: provider.searchError,
            onProductTap: _navigateToProductDetail,
            onAddToCart: _addToCart,
            onAddToFavorites: _addToFavorites,
          ),
        ),
      ],
    );
  }

  void _onSearchChanged(String value) {
    setState(() {});
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _currentQuery = query.trim();
    });

    // Agregar a búsquedas recientes
    _addToRecentSearches(query.trim());

    // Realizar búsqueda
    final productProvider = context.read<ProductProvider>();
    productProvider.searchProducts(query.trim());
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentQuery = '';
    });
    
    final productProvider = context.read<ProductProvider>();
    productProvider.clearSearch();
  }

  void _addToRecentSearches(String query) {
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    
    // Limitar a 10 búsquedas recientes
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList();
    }
    
    _saveRecentSearches();
  }

  void _loadRecentSearches() {
    // TODO: Cargar desde SharedPreferences
    _recentSearches = [
      'iPhone',
      'Samsung Galaxy',
      'Laptop',
      'Auriculares',
      'Cámara',
    ];
  }

  void _saveRecentSearches() {
    // TODO: Guardar en SharedPreferences
  }

  void _loadSuggestions() {
    // TODO: Cargar sugerencias desde API o datos locales
    _suggestions = [
      'Electrónicos',
      'Ropa',
      'Hogar',
      'Deportes',
      'Libros',
      'Música',
      'Juguetes',
      'Belleza',
    ];
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

  void _showFilters() {
    // TODO: Mostrar modal de filtros
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de filtros próximamente'),
        backgroundColor: UIConstants.info,
      ),
    );
  }
}
