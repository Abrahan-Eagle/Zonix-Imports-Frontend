import 'dart:async';
import 'package:flutter/material.dart';

import '../datasources/product_api_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

/// Servicio de búsqueda avanzada con sugerencias
class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final ProductApiService _productApiService = ProductApiService();
  Timer? _debounceTimer;
  final Duration _debounceDelay = const Duration(milliseconds: 300);

  /// Búsqueda con debounce para evitar muchas llamadas a la API
  Stream<List<ProductModel>> searchWithDebounce(String query) async* {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      yield [];
      return;
    }

    yield* _performSearch(query);
  }

  Stream<List<ProductModel>> _performSearch(String query) async* {
    _debounceTimer = Timer(_debounceDelay, () async {
      try {
        final result = await _productApiService.searchProducts(query);
        if (result['success'] == true) {
          final products = result['products'] as List<ProductModel>;
          // En una implementación real, esto sería manejado por un StreamController
        }
      } catch (e) {
        debugPrint('Error en búsqueda: $e');
      }
    });

    yield [];
  }

  /// Obtener sugerencias de búsqueda basadas en productos populares
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      // Simular sugerencias basadas en nombres de productos comunes
      final commonSuggestions = [
        'iPhone',
        'Samsung Galaxy',
        'MacBook',
        'iPad',
        'AirPods',
        'PlayStation',
        'Xbox',
        'Nintendo Switch',
        'Smart TV',
        'Laptop',
        'Tablet',
        'Smartphone',
        'Auriculares',
        'Cámara',
        'Drone',
        'Reloj inteligente',
        'Altavoces',
        'Cargador',
        'Cable USB',
        'Funda'
      ];

      return commonSuggestions
          .where((suggestion) =>
              suggestion.toLowerCase().contains(query.toLowerCase()))
          .take(5)
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo sugerencias: $e');
      return [];
    }
  }

  /// Obtener productos populares para sugerencias
  Future<List<ProductModel>> getPopularProducts({int limit = 5}) async {
    try {
      final result = await _productApiService.getFeaturedProducts();
      if (result['success'] == true) {
        final products = result['products'] as List<ProductModel>;
        return products.take(limit).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error obteniendo productos populares: $e');
      return [];
    }
  }

  /// Obtener productos vistos recientemente (simulado)
  Future<List<ProductModel>> getRecentlyViewed() async {
    // En una implementación real, esto vendría del almacenamiento local
    return [];
  }

  /// Limpiar recursos
  void dispose() {
    _debounceTimer?.cancel();
  }
}
