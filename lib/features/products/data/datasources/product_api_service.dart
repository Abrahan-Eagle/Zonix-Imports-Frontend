import 'package:logger/logger.dart';

import '../../../../core/services/api_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

/// Servicio API para manejo de productos y categorías
class ProductApiService {
  static final Logger _logger = Logger();
  final ApiService _apiService = ApiService();

  /// Obtener lista de productos con filtros opcionales
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    String? search,
    String? sortBy,
    String? sortOrder,
    double? minPrice,
    double? maxPrice,
    String? brand,
    bool? inStock,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      // Agregar filtros opcionales
      if (categoryId != null)
        queryParams['category_id'] = categoryId.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;
      if (inStock != null) queryParams['in_stock'] = inStock.toString();

      final response =
          await _apiService.get('/buyer/products', queryParams: queryParams);

      if (response['success']) {
        final data = response['data'];
        List<ProductModel> products = [];

        // Validar que data existe y tiene la estructura esperada
        if (data != null && data['data'] is List) {
          try {
            products = (data['data'] as List)
                .map((json) => ProductModel.fromJson(json))
                .toList();
          } catch (e) {
            _logger.e('Error al parsear productos: $e');
            products = <ProductModel>[];
          }
        }

        return {
          'success': true,
          'products': products,
          'pagination': data?['meta'],
          'message': 'Productos obtenidos exitosamente',
        };
      } else {
        return {
          'success': false,
          'products': <ProductModel>[],
          'pagination': null,
          'message': response['message'] ?? 'Error al obtener productos',
        };
      }
    } catch (e) {
      _logger.e('Error al obtener productos: $e');
      return {
        'success': false,
        'products': <ProductModel>[],
        'pagination': null,
        'message': 'Error de conexión al obtener productos',
      };
    }
  }

  /// Obtener un producto por ID
  Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final response = await _apiService.get('/buyer/products/$productId');

      if (response['success']) {
        final product = ProductModel.fromJson(response['data']);
        return {
          'success': true,
          'product': product,
          'message': 'Producto obtenido exitosamente',
        };
      } else {
        return {
          'success': false,
          'product': null,
          'message': response['message'] ?? 'Producto no encontrado',
        };
      }
    } catch (e) {
      _logger.e('Error al obtener producto $productId: $e');
      return {
        'success': false,
        'product': null,
        'message': 'Error de conexión al obtener producto',
      };
    }
  }

  /// Obtener productos relacionados
  Future<Map<String, dynamic>> getRelatedProducts(int productId,
      {int limit = 5}) async {
    try {
      final response = await _apiService.get(
          '/buyer/products/$productId/related',
          queryParams: {'limit': limit.toString()});

      if (response['success']) {
        final products = (response['data'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'products': products,
          'message': 'Productos relacionados obtenidos exitosamente',
        };
      } else {
        return {
          'success': false,
          'products': <ProductModel>[],
          'message':
              response['message'] ?? 'Error al obtener productos relacionados',
        };
      }
    } catch (e) {
      _logger.e('Error al obtener productos relacionados: $e');
      return {
        'success': false,
        'products': <ProductModel>[],
        'message': 'Error de conexión al obtener productos relacionados',
      };
    }
  }

  /// Obtener productos destacados
  Future<Map<String, dynamic>> getFeaturedProducts({int limit = 10}) async {
    try {
      final response = await _apiService.get('/buyer/products/featured',
          queryParams: {'limit': limit.toString()});

      if (response['success']) {
        final products = (response['data'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'products': products,
          'message': 'Productos destacados obtenidos exitosamente',
        };
      } else {
        return {
          'success': false,
          'products': <ProductModel>[],
          'message':
              response['message'] ?? 'Error al obtener productos destacados',
        };
      }
    } catch (e) {
      _logger.e('Error al obtener productos destacados: $e');
      return {
        'success': false,
        'products': <ProductModel>[],
        'message': 'Error de conexión al obtener productos destacados',
      };
    }
  }

  /// Buscar productos
  Future<Map<String, dynamic>> searchProducts(String query,
      {int page = 1, int perPage = 20}) async {
    try {
      final response =
          await _apiService.get('/buyer/products/search', queryParams: {
        'q': query,
        'page': page.toString(),
        'per_page': perPage.toString(),
      });

      if (response['success']) {
        final data = response['data'];
        final products = (data['data'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'products': products,
          'pagination': data['meta'],
          'message': 'Búsqueda realizada exitosamente',
        };
      } else {
        return {
          'success': false,
          'products': <ProductModel>[],
          'pagination': null,
          'message': response['message'] ?? 'No se encontraron productos',
        };
      }
    } catch (e) {
      _logger.e('Error al buscar productos: $e');
      return {
        'success': false,
        'products': <ProductModel>[],
        'pagination': null,
        'message': 'Error de conexión al buscar productos',
      };
    }
  }

  /// Obtener todas las categorías
  Future<Map<String, dynamic>> getCategories(
      {bool includeInactive = false}) async {
    try {
      final queryParams = <String, String>{};
      if (includeInactive) {
        queryParams['include_inactive'] = 'true';
      }

      final response =
          await _apiService.get('/categories', queryParams: queryParams);

      if (response['success']) {
        final categories = (response['data'] as List)
            .map((json) => CategoryModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'categories': categories,
          'message': 'Categorías obtenidas exitosamente',
        };
      } else {
        return {
          'success': false,
          'categories': <CategoryModel>[],
          'message': response['message'] ?? 'Error al obtener categorías',
        };
      }
    } catch (e) {
      _logger.e('Error al obtener categorías: $e');
      return {
        'success': false,
        'categories': <CategoryModel>[],
        'message': 'Error de conexión al obtener categorías',
      };
    }
  }

  /// Obtener una categoría por ID
  Future<Map<String, dynamic>> getCategoryById(int categoryId) async {
    try {
      final response = await _apiService.get('/categories/$categoryId');

      if (response['success']) {
        final category = CategoryModel.fromJson(response['data']);
        return {
          'success': true,
          'category': category,
          'message': 'Categoría obtenida exitosamente',
        };
      } else {
        return {
          'success': false,
          'category': null,
          'message': response['message'] ?? 'Categoría no encontrada',
        };
      }
    } catch (e) {
      _logger.e('Error al obtener categoría $categoryId: $e');
      return {
        'success': false,
        'category': null,
        'message': 'Error de conexión al obtener categoría',
      };
    }
  }

  /// Obtener marcas populares
  Future<Map<String, dynamic>> getPopularBrands({int limit = 10}) async {
    try {
      final response = await _apiService.get('/buyer/products/brands',
          queryParams: {'limit': limit.toString()});

      if (response['success']) {
        final brands = (response['data'] as List).cast<String>();
        return {
          'success': true,
          'brands': brands,
          'message': 'Marcas obtenidas exitosamente',
        };
      } else {
        return {
          'success': false,
          'brands': <String>[],
          'message': response['message'] ?? 'Error al obtener marcas',
        };
      }
    } catch (e) {
      _logger.e('Error al obtener marcas: $e');
      return {
        'success': false,
        'brands': <String>[],
        'message': 'Error de conexión al obtener marcas',
      };
    }
  }
}
