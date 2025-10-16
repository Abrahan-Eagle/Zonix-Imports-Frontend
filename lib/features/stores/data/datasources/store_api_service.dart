import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/store_model.dart';
import '../../../products/data/models/product_model.dart';

final logger = Logger();
const FlutterSecureStorage _storage = FlutterSecureStorage();

class StoreApiService {
  final String baseUrl = const bool.fromEnvironment('dart.vm.product')
      ? dotenv.env['API_URL_PROD']!
      : dotenv.env['API_URL_LOCAL']!;

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  /// Obtener lista de tiendas
  /// GET /api/commerces
  Future<Map<String, dynamic>> getStores({
    int page = 1,
    int perPage = 20,
    bool? onlyOpen,
    String? businessType,
    String? search,
    String sortBy = 'business_name',
    String sortOrder = 'asc',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/commerces').replace(queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (onlyOpen != null) 'open': onlyOpen.toString(),
        if (businessType != null) 'business_type': businessType,
        if (search != null && search.isNotEmpty) 'search': search,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      });

      logger.i('🌐 Llamando API: ${url.toString()}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i('✅ Tiendas obtenidas: ${data['data'].length}');

        final stores = (data['data'] as List)
            .map((store) => StoreModel.fromJson(store))
            .toList();

        return {
          'success': data['success'] ?? true,
          'stores': stores,
          'meta': data['meta'],
        };
      } else {
        logger.e('❌ Error al obtener tiendas: ${response.statusCode}');
        return {
          'success': false,
          'stores': <StoreModel>[],
          'error': 'Error al cargar tiendas',
        };
      }
    } catch (e) {
      logger.e('❌ Excepción al obtener tiendas: $e');
      return {
        'success': false,
        'stores': <StoreModel>[],
        'error': e.toString(),
      };
    }
  }

  /// Obtener detalles de una tienda
  /// GET /api/commerces/{id}
  Future<Map<String, dynamic>> getStoreDetails(int storeId) async {
    try {
      final url = Uri.parse('$baseUrl/api/commerces/$storeId');
      logger.i('🌐 Obteniendo detalles de tienda: $storeId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i('✅ Detalles de tienda obtenidos');

        return {
          'success': data['success'] ?? true,
          'store': StoreModel.fromJson(data['data']),
        };
      } else {
        logger.e('❌ Error al obtener tienda: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Tienda no encontrada',
        };
      }
    } catch (e) {
      logger.e('❌ Excepción al obtener tienda: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Obtener productos de una tienda
  /// GET /api/commerces/{id}/products
  Future<Map<String, dynamic>> getStoreProducts(
    int storeId, {
    int page = 1,
    int perPage = 20,
    int? categoryId,
    String? modality,
    double? minPrice,
    double? maxPrice,
    String? search,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/commerces/$storeId/products')
          .replace(queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (modality != null) 'modality': modality,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      });

      logger.i('🌐 Obteniendo productos de tienda: $storeId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i('✅ Productos de tienda obtenidos: ${data['data'].length}');

        final products = (data['data'] as List)
            .map((product) => ProductModel.fromJson(product))
            .toList();

        return {
          'success': data['success'] ?? true,
          'products': products,
          'commerce': data['commerce'],
          'meta': data['meta'],
        };
      } else {
        logger.e('❌ Error al obtener productos: ${response.statusCode}');
        return {
          'success': false,
          'products': <ProductModel>[],
          'error': 'Error al cargar productos',
        };
      }
    } catch (e) {
      logger.e('❌ Excepción al obtener productos: $e');
      return {
        'success': false,
        'products': <ProductModel>[],
        'error': e.toString(),
      };
    }
  }

  /// Obtener mi tienda (vendedor autenticado)
  /// GET /api/my-commerce
  Future<Map<String, dynamic>> getMyStore() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'No autenticado',
        };
      }

      final url = Uri.parse('$baseUrl/api/my-commerce');
      logger.i('🌐 Obteniendo mi tienda');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i('✅ Mi tienda obtenida');

        return {
          'success': data['success'] ?? true,
          'store': StoreModel.fromJson(data['data']),
        };
      } else {
        logger.e('❌ Error al obtener mi tienda: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error al cargar tu tienda',
        };
      }
    } catch (e) {
      logger.e('❌ Excepción al obtener mi tienda: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Cambiar estado de la tienda (abrir/cerrar)
  /// PUT /api/my-commerce/toggle
  Future<Map<String, dynamic>> toggleStoreStatus() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'No autenticado',
        };
      }

      final url = Uri.parse('$baseUrl/api/my-commerce/toggle');
      logger.i('🔄 Cambiando estado de tienda');

      final response = await http.put(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i('✅ Estado de tienda cambiado');

        return {
          'success': data['success'] ?? true,
          'store': StoreModel.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        logger.e('❌ Error al cambiar estado: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error al cambiar estado',
        };
      }
    } catch (e) {
      logger.e('❌ Excepción al cambiar estado: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Obtener tipos de negocio
  /// GET /api/business-types
  Future<List<Map<String, String>>> getBusinessTypes() async {
    try {
      final url = Uri.parse('$baseUrl/api/business-types');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, String>>.from(
          data['data'].map((item) => {
                'value': item['value'].toString(),
                'label': item['label'].toString(),
              }),
        );
      }
      return [];
    } catch (e) {
      logger.e('❌ Error al obtener tipos de negocio: $e');
      return [];
    }
  }
}
