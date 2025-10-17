import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zonix/core/config/app_config.dart';
import 'package:logger/logger.dart';
import 'package:zonix/features/checkout/data/models/checkout_summary_model.dart';
import 'package:zonix/features/checkout/data/models/order_model.dart';
import 'package:zonix/features/checkout/data/models/address_model.dart';
import 'package:zonix/features/cart/data/models/cart_item_model.dart';

class CheckoutApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();
  final String baseUrl = AppConfig.baseUrl;

  /// Obtener resumen de checkout
  Future<Map<String, dynamic>> getCheckoutSummary() async {
    try {
      _logger.i('🛒 Obteniendo resumen de checkout');
      
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/buyer/checkout/summary'),
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
          final responseData = data['data'] as Map<String, dynamic>;
          
          return {
            'success': true,
            'cart_items': (responseData['cart_items'] as List<dynamic>)
                .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
                .toList(),
            'summary': CheckoutSummaryModel.fromJson(
              responseData['summary'] as Map<String, dynamic>
            ),
          };
        } else {
          _logger.w('⚠️ Checkout summary failed: ${data['message']}');
          throw Exception(data['message'] ?? 'Error al obtener resumen');
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'message': data['message'] ?? 'Carrito vacío',
        };
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error obteniendo resumen de checkout: $e');
      rethrow;
    }
  }

  /// Iniciar checkout (validar datos)
  Future<Map<String, dynamic>> initiateCheckout({
    required int shippingAddressId,
    required String deliveryType,
    int? billingAddressId,
  }) async {
    try {
      _logger.i('🚀 Iniciando checkout');
      _logger.d('Shipping Address ID: $shippingAddressId');
      _logger.d('Delivery Type: $deliveryType');
      
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final body = {
        'shipping_address_id': shippingAddressId,
        'delivery_type': deliveryType,
        if (billingAddressId != null) 'billing_address_id': billingAddressId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/buyer/checkout/initiate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          final responseData = data['data'] as Map<String, dynamic>;
          
          return {
            'success': true,
            'shipping_address': AddressModel.fromJson(
              responseData['shipping_address'] as Map<String, dynamic>
            ),
            'billing_address': responseData['billing_address'] != null
                ? AddressModel.fromJson(responseData['billing_address'] as Map<String, dynamic>)
                : null,
            'delivery_type': responseData['delivery_type'] as String,
            'cart_items': (responseData['cart_items'] as List<dynamic>)
                .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
                .toList(),
            'summary': CheckoutSummaryModel.fromJson(
              responseData['summary'] as Map<String, dynamic>
            ),
          };
        } else {
          throw Exception(data['message'] ?? 'Error al iniciar checkout');
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(data['message'] ?? 'Error al iniciar checkout');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final errorMessages = errors.values
              .expand((e) => e as List)
              .join(', ');
          throw Exception(errorMessages);
        }
        throw Exception('Error de validación');
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error iniciando checkout: $e');
      rethrow;
    }
  }

  /// Confirmar checkout y crear orden
  Future<OrderModel> confirmCheckout({
    required int shippingAddressId,
    required String deliveryType,
    int? billingAddressId,
    String? notes,
  }) async {
    try {
      _logger.i('✅ Confirmando checkout');
      
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final body = {
        'shipping_address_id': shippingAddressId,
        'delivery_type': deliveryType,
        if (billingAddressId != null) 'billing_address_id': billingAddressId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/buyer/checkout/confirm'),
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
          final orderData = data['data']['order'] as Map<String, dynamic>;
          _logger.i('✅ Orden creada exitosamente: ${orderData['order_number']}');
          
          return OrderModel.fromJson(orderData);
        } else {
          throw Exception(data['message'] ?? 'Error al confirmar checkout');
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(data['message'] ?? 'Error al confirmar checkout');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final errorMessages = errors.values
              .expand((e) => e as List)
              .join(', ');
          throw Exception(errorMessages);
        }
        throw Exception('Error de validación');
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error confirmando checkout: $e');
      rethrow;
    }
  }
}

