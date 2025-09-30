import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/product_model.dart';

/// Servicio para gestión de wishlist/favoritos persistente
class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  static const String _storageKey = 'wishlist_products';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Obtener todos los productos en la wishlist
  Future<List<ProductModel>> getWishlist() async {
    try {
      final wishlistJson = await _storage.read(key: _storageKey);
      if (wishlistJson == null) return [];

      final List<dynamic> decoded = json.decode(wishlistJson);
      return decoded.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error al obtener wishlist: $e');
      return [];
    }
  }

  /// Verificar si un producto está en la wishlist
  Future<bool> isInWishlist(int productId) async {
    try {
      final wishlist = await getWishlist();
      return wishlist.any((product) => product.id == productId);
    } catch (e) {
      debugPrint('Error al verificar wishlist: $e');
      return false;
    }
  }

  /// Agregar producto a la wishlist
  Future<bool> addToWishlist(ProductModel product) async {
    try {
      final wishlist = await getWishlist();

      // Verificar si ya existe
      if (wishlist.any((p) => p.id == product.id)) {
        return false; // Ya existe
      }

      wishlist.add(product);
      await _saveWishlist(wishlist);
      return true;
    } catch (e) {
      debugPrint('Error al agregar a wishlist: $e');
      return false;
    }
  }

  /// Remover producto de la wishlist
  Future<bool> removeFromWishlist(int productId) async {
    try {
      final wishlist = await getWishlist();
      final initialLength = wishlist.length;

      wishlist.removeWhere((product) => product.id == productId);

      if (wishlist.length != initialLength) {
        await _saveWishlist(wishlist);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al remover de wishlist: $e');
      return false;
    }
  }

  /// Toggle (agregar/remover) producto en la wishlist
  Future<bool> toggleWishlist(ProductModel product) async {
    try {
      final isInList = await isInWishlist(product.id);

      if (isInList) {
        return await removeFromWishlist(product.id);
      } else {
        return await addToWishlist(product);
      }
    } catch (e) {
      debugPrint('Error al toggle wishlist: $e');
      return false;
    }
  }

  /// Limpiar toda la wishlist
  Future<void> clearWishlist() async {
    try {
      await _storage.delete(key: _storageKey);
    } catch (e) {
      debugPrint('Error al limpiar wishlist: $e');
    }
  }

  /// Obtener cantidad de productos en la wishlist
  Future<int> getWishlistCount() async {
    try {
      final wishlist = await getWishlist();
      return wishlist.length;
    } catch (e) {
      debugPrint('Error al obtener cantidad de wishlist: $e');
      return 0;
    }
  }

  /// Guardar wishlist en el almacenamiento
  Future<void> _saveWishlist(List<ProductModel> wishlist) async {
    try {
      final jsonData =
          json.encode(wishlist.map((product) => product.toJson()).toList());
      await _storage.write(key: _storageKey, value: jsonData);
    } catch (e) {
      debugPrint('Error al guardar wishlist: $e');
    }
  }

  /// Obtener productos similares de la wishlist
  Future<List<ProductModel>> getSimilarProducts(ProductModel product,
      {int limit = 3}) async {
    try {
      final wishlist = await getWishlist();

      // Filtrar productos de la misma categoría
      final similar = wishlist
          .where((wishProduct) =>
              wishProduct.id != product.id &&
              wishProduct.categoryId == product.categoryId)
          .take(limit)
          .toList();

      return similar;
    } catch (e) {
      debugPrint('Error al obtener productos similares: $e');
      return [];
    }
  }

  /// Exportar wishlist como JSON
  Future<String?> exportWishlist() async {
    try {
      final wishlist = await getWishlist();
      return json.encode(wishlist.map((product) => product.toJson()).toList());
    } catch (e) {
      debugPrint('Error al exportar wishlist: $e');
      return null;
    }
  }

  /// Importar wishlist desde JSON
  Future<bool> importWishlist(String jsonData) async {
    try {
      final List<dynamic> decoded = json.decode(jsonData);
      final products =
          decoded.map((json) => ProductModel.fromJson(json)).toList();

      await _saveWishlist(products);
      return true;
    } catch (e) {
      debugPrint('Error al importar wishlist: $e');
      return false;
    }
  }
}
