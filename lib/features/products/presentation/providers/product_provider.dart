import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/datasources/product_api_service.dart';
import '../../data/services/wishlist_service.dart';
import '../../data/services/filter_cache_service.dart';

/// Provider para manejo del estado de productos y categorías
class ProductProvider extends ChangeNotifier {
  static final Logger _logger = Logger();
  final ProductApiService _apiService = ProductApiService();
  final WishlistService _wishlistService = WishlistService();

  // Estados de carga
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;

  // Estados de error
  String? _error;
  String? _searchError;

  // Datos de productos
  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _relatedProducts = [];
  List<ProductModel> _searchResults = [];
  ProductModel? _selectedProduct;

  // Datos de categorías
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;

  // Datos de wishlist
  List<ProductModel> _wishlist = [];

  // Datos de búsqueda y filtros
  String _searchQuery = '';
  String _selectedSort = 'name';
  String _sortOrder = 'asc';
  int? _selectedCategoryId;
  String? _selectedBrand;
  double? _minPrice;
  double? _maxPrice;
  bool? _inStockOnly;

  // Cache de filtros
  FilterCache _filterCache = FilterCache();
  bool _cacheLoaded = false;

  // Paginación
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreProducts = true;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String? get searchError => _searchError;

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get relatedProducts => _relatedProducts;
  List<ProductModel> get searchResults => _searchResults;
  ProductModel? get selectedProduct => _selectedProduct;

  List<CategoryModel> get categories => _categories;
  CategoryModel? get selectedCategory => _selectedCategory;

  List<ProductModel> get wishlist => _wishlist;
  int get wishlistCount => _wishlist.length;

  String get searchQuery => _searchQuery;
  String get selectedSort => _selectedSort;

  // Getters para cache de filtros
  FilterCache get filterCache => _filterCache;
  bool get cacheLoaded => _cacheLoaded;
  bool get hasActiveFilters => _filterCache.hasActiveFilters;
  String get sortOrder => _sortOrder;
  int? get selectedCategoryId => _selectedCategoryId;
  String? get selectedBrand => _selectedBrand;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  bool? get inStockOnly => _inStockOnly;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMoreProducts => _hasMoreProducts;

  /// Cargar productos con filtros opcionales
  Future<void> loadProducts({
    bool refresh = false,
    Map<String, dynamic>? filters,
  }) async {
    try {
      _logger.i('🔄 Cargando productos... (refresh: $refresh)');

      if (refresh) {
        _isRefreshing = true;
        _currentPage = 1;
        _hasMoreProducts = true;
        _products.clear();
        _error = null;
      } else {
        _isLoading = true;
        _error = null;
      }

      notifyListeners();

      final result = await _apiService.getProducts(
        page: _currentPage,
        categoryId: _filterCache.selectedCategoryId ?? _selectedCategoryId,
        search: _filterCache.searchQuery.isNotEmpty
            ? _filterCache.searchQuery
            : (_searchQuery.isNotEmpty ? _searchQuery : null),
        sortBy: _filterCache.selectedSort ?? _selectedSort,
        sortOrder: _sortOrder,
        minPrice: _filterCache.minPrice ?? _minPrice,
        maxPrice: _filterCache.maxPrice ?? _maxPrice,
        brand: _selectedBrand,
        inStock: _filterCache.inStockOnly ?? _inStockOnly,
        modalities: _filterCache.selectedModalities.isNotEmpty
            ? _filterCache.selectedModalities
            : null,
        hasDiscount: _filterCache.hasDiscount ? true : null,
      );

      _logger.i('📊 Resultado de API: ${result['success']}');
      _logger.i('📊 Mensaje: ${result['message']}');

      if (result['success']) {
        final newProducts = result['products'] as List<ProductModel>;
        final pagination = result['pagination'] as Map<String, dynamic>?;

        _logger.i('📦 Productos recibidos: ${newProducts.length}');

        if (refresh || _currentPage == 1) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }

        if (pagination != null) {
          _currentPage = pagination['current_page'] ?? 1;
          _totalPages = pagination['last_page'] ?? 1;
          _hasMoreProducts = _currentPage < _totalPages;
          _logger.i('📄 Paginación: página $_currentPage de $_totalPages');
        }

        _error = null;
        _logger.i('✅ Productos cargados exitosamente: ${_products.length}');
      } else {
        _error = result['message'] ?? 'Error al cargar productos';
        _logger.e('❌ Error al cargar productos: $_error');
      }
    } catch (e) {
      _logger.e('❌ Error en loadProducts: $e');
      _error = 'Error de conexión al cargar productos';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Cargar más productos (paginación)
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreProducts) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      _currentPage++;
      await loadProducts();
    } catch (e) {
      _logger.e('Error en loadMoreProducts: $e');
      _currentPage--; // Revertir incremento en caso de error
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Obtener producto por ID
  Future<void> loadProductById(int productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _apiService.getProductById(productId);

      if (result['success']) {
        _selectedProduct = result['product'] as ProductModel;
        _error = null;
      } else {
        _error = result['message'] ?? 'Producto no encontrado';
        _selectedProduct = null;
      }
    } catch (e) {
      _logger.e('Error en loadProductById: $e');
      _error = 'Error de conexión al obtener producto';
      _selectedProduct = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar productos relacionados
  Future<void> loadRelatedProducts(int productId) async {
    try {
      final result = await _apiService.getRelatedProducts(productId);

      if (result['success']) {
        _relatedProducts = result['products'] as List<ProductModel>;
      } else {
        _relatedProducts = [];
      }
    } catch (e) {
      _logger.e('Error en loadRelatedProducts: $e');
      _relatedProducts = [];
    }
  }

  /// Cargar productos destacados
  Future<void> loadFeaturedProducts() async {
    try {
      final result = await _apiService.getFeaturedProducts();

      if (result['success']) {
        _featuredProducts = result['products'] as List<ProductModel>;
      } else {
        _featuredProducts = [];
      }
    } catch (e) {
      _logger.e('Error en loadFeaturedProducts: $e');
      _featuredProducts = [];
    }
  }

  /// Buscar productos
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _searchQuery = '';
      _searchError = null;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _searchError = null;
      _searchQuery = query.trim();
      notifyListeners();

      final result = await _apiService.searchProducts(_searchQuery);

      if (result['success']) {
        _searchResults = result['products'] as List<ProductModel>;
        _searchError = null;
      } else {
        _searchResults = [];
        _searchError = result['message'] ?? 'No se encontraron productos';
      }
    } catch (e) {
      _logger.e('Error en searchProducts: $e');
      _searchResults = [];
      _searchError = 'Error de conexión al buscar productos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar categorías
  Future<void> loadCategories() async {
    try {
      final result = await _apiService.getCategories();

      if (result['success']) {
        _categories = result['categories'] as List<CategoryModel>;
      } else {
        _categories = [];
      }
    } catch (e) {
      _logger.e('Error en loadCategories: $e');
      _categories = [];
    }
  }

  /// Obtener categoría por ID
  Future<void> loadCategoryById(int categoryId) async {
    try {
      final result = await _apiService.getCategoryById(categoryId);

      if (result['success']) {
        _selectedCategory = result['category'] as CategoryModel;
      } else {
        _selectedCategory = null;
      }
    } catch (e) {
      _logger.e('Error en loadCategoryById: $e');
      _selectedCategory = null;
    }
  }

  /// Aplicar filtros
  void applyFilters({
    int? categoryId,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    String? sortBy,
    String? sortOrder,
    List<String>? modalities,
    bool? hasDiscount,
  }) {
    _selectedCategoryId = categoryId;
    _selectedBrand = brand;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _inStockOnly = inStockOnly;
    _selectedSort = sortBy ?? _selectedSort;
    _sortOrder = sortOrder ?? _sortOrder;

    // Actualizar cache con modalidades y descuentos
    _filterCache = FilterCache(
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      selectedBrands: _filterCache.selectedBrands,
      selectedModalities: modalities ?? _filterCache.selectedModalities,
      selectedSort: _selectedSort,
      inStockOnly: _inStockOnly ?? false,
      hasDiscount: hasDiscount ?? _filterCache.hasDiscount,
      selectedCategoryId: _selectedCategoryId,
      searchQuery: _searchQuery,
    );

    // Guardar filtros en cache
    saveFiltersToCache();

    // Recargar productos con nuevos filtros
    loadProducts(refresh: true);
  }

  /// Limpiar filtros
  void clearFilters() {
    _selectedCategoryId = null;
    _selectedBrand = null;
    _minPrice = null;
    _maxPrice = null;
    _inStockOnly = null;
    _selectedSort = 'name';
    _sortOrder = 'asc';
    _searchQuery = '';
    _searchResults.clear();
    _searchError = null;

    // Limpiar cache de filtros
    clearFiltersCache();

    // Recargar productos sin filtros
    loadProducts(refresh: true);
  }

  /// Limpiar búsqueda
  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    _searchError = null;
    notifyListeners();
  }

  /// Refrescar datos
  Future<void> refresh() async {
    _logger.i('🔄 Iniciando refresh de productos...');
    await Future.wait([
      loadProducts(refresh: true),
      loadCategories(),
      loadFeaturedProducts(),
    ]);
    _logger.i('✅ Refresh completado. Productos cargados: ${_products.length}');
  }

  /// Limpiar estado
  void clearState() {
    _products.clear();
    _featuredProducts.clear();
    _relatedProducts.clear();
    _searchResults.clear();
    _categories.clear();
    _selectedProduct = null;
    _selectedCategory = null;
    _searchQuery = '';
    _error = null;
    _searchError = null;
    _currentPage = 1;
    _totalPages = 1;
    _hasMoreProducts = true;
    notifyListeners();
  }

  /// Verificar si hay productos
  bool get hasProducts => _products.isNotEmpty;

  /// Verificar si hay productos destacados
  bool get hasFeaturedProducts => _featuredProducts.isNotEmpty;

  /// Verificar si hay resultados de búsqueda
  bool get hasSearchResults => _searchResults.isNotEmpty;

  /// Verificar si hay categorías
  bool get hasCategories => _categories.isNotEmpty;

  /// Verificar si hay filtros activos (método legacy)
  bool get hasActiveFiltersLegacy =>
      _selectedCategoryId != null ||
      _selectedBrand != null ||
      _minPrice != null ||
      _maxPrice != null ||
      _inStockOnly != null ||
      _selectedSort != 'name' ||
      _sortOrder != 'asc';

  /// Obtener categorías principales
  List<CategoryModel> get mainCategories =>
      _categories.where((cat) => cat.isMainCategory).toList();

  /// Obtener subcategorías de una categoría
  List<CategoryModel> getSubCategories(int parentId) =>
      _categories.where((cat) => cat.parentId == parentId).toList();

  /// Cargar wishlist
  Future<void> loadWishlist() async {
    try {
      _wishlist = await _wishlistService.getWishlist();
      notifyListeners();
    } catch (e) {
      _logger.e('Error al cargar wishlist: $e');
    }
  }

  /// Cargar filtros desde cache
  Future<void> loadFiltersFromCache() async {
    if (_cacheLoaded) return;

    try {
      _logger.d('🔄 Cargando filtros desde cache...');
      final cachedFilters = await FilterCacheService.loadFiltersOrDefault();

      // Aplicar filtros cargados
      _filterCache = cachedFilters;
      _searchQuery = cachedFilters.searchQuery;
      _selectedSort = cachedFilters.selectedSort ?? 'name';
      _selectedCategoryId = cachedFilters.selectedCategoryId;
      _minPrice = cachedFilters.minPrice;
      _maxPrice = cachedFilters.maxPrice;
      _inStockOnly = cachedFilters.inStockOnly;

      _cacheLoaded = true;
      _logger.d('✅ Filtros cargados desde cache: ${cachedFilters.toString()}');

      // Aplicar filtros automáticamente si hay filtros activos
      if (cachedFilters.hasActiveFilters) {
        _logger.d('🔄 Aplicando filtros desde cache automáticamente...');
        await loadProducts(refresh: true);
      }

      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error cargando filtros desde cache: $e');
      _cacheLoaded = true; // Marcar como cargado para evitar reintentos
    }
  }

  /// Guardar filtros en cache
  Future<void> saveFiltersToCache() async {
    try {
      _filterCache = FilterCache(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        selectedBrands: _selectedBrand != null ? [_selectedBrand!] : [],
        selectedModalities: [], // TODO: Implementar cuando se agregue
        selectedSort: _selectedSort,
        inStockOnly: _inStockOnly ?? false,
        hasDiscount: false, // TODO: Implementar cuando se agregue
        selectedCategoryId: _selectedCategoryId,
        searchQuery: _searchQuery,
      );

      await FilterCacheService.saveFilters(_filterCache);
      _logger.d('💾 Filtros guardados en cache');
    } catch (e) {
      _logger.e('❌ Error guardando filtros en cache: $e');
    }
  }

  /// Limpiar cache de filtros
  Future<void> clearFiltersCache() async {
    try {
      await FilterCacheService.clearFilters();
      _filterCache = FilterCache();
      _logger.d('🗑️ Cache de filtros limpiado');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error limpiando cache de filtros: $e');
    }
  }

  /// Toggle wishlist
  Future<bool> toggleWishlist(ProductModel product) async {
    try {
      final success = await _wishlistService.toggleWishlist(product);
      if (success) {
        await loadWishlist();
      }
      return success;
    } catch (e) {
      _logger.e('Error al toggle wishlist: $e');
      return false;
    }
  }

  /// Verificar si un producto está en wishlist
  Future<bool> isInWishlist(int productId) async {
    return await _wishlistService.isInWishlist(productId);
  }

  /// Limpiar wishlist
  Future<void> clearWishlist() async {
    try {
      await _wishlistService.clearWishlist();
      _wishlist.clear();
      notifyListeners();
    } catch (e) {
      _logger.e('Error al limpiar wishlist: $e');
    }
  }

  /// Obtener productos similares de la wishlist
  Future<List<ProductModel>> getSimilarWishlistProducts(ProductModel product,
      {int limit = 3}) async {
    try {
      return await _wishlistService.getSimilarProducts(product, limit: limit);
    } catch (e) {
      _logger.e('Error al obtener productos similares de wishlist: $e');
      return [];
    }
  }

  /// Exportar wishlist
  Future<String?> exportWishlist() async {
    try {
      return await _wishlistService.exportWishlist();
    } catch (e) {
      _logger.e('Error al exportar wishlist: $e');
      return null;
    }
  }

  /// Importar wishlist
  Future<bool> importWishlist(String jsonData) async {
    try {
      final success = await _wishlistService.importWishlist(jsonData);
      if (success) {
        await loadWishlist();
      }
      return success;
    } catch (e) {
      _logger.e('Error al importar wishlist: $e');
      return false;
    }
  }
}
