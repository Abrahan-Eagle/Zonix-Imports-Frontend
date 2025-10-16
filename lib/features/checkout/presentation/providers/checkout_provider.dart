import 'package:flutter/material.dart';
import 'package:zonix/features/checkout/data/datasources/checkout_api_service.dart';
import 'package:zonix/features/checkout/data/models/checkout_summary_model.dart';
import 'package:zonix/features/checkout/data/models/order_model.dart';
import 'package:zonix/features/checkout/data/models/address_model.dart';
import 'package:zonix/features/cart/data/models/cart_item_model.dart';

class CheckoutProvider with ChangeNotifier {
  final CheckoutApiService _checkoutApiService = CheckoutApiService();

  // Estado del checkout
  bool _isLoading = false;
  String? _error;
  CheckoutSummaryModel? _checkoutSummary;
  List<CartItemModel> _cartItems = [];
  AddressModel? _selectedShippingAddress;
  AddressModel? _selectedBillingAddress;
  String _deliveryType = 'delivery'; // delivery | pickup
  String? _notes;
  OrderModel? _createdOrder;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  CheckoutSummaryModel? get checkoutSummary => _checkoutSummary;
  List<CartItemModel> get cartItems => _cartItems;
  AddressModel? get selectedShippingAddress => _selectedShippingAddress;
  AddressModel? get selectedBillingAddress => _selectedBillingAddress;
  String get deliveryType => _deliveryType;
  String? get notes => _notes;
  OrderModel? get createdOrder => _createdOrder;

  bool get isReadyToCheckout {
    return _selectedShippingAddress != null && 
           _cartItems.isNotEmpty &&
           !_isLoading;
  }

  /// Cargar resumen de checkout
  Future<void> loadCheckoutSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _checkoutApiService.getCheckoutSummary();

      if (result['success'] == true) {
        _cartItems = result['cart_items'] as List<CartItemModel>;
        _checkoutSummary = result['summary'] as CheckoutSummaryModel;
        _error = null;
      } else {
        _error = result['message'] as String? ?? 'Carrito vacío';
        _cartItems = [];
        _checkoutSummary = null;
      }
    } catch (e) {
      _error = 'Error al cargar resumen: $e';
      _cartItems = [];
      _checkoutSummary = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Seleccionar dirección de envío
  void setShippingAddress(AddressModel address) {
    _selectedShippingAddress = address;
    notifyListeners();
  }

  /// Seleccionar dirección de facturación
  void setBillingAddress(AddressModel? address) {
    _selectedBillingAddress = address;
    notifyListeners();
  }

  /// Cambiar tipo de entrega
  void setDeliveryType(String type) {
    if (type == 'delivery' || type == 'pickup') {
      _deliveryType = type;
      notifyListeners();
      
      // Recalcular resumen si es necesario
      loadCheckoutSummary();
    }
  }

  /// Agregar notas
  void setNotes(String? notesText) {
    _notes = notesText;
    notifyListeners();
  }

  /// Iniciar checkout (validar)
  Future<bool> initiateCheckout() async {
    if (_selectedShippingAddress == null) {
      _error = 'Debe seleccionar una dirección de envío';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _checkoutApiService.initiateCheckout(
        shippingAddressId: _selectedShippingAddress!.id,
        deliveryType: _deliveryType,
        billingAddressId: _selectedBillingAddress?.id,
      );

      if (result['success'] == true) {
        _checkoutSummary = result['summary'] as CheckoutSummaryModel;
        _cartItems = result['cart_items'] as List<CartItemModel>;
        _error = null;
        return true;
      } else {
        _error = 'Error al validar checkout';
        return false;
      }
    } catch (e) {
      _error = 'Error al validar checkout: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Confirmar checkout y crear orden
  Future<OrderModel?> confirmCheckout() async {
    if (_selectedShippingAddress == null) {
      _error = 'Debe seleccionar una dirección de envío';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _checkoutApiService.confirmCheckout(
        shippingAddressId: _selectedShippingAddress!.id,
        deliveryType: _deliveryType,
        billingAddressId: _selectedBillingAddress?.id,
        notes: _notes,
      );

      _createdOrder = order;
      _error = null;

      // Limpiar estado después de crear la orden
      _cartItems = [];
      _checkoutSummary = null;

      return order;
    } catch (e) {
      _error = 'Error al crear orden: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reiniciar estado
  void reset() {
    _isLoading = false;
    _error = null;
    _checkoutSummary = null;
    _cartItems = [];
    _selectedShippingAddress = null;
    _selectedBillingAddress = null;
    _deliveryType = 'delivery';
    _notes = null;
    _createdOrder = null;
    notifyListeners();
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

