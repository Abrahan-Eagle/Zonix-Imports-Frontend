import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zonix/core/config/app_config.dart';
import 'package:logger/logger.dart';
import 'package:zonix/features/payments/data/models/payment_model.dart';
import 'package:zonix/features/payments/data/models/payment_method_model.dart';

class PaymentApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();
  final String baseUrl = AppConfig.baseUrl;

  /// Obtener métodos de pago disponibles para una orden
  Future<List<PaymentMethodModel>> getPaymentMethods(int orderId) async {
    try {
      _logger.i('💳 Obteniendo métodos de pago para orden $orderId');
      
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/buyer/payments/methods?order_id=$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          final methods = (data['data']['methods'] as List<dynamic>)
              .map((method) => PaymentMethodModel.fromJson(method as Map<String, dynamic>))
              .toList();
          
          _logger.i('✅ Métodos de pago obtenidos: ${methods.length}');
          return methods;
        } else {
          throw Exception(data['message'] ?? 'Error al obtener métodos');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error obteniendo métodos de pago: $e');
      rethrow;
    }
  }

  /// Iniciar proceso de pago
  Future<Map<String, dynamic>> initiatePayment({
    required int orderId,
    required String paymentMethod,
    String? currency,
    String? cryptoCurrency,
  }) async {
    try {
      _logger.i('🚀 Iniciando pago: $paymentMethod para orden $orderId');
      
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final body = {
        'order_id': orderId,
        'payment_method': paymentMethod,
        if (currency != null) 'currency': currency,
        if (cryptoCurrency != null) 'crypto_currency': cryptoCurrency,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/buyer/payments/initiate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          final responseData = data['data'] as Map<String, dynamic>;
          
          _logger.i('✅ Pago iniciado exitosamente');
          
          return {
            'success': true,
            'payment': PaymentModel.fromJson(responseData['payment'] as Map<String, dynamic>),
            'client_secret': responseData['client_secret'] as String?,
            'payment_intent_id': responseData['payment_intent_id'] as String?,
            'approval_url': responseData['approval_url'] as String?,
            'paypal_order_id': responseData['paypal_order_id'] as String?,
            'checkout_url': responseData['checkout_url'] as String?,
            'binance_order_id': responseData['binance_order_id'] as String?,
          };
        } else {
          throw Exception(data['message'] ?? 'Error al iniciar pago');
        }
      } else if (response.statusCode == 400 || response.statusCode == 422) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(data['message'] ?? 'Error al iniciar pago');
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error iniciando pago: $e');
      rethrow;
    }
  }

  /// Registrar pago manual
  Future<PaymentModel> submitManualPayment({
    required int orderId,
    required String paymentMethod,
    required String receiptUrl,
    String? reference,
    String? bank,
    String? phone,
    String? account,
  }) async {
    try {
      _logger.i('📄 Registrando pago manual: $paymentMethod');
      
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final body = {
        'order_id': orderId,
        'payment_method': paymentMethod,
        'receipt_url': receiptUrl,
        if (reference != null) 'reference': reference,
        if (bank != null) 'bank': bank,
        if (phone != null) 'phone': phone,
        if (account != null) 'account': account,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/buyer/payments/manual'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      _logger.d('Response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          final paymentData = data['data']['payment'] as Map<String, dynamic>;
          _logger.i('✅ Pago manual registrado');
          
          return PaymentModel.fromJson(paymentData);
        } else {
          throw Exception(data['message'] ?? 'Error al registrar pago');
        }
      } else {
        final data = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(data['message'] ?? 'Error al registrar pago');
      }
    } catch (e) {
      _logger.e('❌ Error registrando pago manual: $e');
      rethrow;
    }
  }

  /// Verificar estado de un pago
  Future<Map<String, dynamic>> checkPaymentStatus(int paymentId) async {
    try {
      _logger.i('🔍 Verificando estado del pago $paymentId');
      
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/buyer/payments/$paymentId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      _logger.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          final responseData = data['data'] as Map<String, dynamic>;
          
          return {
            'success': true,
            'payment': PaymentModel.fromJson(responseData['payment'] as Map<String, dynamic>),
            'order': responseData['order'] as Map<String, dynamic>,
          };
        } else {
          throw Exception(data['message'] ?? 'Error al verificar estado');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error verificando estado de pago: $e');
      rethrow;
    }
  }
}

