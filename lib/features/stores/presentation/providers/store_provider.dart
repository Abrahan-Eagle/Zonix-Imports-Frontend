import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../data/datasources/store_api_service.dart';
import '../../data/models/store_model.dart';
import '../../../products/data/models/product_model.dart';

final logger = Logger();

class StoreProvider with ChangeNotifier {
  final StoreApiService _apiService = StoreApiService();

  // Estado
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Tiendas
  List<StoreModel> _stores = [];
  StoreModel? _selectedStore;
  List<ProductModel> _storeProducts = [];

  // Paginación
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;

  // Filtros
  bool? _onlyOpen;
  String? _businessType;
  String? _searchQuery;
  String _sortBy = 'business_name';
  String _sortOrder = 'asc';

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  List<StoreModel> get stores => _stores;
  StoreModel? get selectedStore => _selectedStore;
  List<ProductModel> get storeProducts => _storeProducts;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasMore => _currentPage < _lastPage;

  /// Cargar lista de tiendas
  Future<void> loadStores({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _stores = [];
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getStores(
        page: _currentPage,
        perPage: 20,
        onlyOpen: _onlyOpen,
        businessType: _businessType,
        search: _searchQuery,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      if (result['success'] == true) {
        final newStores = result['stores'] as List<StoreModel>;

        if (refresh) {
          _stores = newStores;
        } else {
          _stores.addAll(newStores);
        }

        if (result['meta'] != null) {
          _currentPage = result['meta']['current_page'] ?? 1;
          _lastPage = result['meta']['last_page'] ?? 1;
          _total = result['meta']['total'] ?? 0;
        }

        logger.i('✅ Tiendas cargadas: ${_stores.length}');
      } else {
        _error = result['error'] ?? 'Error al cargar tiendas';
        logger.e('❌ Error: $_error');
      }
    } catch (e) {
      _error = e.toString();
      logger.e('❌ Excepción: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Cargar más tiendas (paginación)
  Future<void> loadMoreStores() async {
    if (!hasMore || _isLoadingMore) return;

    _currentPage++;
    await loadStores();
  }

  /// Obtener detalles de una tienda
  Future<void> getStoreDetails(int storeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getStoreDetails(storeId);

      if (result['success'] == true) {
        _selectedStore = result['store'];
        logger.i('✅ Tienda cargada: ${_selectedStore?.businessName}');
      } else {
        _error = result['error'] ?? 'Error al cargar tienda';
        logger.e('❌ Error: $_error');
      }
    } catch (e) {
      _error = e.toString();
      logger.e('❌ Excepción: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar productos de una tienda
  Future<void> loadStoreProducts(int storeId, {bool refresh = false}) async {
    if (refresh) {
      _storeProducts = [];
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getStoreProducts(storeId);

      if (result['success'] == true) {
        _storeProducts = result['products'];
        logger.i('✅ Productos cargados: ${_storeProducts.length}');
      } else {
        _error = result['error'] ?? 'Error al cargar productos';
        logger.e('❌ Error: $_error');
      }
    } catch (e) {
      _error = e.toString();
      logger.e('❌ Excepción: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Aplicar filtros
  void applyFilters({
    bool? onlyOpen,
    String? businessType,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) {
    bool hasChanges = false;

    if (onlyOpen != _onlyOpen) {
      _onlyOpen = onlyOpen;
      hasChanges = true;
    }

    if (businessType != _businessType) {
      _businessType = businessType;
      hasChanges = true;
    }

    if (search != _searchQuery) {
      _searchQuery = search;
      hasChanges = true;
    }

    if (sortBy != null && sortBy != _sortBy) {
      _sortBy = sortBy;
      hasChanges = true;
    }

    if (sortOrder != null && sortOrder != _sortOrder) {
      _sortOrder = sortOrder;
      hasChanges = true;
    }

    if (hasChanges) {
      loadStores(refresh: true);
    }
  }

  /// Limpiar filtros
  void clearFilters() {
    _onlyOpen = null;
    _businessType = null;
    _searchQuery = null;
    _sortBy = 'business_name';
    _sortOrder = 'asc';
    loadStores(refresh: true);
  }

  /// Limpiar tienda seleccionada
  void clearSelectedStore() {
    _selectedStore = null;
    _storeProducts = [];
    notifyListeners();
  }
}
