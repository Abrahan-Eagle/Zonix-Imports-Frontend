import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Modelo para almacenar filtros en cache
class FilterCache {
  final double? minPrice;
  final double? maxPrice;
  final List<String> selectedBrands;
  final List<String> selectedModalities;
  final String? selectedSort;
  final bool inStockOnly;
  final bool hasDiscount;
  final int? selectedCategoryId;
  final String searchQuery;

  FilterCache({
    this.minPrice,
    this.maxPrice,
    this.selectedBrands = const [],
    this.selectedModalities = const [],
    this.selectedSort,
    this.inStockOnly = false,
    this.hasDiscount = false,
    this.selectedCategoryId,
    this.searchQuery = '',
  });

  /// Convertir a Map para JSON
  Map<String, dynamic> toJson() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'selectedBrands': selectedBrands,
      'selectedModalities': selectedModalities,
      'selectedSort': selectedSort,
      'inStockOnly': inStockOnly,
      'hasDiscount': hasDiscount,
      'selectedCategoryId': selectedCategoryId,
      'searchQuery': searchQuery,
    };
  }

  /// Crear desde Map
  factory FilterCache.fromJson(Map<String, dynamic> json) {
    return FilterCache(
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      selectedBrands: List<String>.from(json['selectedBrands'] ?? []),
      selectedModalities: List<String>.from(json['selectedModalities'] ?? []),
      selectedSort: json['selectedSort'],
      inStockOnly: json['inStockOnly'] ?? false,
      hasDiscount: json['hasDiscount'] ?? false,
      selectedCategoryId: json['selectedCategoryId'],
      searchQuery: json['searchQuery'] ?? '',
    );
  }

  /// Crear copia con cambios
  FilterCache copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? selectedBrands,
    List<String>? selectedModalities,
    String? selectedSort,
    bool? inStockOnly,
    bool? hasDiscount,
    int? selectedCategoryId,
    String? searchQuery,
  }) {
    return FilterCache(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      selectedModalities: selectedModalities ?? this.selectedModalities,
      selectedSort: selectedSort ?? this.selectedSort,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Verificar si hay filtros activos
  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        selectedBrands.isNotEmpty ||
        selectedModalities.isNotEmpty ||
        selectedSort != null ||
        inStockOnly ||
        hasDiscount ||
        selectedCategoryId != null ||
        searchQuery.isNotEmpty;
  }

  /// Limpiar todos los filtros
  FilterCache clear() {
    return FilterCache();
  }

  @override
  String toString() {
    return 'FilterCache(minPrice: $minPrice, maxPrice: $maxPrice, '
        'selectedBrands: $selectedBrands, selectedModalities: $selectedModalities, '
        'selectedSort: $selectedSort, inStockOnly: $inStockOnly, '
        'hasDiscount: $hasDiscount, selectedCategoryId: $selectedCategoryId, '
        'searchQuery: $searchQuery)';
  }
}

/// Servicio para manejar el cache de filtros de productos
class FilterCacheService {
  static final Logger _logger = Logger();
  static const String _cacheKey = 'product_filters_cache';
  static const String _lastUsedKey = 'last_used_filters';

  /// Guardar filtros en cache
  static Future<void> saveFilters(FilterCache filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(filters.toJson());

      await prefs.setString(_cacheKey, jsonString);
      await prefs.setString(_lastUsedKey, DateTime.now().toIso8601String());

      _logger.d('💾 Filtros guardados en cache: ${filters.toString()}');
    } catch (e) {
      _logger.e('❌ Error guardando filtros en cache: $e');
    }
  }

  /// Cargar filtros desde cache
  static Future<FilterCache?> loadFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final filters = FilterCache.fromJson(json);

        _logger.d('📂 Filtros cargados desde cache: ${filters.toString()}');
        return filters;
      }

      _logger.d('📂 No hay filtros en cache');
      return null;
    } catch (e) {
      _logger.e('❌ Error cargando filtros desde cache: $e');
      return null;
    }
  }

  /// Cargar filtros con fallback a valores por defecto
  static Future<FilterCache> loadFiltersOrDefault() async {
    final cached = await loadFilters();
    return cached ?? FilterCache();
  }

  /// Limpiar cache de filtros
  static Future<void> clearFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastUsedKey);

      _logger.d('🗑️ Cache de filtros limpiado');
    } catch (e) {
      _logger.e('❌ Error limpiando cache de filtros: $e');
    }
  }

  /// Obtener fecha de último uso
  static Future<DateTime?> getLastUsedDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString(_lastUsedKey);

      if (dateString != null) {
        return DateTime.parse(dateString);
      }

      return null;
    } catch (e) {
      _logger.e('❌ Error obteniendo fecha de último uso: $e');
      return null;
    }
  }

  /// Verificar si el cache es reciente (menos de 24 horas)
  static Future<bool> isCacheRecent() async {
    try {
      final lastUsed = await getLastUsedDate();
      if (lastUsed == null) return false;

      final now = DateTime.now();
      final difference = now.difference(lastUsed);

      return difference.inHours < 24;
    } catch (e) {
      _logger.e('❌ Error verificando si el cache es reciente: $e');
      return false;
    }
  }

  /// Guardar filtro individual
  static Future<void> saveFilter<T>(String key, T value) async {
    try {
      final current = await loadFiltersOrDefault();
      FilterCache updated;

      switch (key) {
        case 'minPrice':
          updated = current.copyWith(minPrice: value as double?);
          break;
        case 'maxPrice':
          updated = current.copyWith(maxPrice: value as double?);
          break;
        case 'selectedBrands':
          updated = current.copyWith(selectedBrands: value as List<String>);
          break;
        case 'selectedModalities':
          updated = current.copyWith(selectedModalities: value as List<String>);
          break;
        case 'selectedSort':
          updated = current.copyWith(selectedSort: value as String?);
          break;
        case 'inStockOnly':
          updated = current.copyWith(inStockOnly: value as bool);
          break;
        case 'hasDiscount':
          updated = current.copyWith(hasDiscount: value as bool);
          break;
        case 'selectedCategoryId':
          updated = current.copyWith(selectedCategoryId: value as int?);
          break;
        case 'searchQuery':
          updated = current.copyWith(searchQuery: value as String);
          break;
        default:
          _logger.w('⚠️ Clave de filtro no reconocida: $key');
          return;
      }

      await saveFilters(updated);
    } catch (e) {
      _logger.e('❌ Error guardando filtro individual: $e');
    }
  }

  /// Obtener estadísticas del cache
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final lastUsed = await getLastUsedDate();
      final isRecent = await isCacheRecent();
      final filters = await loadFilters();

      return {
        'hasFilters': filters != null,
        'hasActiveFilters': filters?.hasActiveFilters ?? false,
        'lastUsed': lastUsed?.toIso8601String(),
        'isRecent': isRecent,
        'filterCount': filters != null ? _countActiveFilters(filters) : 0,
      };
    } catch (e) {
      _logger.e('❌ Error obteniendo estadísticas del cache: $e');
      return {};
    }
  }

  /// Contar filtros activos
  static int _countActiveFilters(FilterCache filters) {
    int count = 0;
    if (filters.minPrice != null) count++;
    if (filters.maxPrice != null) count++;
    if (filters.selectedBrands.isNotEmpty) count++;
    if (filters.selectedModalities.isNotEmpty) count++;
    if (filters.selectedSort != null) count++;
    if (filters.inStockOnly) count++;
    if (filters.hasDiscount) count++;
    if (filters.selectedCategoryId != null) count++;
    if (filters.searchQuery.isNotEmpty) count++;
    return count;
  }
}
