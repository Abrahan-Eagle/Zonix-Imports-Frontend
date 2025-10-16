import 'package:flutter/material.dart';
import 'package:zonix/features/orders/data/datasources/order_api_service.dart';
import 'package:zonix/features/checkout/data/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final OrderApiService _orderApiService = OrderApiService();

  // Estado
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _orders = [];
  OrderModel? _currentOrder;
  Map<String, dynamic>? _tracking;
  Map<String, dynamic>? _pagination;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get orders => _orders;
  OrderModel? get currentOrder => _currentOrder;
  Map<String, dynamic>? get tracking => _tracking;
  Map<String, dynamic>? get pagination => _pagination;

  bool get hasOrders => _orders.isNotEmpty;
  bool get hasMorePages => 
      _pagination != null && 
      (_pagination!['current_page'] as int) < (_pagination!['last_page'] as int);

  /// Cargar lista de órdenes
  Future<void> loadOrders({
    String? status,
    String? modality,
    int page = 1,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _orderApiService.getBuyerOrders(
        status: status,
        modality: modality,
        page: page,
      );

      if (result['success'] == true) {
        _orders = result['orders'] as List<Map<String, dynamic>>;
        _pagination = result['pagination'] as Map<String, dynamic>;
        _error = null;
      } else {
        _error = 'Error al cargar órdenes';
        _orders = [];
      }
    } catch (e) {
      _error = 'Error al cargar órdenes: $e';
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar más órdenes (paginación)
  Future<void> loadMoreOrders({String? status, String? modality}) async {
    if (!hasMorePages || _isLoading) return;

    final nextPage = (_pagination!['current_page'] as int) + 1;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _orderApiService.getBuyerOrders(
        status: status,
        modality: modality,
        page: nextPage,
      );

      if (result['success'] == true) {
        final newOrders = result['orders'] as List<Map<String, dynamic>>;
        _orders.addAll(newOrders);
        _pagination = result['pagination'] as Map<String, dynamic>;
        _error = null;
      }
    } catch (e) {
      _error = 'Error al cargar más órdenes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar detalle de una orden
  Future<void> loadOrderDetail(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentOrder = await _orderApiService.getOrderDetail(orderId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar detalle: $e';
      _currentOrder = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar tracking de una orden
  Future<void> loadOrderTracking(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tracking = await _orderApiService.getOrderTracking(orderId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar tracking: $e';
      _tracking = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refrescar órdenes
  Future<void> refreshOrders({String? status, String? modality}) async {
    await loadOrders(status: status, modality: modality, page: 1);
  }

  /// Reiniciar estado
  void reset() {
    _isLoading = false;
    _error = null;
    _orders = [];
    _currentOrder = null;
    _tracking = null;
    _pagination = null;
    notifyListeners();
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

