import 'package:flutter/material.dart';
import 'package:zonix/features/payments/data/datasources/payment_api_service.dart';
import 'package:zonix/features/payments/data/models/payment_model.dart';
import 'package:zonix/features/payments/data/models/payment_method_model.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentApiService _paymentApiService = PaymentApiService();

  // Estado
  bool _isLoading = false;
  String? _error;
  List<PaymentMethodModel> _paymentMethods = [];
  PaymentModel? _currentPayment;
  String? _selectedPaymentMethod;

  // Datos específicos por método
  String? _clientSecret; // Stripe
  String? _approvalUrl; // PayPal
  String? _checkoutUrl; // Binance

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  PaymentModel? get currentPayment => _currentPayment;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  String? get clientSecret => _clientSecret;
  String? get approvalUrl => _approvalUrl;
  String? get checkoutUrl => _checkoutUrl;

  bool get hasPaymentMethods => _paymentMethods.isNotEmpty;

  /// Cargar métodos de pago disponibles
  Future<void> loadPaymentMethods(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _paymentMethods = await _paymentApiService.getPaymentMethods(orderId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar métodos de pago: $e';
      _paymentMethods = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Seleccionar método de pago
  void selectPaymentMethod(String methodId) {
    _selectedPaymentMethod = methodId;
    _error = null;
    notifyListeners();
  }

  /// Iniciar proceso de pago
  Future<bool> initiatePayment({
    required int orderId,
    required String paymentMethod,
    String? currency,
    String? cryptoCurrency,
  }) async {
    if (paymentMethod.isEmpty) {
      _error = 'Debe seleccionar un método de pago';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentApiService.initiatePayment(
        orderId: orderId,
        paymentMethod: paymentMethod,
        currency: currency,
        cryptoCurrency: cryptoCurrency,
      );

      if (result['success'] == true) {
        _currentPayment = result['payment'] as PaymentModel;
        
        // Guardar datos específicos según el método
        _clientSecret = result['client_secret'] as String?;
        _approvalUrl = result['approval_url'] as String?;
        _checkoutUrl = result['checkout_url'] as String?;
        
        _error = null;
        return true;
      } else {
        _error = 'Error al iniciar pago';
        return false;
      }
    } catch (e) {
      _error = 'Error al iniciar pago: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registrar pago manual
  Future<PaymentModel?> submitManualPayment({
    required int orderId,
    required String paymentMethod,
    required String receiptUrl,
    String? reference,
    String? bank,
    String? phone,
    String? account,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payment = await _paymentApiService.submitManualPayment(
        orderId: orderId,
        paymentMethod: paymentMethod,
        receiptUrl: receiptUrl,
        reference: reference,
        bank: bank,
        phone: phone,
        account: account,
      );

      _currentPayment = payment;
      _error = null;
      return payment;
    } catch (e) {
      _error = 'Error al registrar pago manual: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verificar estado de un pago
  Future<void> checkPaymentStatus(int paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentApiService.checkPaymentStatus(paymentId);

      if (result['success'] == true) {
        _currentPayment = result['payment'] as PaymentModel;
        _error = null;
      } else {
        _error = 'Error al verificar estado';
      }
    } catch (e) {
      _error = 'Error al verificar estado: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reiniciar estado
  void reset() {
    _isLoading = false;
    _error = null;
    _paymentMethods = [];
    _currentPayment = null;
    _selectedPaymentMethod = null;
    _clientSecret = null;
    _approvalUrl = null;
    _checkoutUrl = null;
    notifyListeners();
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

