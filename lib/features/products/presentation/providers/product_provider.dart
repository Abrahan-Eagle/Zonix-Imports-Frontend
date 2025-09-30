import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/datasources/product_api_service.dart';

/// Provider para manejo del estado de productos y categorías
class ProductProvider extends ChangeNotifier {
  static final Logger _logger = Logger();
  final ProductApiService _apiService = ProductApiService();

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

  // Datos de búsqueda y filtros
  String _searchQuery = '';
  String _selectedSort = 'name';
  String _sortOrder = 'asc';
  int? _selectedCategoryId;
  String? _selectedBrand;
  double? _minPrice;
  double? _maxPrice;
  bool? _inStockOnly;

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

  String get searchQuery => _searchQuery;
  String get selectedSort => _selectedSort;
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
        categoryId: _selectedCategoryId,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _selectedSort,
        sortOrder: _sortOrder,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        brand: _selectedBrand,
        inStock: _inStockOnly,
      );

      if (result['success']) {
        final newProducts = result['products'] as List<ProductModel>;
        final pagination = result['pagination'] as Map<String, dynamic>?;

        if (refresh || _currentPage == 1) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }

        if (pagination != null) {
          _currentPage = pagination['current_page'] ?? 1;
          _totalPages = pagination['last_page'] ?? 1;
          _hasMoreProducts = _currentPage < _totalPages;
        }

        _error = null;
      } else {
        _error = result['message'] ?? 'Error al cargar productos';
      }
    } catch (e) {
      _logger.e('Error en loadProducts: $e');
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
  }) {
    _selectedCategoryId = categoryId;
    _selectedBrand = brand;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _inStockOnly = inStockOnly;
    _selectedSort = sortBy ?? _selectedSort;
    _sortOrder = sortOrder ?? _sortOrder;

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
    await Future.wait([
      loadProducts(refresh: true),
      loadCategories(),
      loadFeaturedProducts(),
    ]);
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

  /// Obtener categorías principales
  List<CategoryModel> get mainCategories => 
      _categories.where((cat) => cat.isMainCategory).toList();

  /// Obtener subcategorías de una categoría
  List<CategoryModel> getSubCategories(int parentId) => 
      _categories.where((cat) => cat.parentId == parentId).toList();
}
