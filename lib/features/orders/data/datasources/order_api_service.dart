import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zonix/core/config/app_config.dart';
import 'package:logger/logger.dart';
import 'package:zonix/features/checkout/data/models/order_model.dart';

class OrderApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();
  final String baseUrl = AppConfig.baseUrl;

  /// Obtener lista de órdenes del comprador
  Future<Map<String, dynamic>> getBuyerOrders({
    String? status,
    String? modality,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      _logger.i('📦 Obteniendo órdenes del comprador');
      
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final queryParams = <String>[];
      if (status != null) queryParams.add('status=$status');
      if (modality != null) queryParams.add('modality=$modality');
      queryParams.add('page=$page');
      queryParams.add('per_page=$perPage');

      final url = '$baseUrl/buyer/orders?${queryParams.join('&')}';

      final response = await http.get(
        Uri.parse(url),
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
            'orders': (responseData['orders'] as List<dynamic>)
                .map((order) => _parseOrderSummary(order as Map<String, dynamic>))
                .toList(),
            'pagination': responseData['pagination'] as Map<String, dynamic>,
          };
        } else {
          throw Exception(data['message'] ?? 'Error al obtener órdenes');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error obteniendo órdenes: $e');
      rethrow;
    }
  }

  /// Obtener detalle de una orden
  Future<OrderModel> getOrderDetail(int orderId) async {
    try {
      _logger.i('📋 Obteniendo detalle de orden $orderId');
      
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/buyer/orders/$orderId'),
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
          final orderData = data['data']['order'] as Map<String, dynamic>;
          _logger.i('✅ Detalle de orden obtenido');
          
          return OrderModel.fromJson(orderData);
        } else {
          throw Exception(data['message'] ?? 'Error al obtener detalle');
        }
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(data['message'] ?? 'Orden no encontrada');
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error obteniendo detalle de orden: $e');
      rethrow;
    }
  }

  /// Obtener tracking de una orden
  Future<Map<String, dynamic>> getOrderTracking(int orderId) async {
    try {
      _logger.i('🚚 Obteniendo tracking de orden $orderId');
      
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/buyer/orders/$orderId/tracking'),
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
          _logger.i('✅ Tracking obtenido');
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Error al obtener tracking');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error obteniendo tracking: $e');
      rethrow;
    }
  }

  /// Helper para parsear resumen de orden
  Map<String, dynamic> _parseOrderSummary(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'order_number': json['order_number'],
      'status': json['status'],
      'modality': json['modality'],
      'delivery_type': json['delivery_type'],
      'total': (json['total'] as num).toDouble(),
      'commerce': json['commerce'],
      'items_count': json['items_count'],
      'created_at': json['created_at'],
    };
  }
}

