import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zonix/features/profile/data/models/profile_model.dart';
import 'package:logger/logger.dart';

final logger = Logger();
const FlutterSecureStorage _storage = FlutterSecureStorage();

class UserProvider with ChangeNotifier {
  Profile? _profile;
  bool _isAuthenticated = false;
  String? _userRole;
  int? _userId;
  int _userLevel = 0; // 0 = Comprador, 1 = Vendedor

  // Getters
  Profile? get profile => _profile;
  bool get isAuthenticated => _isAuthenticated;
  String? get userRole => _userRole;
  int? get userId => _userId;
  int get userLevel => _userLevel;

  // Métodos de autenticación
  Future<void> setAuthenticatedForTest({required String role}) async {
    _isAuthenticated = true;
    _userRole = role;
    _userLevel = role == 'commerce' ? 1 : 0;
    await _saveAuthState();
    notifyListeners();
  }

  Future<void> checkAuthentication() async {
    try {
      if (kIsWeb || kDebugMode) {
        // En modo debug o web, no usar FlutterSecureStorage
        _isAuthenticated = false;
        _userRole = null;
        _userId = null;
        _userLevel = 0;
        notifyListeners();
        return;
      }

      final token = await _storage.read(key: 'token');
      final role = await _storage.read(key: 'role');
      final userIdStr = await _storage.read(key: 'userId');

      if (token != null && role != null && userIdStr != null) {
        _isAuthenticated = true;
        _userRole = role;
        _userId = int.tryParse(userIdStr);
        _userLevel = role == 'commerce' ? 1 : 0;
      } else {
        _isAuthenticated = false;
        _userRole = null;
        _userId = null;
        _userLevel = 0;
      }
      notifyListeners();
    } catch (e) {
      logger.e('Error checking authentication: $e');
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      if (!_isAuthenticated) return null;

      // Simular datos de usuario para MVP
      return {
        'id': _userId,
        'userId': _userId, // Agregar userId para compatibilidad
        'role': _userRole,
        'level': _userLevel,
        'profile': _profile?.toJson(),
      };
    } catch (e) {
      logger.e('Error getting user details: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      if (!kIsWeb && !kDebugMode) {
        await _storage.delete(key: 'token');
        await _storage.delete(key: 'role');
        await _storage.delete(key: 'userId');
      }

      _isAuthenticated = false;
      _userRole = null;
      _userId = null;
      _userLevel = 0;
      _profile = null;

      notifyListeners();
      logger.i('User logged out successfully');
    } catch (e) {
      logger.e('Error during logout: $e');
    }
  }

  // Métodos de perfil
  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  // Método para tests que permite establecer null
  void setProfileForTest(Profile? profile) {
    _profile = profile;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }

  // Métodos adicionales para compatibilidad
  void setProfileCreated(bool value) {
    // Método para compatibilidad con código existente
    notifyListeners();
  }

  void setPhoneCreated(bool value) {
    // Método para compatibilidad con código existente
    notifyListeners();
  }

  // Métodos privados
  Future<void> _saveAuthState() async {
    try {
      if (kIsWeb || kDebugMode) {
        // En modo debug o web, no usar FlutterSecureStorage
        return;
      }

      if (_userRole != null) {
        await _storage.write(key: 'role', value: _userRole!);
      }
      if (_userId != null) {
        await _storage.write(key: 'userId', value: _userId.toString());
      }
    } catch (e) {
      logger.e('Error saving auth state: $e');
    }
  }
}
