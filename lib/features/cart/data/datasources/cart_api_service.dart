import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/cart_item_model.dart';
import '../models/cart_summary_model.dart';

final logger = Logger();
const FlutterSecureStorage _storage = FlutterSecureStorage();

class CartApiService {
  final String baseUrl = const bool.fromEnvironment('dart.vm.product')
      ? dotenv.env['API_URL_PROD']!
      : dotenv.env['API_URL_LOCAL']!;

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  /// Agregar producto al carrito
  /// POST /buyer/cart/add
  Future<Map<String, dynamic>> addItem({
    required int productId,
    required int quantity,
    String modality = 'retail',
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'No autenticado',
        };
      }

      final url = Uri.parse('$baseUrl/api/buyer/cart/add');
      logger.i('🛒 Agregando producto al carrito: $productId');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
          'modality': modality,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        logger.i('✅ Producto agregado al carrito');
        return {
          'success': true,
          'cart_item': CartItemModel.fromJson(data['data']['cart_item']),
          'cart_total': double.parse(data['data']['cart_total'].toString()),
          'items_count': data['data']['items_count'],
        };
      } else {
        logger.e('❌ Error agregando: ${response.statusCode}');
        return {
          'success': false,
          'error': data['message'] ?? 'Error al agregar producto',
        };
      }
    } catch (e) {
      logger.e('❌ Excepción agregando: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Obtener carrito
  /// GET /buyer/cart
  Future<Map<String, dynamic>> getCart() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'No autenticado',
        };
      }

      final url = Uri.parse('$baseUrl/api/buyer/cart');
      logger.i('🛒 Obteniendo carrito');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final items = (data['data']['items'] as List? ?? [])
            .map((item) => CartItemModel.fromJson(item))
            .toList();

        final summary = CartSummaryModel.fromJson(data['data']['summary']);

        logger.i('✅ Carrito obtenido: ${items.length} items');

        return {
          'success': true,
          'items': items,
          'summary': summary,
        };
      } else {
        logger.e('❌ Error obteniendo carrito: ${response.statusCode}');
        return {
          'success': false,
          'error': data['message'] ?? 'Error al obtener carrito',
        };
      }
    } catch (e) {
      logger.e('❌ Excepción obteniendo carrito: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Actualizar cantidad
  /// PUT /cart/{id}
  Future<Map<String, dynamic>> updateQuantity(int cartItemId, int quantity) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'No autenticado',
        };
      }

      final url = Uri.parse('$baseUrl/api/cart/$cartItemId');
      logger.i('🔄 Actualizando cantidad: $cartItemId → $quantity');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'quantity': quantity}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        logger.i('✅ Cantidad actualizada');
        return {
          'success': true,
          'cart_item': CartItemModel.fromJson(data['data']['cart_item']),
          'summary': CartSummaryModel.fromJson(data['data']['summary']),
        };
      } else {
        logger.e('❌ Error actualizando: ${response.statusCode}');
        return {
          'success': false,
          'error': data['message'] ?? 'Error al actualizar',
        };
      }
    } catch (e) {
      logger.e('❌ Excepción actualizando: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Eliminar item
  /// DELETE /cart/{id}
  Future<Map<String, dynamic>> removeItem(int cartItemId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'No autenticado',
        };
      }

      final url = Uri.parse('$baseUrl/api/cart/$cartItemId');
      logger.i('🗑️ Eliminando item: $cartItemId');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        logger.i('✅ Item eliminado');
        return {
          'success': true,
          'summary': CartSummaryModel.fromJson(data['data']['summary']),
        };
      } else {
        logger.e('❌ Error eliminando: ${response.statusCode}');
        return {
          'success': false,
          'error': data['message'] ?? 'Error al eliminar',
        };
      }
    } catch (e) {
      logger.e('❌ Excepción eliminando: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Limpiar carrito
  /// DELETE /buyer/cart
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'No autenticado',
        };
      }

      final url = Uri.parse('$baseUrl/api/buyer/cart');
      logger.i('🗑️ Limpiando carrito completo');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        logger.i('✅ Carrito limpiado');
        return {
          'success': true,
          'items_deleted': data['data']['items_deleted'],
        };
      } else {
        logger.e('❌ Error limpiando: ${response.statusCode}');
        return {
          'success': false,
          'error': data['message'] ?? 'Error al limpiar',
        };
      }
    } catch (e) {
      logger.e('❌ Excepción limpiando: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Validar stock
  /// GET /buyer/cart/validate
  Future<Map<String, dynamic>> validateStock() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'No autenticado',
        };
      }

      final url = Uri.parse('$baseUrl/api/buyer/cart/validate');
      logger.i('✅ Validando stock del carrito');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'valid': data['data']['valid'] ?? false,
        'errors': data['data']['errors'] ?? [],
      };
    } catch (e) {
      logger.e('❌ Excepción validando: $e');
      return {
        'success': false,
        'valid': false,
        'error': e.toString(),
      };
    }
  }
}

