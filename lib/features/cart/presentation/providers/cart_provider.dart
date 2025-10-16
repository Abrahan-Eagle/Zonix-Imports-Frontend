import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../data/datasources/cart_api_service.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/cart_summary_model.dart';

final logger = Logger();

class CartProvider with ChangeNotifier {
  final CartApiService _apiService = CartApiService();

  // Estado
  List<CartItemModel> _items = [];
  CartSummaryModel? _summary;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CartItemModel> get items => _items;
  CartSummaryModel? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;
  int get itemsCount => _summary?.itemsCount ?? 0;
  double get total => _summary?.total ?? 0;

  /// Cargar carrito
  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getCart();

      if (result['success'] == true) {
        _items = result['items'] ?? [];
        _summary = result['summary'];
        logger.i('✅ Carrito cargado: ${_items.length} items');
      } else {
        _error = result['error'];
        logger.e('❌ Error cargando carrito: $_error');
      }
    } catch (e) {
      _error = e.toString();
      logger.e('❌ Excepción cargando carrito: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Agregar item al carrito
  Future<bool> addItem({
    required int productId,
    required int quantity,
    String modality = 'retail',
  }) async {
    _error = null;

    try {
      final result = await _apiService.addItem(
        productId: productId,
        quantity: quantity,
        modality: modality,
      );

      if (result['success'] == true) {
        // Recargar carrito completo para tener datos actualizados
        await loadCart();
        logger.i('✅ Producto agregado exitosamente');
        return true;
      } else {
        _error = result['error'];
        logger.e('❌ Error agregando: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      logger.e('❌ Excepción agregando: $e');
      notifyListeners();
      return false;
    }
  }

  /// Actualizar cantidad
  Future<bool> updateQuantity(int cartItemId, int newQuantity) async {
    _error = null;

    try {
      final result = await _apiService.updateQuantity(cartItemId, newQuantity);

      if (result['success'] == true) {
        // Actualizar item en la lista local
        final index = _items.indexWhere((item) => item.id == cartItemId);
        if (index != -1) {
          _items[index] = result['cart_item'];
        }
        _summary = result['summary'];
        
        logger.i('✅ Cantidad actualizada');
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        logger.e('❌ Error actualizando: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      logger.e('❌ Excepción actualizando: $e');
      notifyListeners();
      return false;
    }
  }

  /// Incrementar cantidad
  Future<bool> incrementQuantity(int cartItemId) async {
    final item = _items.firstWhere((i) => i.id == cartItemId);
    return await updateQuantity(cartItemId, item.quantity + 1);
  }

  /// Decrementar cantidad
  Future<bool> decrementQuantity(int cartItemId) async {
    final item = _items.firstWhere((i) => i.id == cartItemId);
    if (item.quantity > 1) {
      return await updateQuantity(cartItemId, item.quantity - 1);
    }
    return false;
  }

  /// Eliminar item
  Future<bool> removeItem(int cartItemId) async {
    _error = null;

    try {
      final result = await _apiService.removeItem(cartItemId);

      if (result['success'] == true) {
        _items.removeWhere((item) => item.id == cartItemId);
        _summary = result['summary'];
        
        logger.i('✅ Item eliminado');
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        logger.e('❌ Error eliminando: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      logger.e('❌ Excepción eliminando: $e');
      notifyListeners();
      return false;
    }
  }

  /// Limpiar carrito
  Future<bool> clearCart() async {
    _error = null;

    try {
      final result = await _apiService.clearCart();

      if (result['success'] == true) {
        _items = [];
        _summary = CartSummaryModel(
          itemsCount: 0,
          subtotal: 0,
          shipping: 0,
          discount: 0,
          total: 0,
        );
        
        logger.i('✅ Carrito limpiado');
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        logger.e('❌ Error limpiando: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      logger.e('❌ Excepción limpiando: $e');
      notifyListeners();
      return false;
    }
  }

  /// Validar stock
  Future<Map<String, dynamic>> validateStock() async {
    try {
      final result = await _apiService.validateStock();
      
      if (result['success'] == true && result['valid'] == false) {
        _error = 'Hay productos con stock insuficiente';
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      logger.e('❌ Excepción validando: $e');
      return {
        'success': false,
        'valid': false,
        'error': e.toString(),
      };
    }
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refrescar carrito
  Future<void> refresh() async {
    await loadCart();
  }
}

