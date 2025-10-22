import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:zonix/features/profile/data/datasources/profile_service.dart';
import 'package:zonix/features/profile/data/models/profile_model.dart';

final logger = Logger();

/// Provider para gestionar el estado del perfil del usuario
/// Maneja tanto usuarios nivel 0 (compradores) como nivel 1 (vendedores)
class ProfileProvider with ChangeNotifier {
  Profile? _profile;
  bool _isLoading = false;
  String? _error;
  String? _userRole;

  // Getters
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userRole => _userRole;
  
  // Computed getters
  bool get hasProfile => _profile != null;
  bool get isSeller => _userRole == 'sellers' || _userRole == 'commerce';
  bool get isBuyer => _userRole == 'users';

  /// Cargar perfil del usuario
  Future<void> loadProfile(int userId) async {
    _setLoading(true);
    _clearError();

    try {
      logger.i('Cargando perfil para usuario: $userId');
      _profile = await ProfileService().getProfileByUserId(userId);
      logger.i('Perfil cargado exitosamente: ${_profile?.firstName} ${_profile?.lastName}');
    } catch (e) {
      logger.e('Error cargando perfil: $e');
      _setError('Error al cargar el perfil: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar perfil por ID específico
  Future<void> loadProfileById(int profileId) async {
    _setLoading(true);
    _clearError();

    try {
      logger.i('Cargando perfil por ID: $profileId');
      _profile = await ProfileService().getProfileById(profileId);
      logger.i('Perfil cargado exitosamente: ${_profile?.firstName} ${_profile?.lastName}');
    } catch (e) {
      logger.e('Error cargando perfil por ID: $e');
      _setError('Error al cargar el perfil: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar perfil
  Future<bool> updateProfile(Profile updatedProfile) async {
    if (_profile == null) return false;

    _setLoading(true);
    _clearError();

    try {
      logger.i('Actualizando perfil: ${updatedProfile.firstName} ${updatedProfile.lastName}');
      
      // Aquí llamarías al servicio de actualización
      // await ProfileService().updateProfile(_profile!.id, updatedProfile);
      
      _profile = updatedProfile;
      logger.i('Perfil actualizado exitosamente');
      return true;
    } catch (e) {
      logger.e('Error actualizando perfil: $e');
      _setError('Error al actualizar el perfil: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Establecer rol del usuario
  void setUserRole(String role) {
    _userRole = role;
    logger.i('Rol del usuario establecido: $role');
    notifyListeners();
  }

  /// Obtener opciones del menú según el rol
  List<ProfileMenuItem> getMenuItems() {
    if (isSeller) {
      return _getSellerMenuItems();
    } else {
      return _getBuyerMenuItems();
    }
  }

  /// Opciones del menú para compradores (Nivel 0)
  List<ProfileMenuItem> _getBuyerMenuItems() {
    return [
      ProfileMenuItem(
        title: 'Mi Perfil',
        subtitle: 'Editar información personal',
        icon: Icons.person_outline,
        color: const Color(0xFF1E40AF),
        route: '/profile',
      ),
      ProfileMenuItem(
        title: 'Mis Direcciones',
        subtitle: 'Gestionar direcciones de envío',
        icon: Icons.location_on_outlined,
        color: const Color(0xFFF59E0B),
        route: '/addresses',
      ),
      ProfileMenuItem(
        title: 'Mis Teléfonos',
        subtitle: 'Gestionar números de contacto',
        icon: Icons.phone_outlined,
        color: const Color(0xFF10B981),
        route: '/phones',
      ),
      ProfileMenuItem(
        title: 'Mis Documentos',
        subtitle: 'Gestionar documentos personales',
        icon: Icons.description_outlined,
        color: const Color(0xFF3B82F6),
        route: '/documents',
      ),
      ProfileMenuItem(
        title: 'Mis Pedidos',
        subtitle: 'Ver historial de compras',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF8B5CF6),
        route: '/orders',
      ),
    ];
  }

  /// Opciones del menú para vendedores (Nivel 1)
  List<ProfileMenuItem> _getSellerMenuItems() {
    return [
      ProfileMenuItem(
        title: 'Mi Perfil',
        subtitle: 'Editar información personal',
        icon: Icons.person_outline,
        color: const Color(0xFF1E40AF),
        route: '/profile',
      ),
      ProfileMenuItem(
        title: 'Mis Productos',
        subtitle: 'Gestionar productos de mi tienda',
        icon: Icons.inventory_outlined,
        color: const Color(0xFF10B981),
        route: '/seller/products',
      ),
      ProfileMenuItem(
        title: 'Mis Pedidos',
        subtitle: 'Gestionar pedidos recibidos',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF8B5CF6),
        route: '/seller/orders',
      ),
      ProfileMenuItem(
        title: 'Dashboard',
        subtitle: 'Estadísticas de ventas',
        icon: Icons.dashboard_outlined,
        color: const Color(0xFFF59E0B),
        route: '/seller/dashboard',
      ),
      ProfileMenuItem(
        title: 'Configuración de Tienda',
        subtitle: 'Configurar mi tienda',
        icon: Icons.store_outlined,
        color: const Color(0xFF3B82F6),
        route: '/seller/store',
      ),
    ];
  }

  /// Limpiar estado
  void clearProfile() {
    _profile = null;
    _userRole = null;
    _clearError();
    notifyListeners();
  }

  /// Resetear estado
  void reset() {
    _profile = null;
    _userRole = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Modelo para elementos del menú de perfil
class ProfileMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  ProfileMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
