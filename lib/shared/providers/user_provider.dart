import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
      final token = await _storage.read(key: 'token');
      final role = await _storage.read(key: 'role');
      final userIdStr = await _storage.read(key: 'userId');

      if (token != null && role != null && userIdStr != null) {
        _isAuthenticated = true;
        _userRole = role;
        _userId = int.tryParse(userIdStr);
        _userLevel = role == 'commerce' ? 1 : 0;
        logger
            .i('✅ Autenticación verificada: userId=$_userId, role=$_userRole');
      } else {
        _isAuthenticated = false;
        _userRole = null;
        _userId = null;
        _userLevel = 0;
        logger.w('⚠️ No se encontró autenticación almacenada');
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
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'role');
      await _storage.delete(key: 'userId');

      _isAuthenticated = false;
      _userRole = null;
      _userId = null;
      _userLevel = 0;
      _profile = null;

      notifyListeners();
      logger.i('🚪 Sesión cerrada exitosamente');
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
      if (_userRole != null) {
        await _storage.write(key: 'role', value: _userRole!);
      }
      if (_userId != null) {
        await _storage.write(key: 'userId', value: _userId.toString());
      }
      logger.i(
          '💾 Estado de autenticación guardado: userId=$_userId, role=$_userRole');
    } catch (e) {
      logger.e('Error saving auth state: $e');
    }
  }
}
