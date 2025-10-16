import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zonix/core/config/app_config.dart';
import 'package:logger/logger.dart';
import 'package:zonix/features/checkout/data/models/address_model.dart';

class AddressApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();
  final String baseUrl = AppConfig.baseUrl;

  /// Obtener direcciones del usuario
  Future<List<AddressModel>> getUserAddresses() async {
    try {
      _logger.i('🏠 Obteniendo direcciones del usuario');
      
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      _logger.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        
        final addresses = data
            .map((addr) => AddressModel.fromJson(addr as Map<String, dynamic>))
            .toList();
        
        _logger.i('✅ Direcciones obtenidas: ${addresses.length}');
        return addresses;
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error obteniendo direcciones: $e');
      rethrow;
    }
  }
}

