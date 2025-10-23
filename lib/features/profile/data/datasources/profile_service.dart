import 'package:zonix/features/profile/data/models/profile_model.dart';
import 'package:zonix/features/profile/data/models/phone_model.dart';
import 'package:zonix/features/profile/data/models/address_model.dart';
import 'package:zonix/features/profile/data/models/document_model.dart';
import 'package:zonix/features/profile/data/models/commerce_model.dart';
import 'package:zonix/core/services/api_service.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  // Profile operations
  Future<Profile> getProfile() async {
    try {
      // Usar el endpoint correcto para obtener el perfil del usuario autenticado
      final response = await _apiService.get('/profile');
      print('🔍 Profile response: $response'); // Debug

      if (response['success'] == true && response['data'] != null) {
        print('🔍 Profile data: ${response['data']}'); // Debug
        return Profile.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Error al obtener perfil');
      }
    } catch (e) {
      print('❌ Error en getProfile: $e'); // Debug
      throw Exception('Error al obtener perfil: $e');
    }
  }

  Future<Profile> updateProfile(Profile profile) async {
    try {
      // Por ahora simulamos la actualización hasta que se implemente PUT en ApiService
      return profile;
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  Future<String> uploadProfileImage(String imagePath) async {
    try {
      // Por ahora simulamos la subida hasta que se implemente POST con archivos
      return 'https://via.placeholder.com/150';
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  // Phone operations
  Future<List<PhoneModel>> getPhones() async {
    try {
      // Los teléfonos están incluidos en el perfil, no hay endpoint separado
      // Por ahora retornamos una lista vacía hasta que se implemente el endpoint
      return [];
    } catch (e) {
      throw Exception('Error al obtener teléfonos: $e');
    }
  }

  Future<PhoneModel> createPhone(PhoneModel phone) async {
    try {
      // Por ahora simulamos la creación hasta que se implemente POST en ApiService
      return phone;
    } catch (e) {
      throw Exception('Error al crear teléfono: $e');
    }
  }

  Future<PhoneModel> updatePhone(PhoneModel phone) async {
    try {
      // Por ahora simulamos la actualización hasta que se implemente PUT en ApiService
      return phone;
    } catch (e) {
      throw Exception('Error al actualizar teléfono: $e');
    }
  }

  Future<void> deletePhone(int id) async {
    try {
      // Por ahora simulamos la eliminación hasta que se implemente DELETE en ApiService
    } catch (e) {
      throw Exception('Error al eliminar teléfono: $e');
    }
  }

  // Address operations
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiService.get('/addresses');
      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => AddressModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Error al obtener direcciones');
      }
    } catch (e) {
      throw Exception('Error al obtener direcciones: $e');
    }
  }

  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      // Por ahora simulamos la creación hasta que se implemente POST en ApiService
      return address;
    } catch (e) {
      throw Exception('Error al crear dirección: $e');
    }
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      // Por ahora simulamos la actualización hasta que se implemente PUT en ApiService
      return address;
    } catch (e) {
      throw Exception('Error al actualizar dirección: $e');
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      // Por ahora simulamos la eliminación hasta que se implemente DELETE en ApiService
    } catch (e) {
      throw Exception('Error al eliminar dirección: $e');
    }
  }

  // Document operations
  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await _apiService.get('/documents');
      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => DocumentModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Error al obtener documentos');
      }
    } catch (e) {
      throw Exception('Error al obtener documentos: $e');
    }
  }

  Future<DocumentModel> createDocument(DocumentModel document) async {
    try {
      // Por ahora simulamos la creación hasta que se implemente POST en ApiService
      return document;
    } catch (e) {
      throw Exception('Error al crear documento: $e');
    }
  }

  Future<void> deleteDocument(int id) async {
    try {
      // Por ahora simulamos la eliminación hasta que se implemente DELETE en ApiService
    } catch (e) {
      throw Exception('Error al eliminar documento: $e');
    }
  }

  // Commerce operations
  Future<CommerceModel?> getCommerce() async {
    try {
      final response = await _apiService.get('/my-commerce');
      if (response['success'] == true && response['data'] != null) {
        return CommerceModel.fromJson(response['data']);
      } else {
        // Si no hay comercio, retornar null
        return null;
      }
    } catch (e) {
      // Si no hay comercio, retornar null
      return null;
    }
  }

  Future<CommerceModel> updateCommerce(CommerceModel commerce) async {
    try {
      // Por ahora simulamos la actualización hasta que se implemente PUT en ApiService
      return commerce;
    } catch (e) {
      throw Exception('Error al actualizar comercio: $e');
    }
  }

  Future<String> uploadCommerceLogo(String imagePath) async {
    try {
      // Por ahora simulamos la subida hasta que se implemente POST con archivos
      return 'https://via.placeholder.com/150';
    } catch (e) {
      throw Exception('Error al subir logo: $e');
    }
  }
}
