import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:zonix/features/profile/data/models/profile_model.dart';
import 'package:zonix/features/profile/data/models/phone_model.dart';
import 'package:zonix/features/profile/data/models/address_model.dart';
import 'package:zonix/features/profile/data/models/document_model.dart';
import 'package:zonix/features/profile/data/models/commerce_model.dart';

final logger = Logger();
final String baseUrl = const bool.fromEnvironment('dart.vm.product')
    ? dotenv.env['API_URL_PROD']!
    : dotenv.env['API_URL_LOCAL']!;

class UnifiedProfileService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // ========== PROFILE OPERATIONS ==========

  Future<Profile> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$baseUrl/profile'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      logger.i('Profile response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Profile.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Error al obtener perfil');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en getProfile: $e');
      throw Exception('Error al obtener perfil: $e');
    }
  }

  Future<Profile> updateProfile(Profile profile) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('$baseUrl/profile'),
            headers: headers,
            body: jsonEncode(profile.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['isSuccess'] == true) {
          return Profile.fromJson(data['profile']);
        } else {
          throw Exception(data['message'] ?? 'Error al actualizar perfil');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en updateProfile: $e');
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token no encontrado');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/upload-image'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'photo_users',
        imageFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['image_url'] ?? '';
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en uploadProfileImage: $e');
      throw Exception('Error al subir imagen: $e');
    }
  }

  // ========== PHONE OPERATIONS ==========

  Future<List<PhoneModel>> getPhones() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$baseUrl/phones'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => PhoneModel.fromJson(json)).toList();
        } else {
          return [];
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en getPhones: $e');
      throw Exception('Error al obtener teléfonos: $e');
    }
  }

  Future<PhoneModel> createPhone(PhoneModel phone) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/phones'),
            headers: headers,
            body: jsonEncode(phone.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PhoneModel.fromJson(data);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en createPhone: $e');
      throw Exception('Error al crear teléfono: $e');
    }
  }

  Future<PhoneModel> updatePhone(PhoneModel phone) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('$baseUrl/phones/${phone.id}'),
            headers: headers,
            body: jsonEncode(phone.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PhoneModel.fromJson(data);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en updatePhone: $e');
      throw Exception('Error al actualizar teléfono: $e');
    }
  }

  Future<void> deletePhone(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('$baseUrl/phones/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en deletePhone: $e');
      throw Exception('Error al eliminar teléfono: $e');
    }
  }

  // ========== ADDRESS OPERATIONS ==========

  Future<List<AddressModel>> getAddresses() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$baseUrl/addresses'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => AddressModel.fromJson(json)).toList();
        } else {
          return [];
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en getAddresses: $e');
      throw Exception('Error al obtener direcciones: $e');
    }
  }

  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/addresses'),
            headers: headers,
            body: jsonEncode(address.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AddressModel.fromJson(data);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en createAddress: $e');
      throw Exception('Error al crear dirección: $e');
    }
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('$baseUrl/addresses/${address.id}'),
            headers: headers,
            body: jsonEncode(address.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AddressModel.fromJson(data);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en updateAddress: $e');
      throw Exception('Error al actualizar dirección: $e');
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('$baseUrl/addresses/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en deleteAddress: $e');
      throw Exception('Error al eliminar dirección: $e');
    }
  }

  // ========== DOCUMENT OPERATIONS ==========

  Future<List<DocumentModel>> getDocuments() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$baseUrl/documents'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => DocumentModel.fromJson(json)).toList();
        } else {
          return [];
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en getDocuments: $e');
      throw Exception('Error al obtener documentos: $e');
    }
  }

  Future<DocumentModel> createDocument(DocumentModel document) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/documents'),
            headers: headers,
            body: jsonEncode(document.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DocumentModel.fromJson(data);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en createDocument: $e');
      throw Exception('Error al crear documento: $e');
    }
  }

  Future<void> deleteDocument(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('$baseUrl/documents/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en deleteDocument: $e');
      throw Exception('Error al eliminar documento: $e');
    }
  }

  // ========== COMMERCE OPERATIONS ==========

  Future<CommerceModel?> getCommerce() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$baseUrl/my-commerce'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return CommerceModel.fromJson(data['data']);
        } else {
          return null; // No commerce found
        }
      } else if (response.statusCode == 404) {
        return null; // No commerce found
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en getCommerce: $e');
      throw Exception('Error al obtener comercio: $e');
    }
  }

  Future<CommerceModel> updateCommerce(CommerceModel commerce) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('$baseUrl/my-commerce'),
            headers: headers,
            body: jsonEncode(commerce.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CommerceModel.fromJson(data);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en updateCommerce: $e');
      throw Exception('Error al actualizar comercio: $e');
    }
  }

  Future<String> uploadCommerceLogo(File imageFile) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token no encontrado');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/my-commerce/upload-logo'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['image_url'] ?? '';
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      logger.e('Error en uploadCommerceLogo: $e');
      throw Exception('Error al subir logo: $e');
    }
  }
}
