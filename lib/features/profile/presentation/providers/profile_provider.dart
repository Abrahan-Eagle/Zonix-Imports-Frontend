import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zonix/features/profile/data/datasources/unified_profile_service.dart';
import 'package:zonix/features/profile/data/models/profile_model.dart';
import 'package:zonix/features/profile/data/models/phone_model.dart';
import 'package:zonix/features/profile/data/models/address_model.dart';
import 'package:zonix/features/profile/data/models/document_model.dart';
import 'package:zonix/features/profile/data/models/commerce_model.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  final UnifiedProfileService _profileService;

  ProfileProvider(this._profileService);

  ProfileStatus _status = ProfileStatus.initial;
  Profile? _profile;
  List<PhoneModel> _phones = [];
  List<AddressModel> _addresses = [];
  List<DocumentModel> _documents = [];
  CommerceModel? _commerce;
  String? _errorMessage;

  // Getters
  ProfileStatus get status => _status;
  Profile? get profile => _profile;
  List<PhoneModel> get phones => _phones;
  List<AddressModel> get addresses => _addresses;
  List<DocumentModel> get documents => _documents;
  CommerceModel? get commerce => _commerce;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ProfileStatus.loading;
  bool get hasError => _status == ProfileStatus.error;

  // Rol del usuario
  String get userRole => _profile?.role ?? 'buyer';
  bool get isSeller => userRole == 'seller' || userRole == 'admin';
  bool get isAdmin => userRole == 'admin';

  // === CARGAR PERFIL COMPLETO ===
  Future<void> loadProfile() async {
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      // Cargar perfil desde el backend
      _profile = await _profileService.getProfile();

      // Cargar teléfonos
      _phones = await _profileService.getPhones();

      // Cargar direcciones
      _addresses = await _profileService.getAddresses();

      // Cargar documentos
      _documents = await _profileService.getDocuments();

      // Cargar comercio si es vendedor
      if (isSeller) {
        _commerce = await _profileService.getCommerce();
      }

      _status = ProfileStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // === ACTUALIZAR PERFIL ===
  Future<bool> updateProfile(Profile profile) async {
    try {
      _profile = await _profileService.updateProfile(profile);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadProfileImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final imageUrl = await _profileService.uploadProfileImage(imageFile);
      _profile = Profile(
        id: _profile?.id ?? 1,
        userId: _profile?.userId ?? 1,
        firstName: _profile?.firstName ?? '',
        middleName: _profile?.middleName,
        lastName: _profile?.lastName ?? '',
        secondLastName: _profile?.secondLastName,
        dateOfBirth: _profile?.dateOfBirth,
        photoUsers: imageUrl,
        role: _profile?.role ?? 'user',
        isVerified: _profile?.isVerified ?? false,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // === TELÉFONOS ===
  Future<void> loadPhones() async {
    try {
      _phones = await _profileService.getPhones();
    } catch (e) {
      print('Error loading phones: $e');
    }
  }

  Future<bool> createPhone(PhoneModel phone) async {
    try {
      final newPhone = await _profileService.createPhone(phone);
      _phones.add(newPhone);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePhone(PhoneModel phone) async {
    try {
      final updatedPhone = await _profileService.updatePhone(phone);
      final index = _phones.indexWhere((p) => p.id == phone.id);
      if (index != -1) {
        _phones[index] = updatedPhone;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePhone(int id) async {
    try {
      await _profileService.deletePhone(id);
      _phones.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // === DIRECCIONES ===
  Future<void> loadAddresses() async {
    try {
      _addresses = await _profileService.getAddresses();
    } catch (e) {
      print('Error loading addresses: $e');
    }
  }

  Future<bool> createAddress(AddressModel address) async {
    try {
      final newAddress = await _profileService.createAddress(address);
      _addresses.add(newAddress);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress(AddressModel address) async {
    try {
      final updatedAddress = await _profileService.updateAddress(address);
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(int id) async {
    try {
      await _profileService.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // === DOCUMENTOS ===
  Future<void> loadDocuments() async {
    try {
      _documents = await _profileService.getDocuments();
    } catch (e) {
      print('Error loading documents: $e');
    }
  }

  Future<bool> createDocument(DocumentModel document) async {
    try {
      final newDocument = await _profileService.createDocument(document);
      _documents.add(newDocument);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocument(int id) async {
    try {
      await _profileService.deleteDocument(id);
      _documents.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // === COMERCIO ===
  Future<void> loadCommerce() async {
    try {
      _commerce = await _profileService.getCommerce();
    } catch (e) {
      print('Error loading commerce: $e');
    }
  }

  Future<bool> updateCommerce(CommerceModel commerce) async {
    try {
      _commerce = await _profileService.updateCommerce(commerce);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadCommerceLogo(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final imageUrl = await _profileService.uploadCommerceLogo(imageFile);
      _commerce = CommerceModel(
        id: _commerce?.id ?? 1,
        profileId: _commerce?.profileId ?? 1,
        businessName: _commerce?.businessName ?? '',
        businessType: _commerce?.businessType ?? 'retail',
        image: imageUrl,
        phone: _commerce?.phone ?? '',
        rif: _commerce?.rif ?? '',
        bankAccount: _commerce?.bankAccount ?? '',
        isVerified: _commerce?.isVerified ?? false,
        open: _commerce?.open ?? true,
        paymentMethods: _commerce?.paymentMethods ?? [],
        schedule: _commerce?.schedule ?? {'monday': '9:00-18:00'},
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // === LOGOUT ===
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    await prefs.remove('userId');

    _profile = null;
    _phones = [];
    _addresses = [];
    _documents = [];
    _commerce = null;
    _status = ProfileStatus.initial;

    notifyListeners();
  }
}
