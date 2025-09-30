import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/profile/presentation/screens/documents/document_list_screen.dart';

import 'package:zonix/features/profile/presentation/screens/phones/phone_list_screen.dart';
import 'package:zonix/shared/providers/user_provider.dart';
import 'package:zonix/features/profile/presentation/screens/profile_page.dart';
import 'package:zonix/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:zonix/features/profile/presentation/screens/addresses/adresse_list_screen.dart';
import 'package:zonix/features/profile/data/datasources/profile_service.dart';

// Configuración del logger
final logger = Logger();

// Paleta de colores profesional
class ZonixColors {
  static const Color primaryBlue = Color(0xFF1E40AF); // Azul profesional
  static const Color secondaryBlue = Color(0xFF3B82F6); // Azul secundario
  static const Color accentBlue = Color(0xFF60A5FA); // Azul de acento
  static const Color darkGray = Color(0xFF1E293B); // Gris oscuro
  static const Color mediumGray = Color(0xFF64748B); // Gris medio
  static const Color lightGray = Color(0xFFF1F5F9); // Gris claro
  static const Color white = Color(0xFFFFFFFF); // Blanco
  static const Color successGreen = Color(0xFF10B981); // Verde éxito
  static const Color warningOrange = Color(0xFFF59E0B); // Naranja advertencia
  static const Color errorRed = Color(0xFFEF4444); // Rojo error

  // Colores adicionales para efectos modernos
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color neumorphicLight = Color(0xFFFFFFFF);
  static const Color neumorphicDark = Color(0xFFE0E0E0);
}

class SettingsPage2 extends StatefulWidget {
  const SettingsPage2({super.key});

  @override
  State<SettingsPage2> createState() => _SettingsPage2State();
}

class _SettingsPage2State extends State<SettingsPage2> {
  dynamic _profile;
  String? _email;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Future<void> _loadProfile() async {
  //   setState(() {
  //     _loading = true;
  //     _error = null;
  //   });
  //   try {
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //     final userDetails = await userProvider.getUserDetails();
  //     final id = userDetails['userId'];
  //     if (id == null || id is! int) {
  //       throw Exception('El ID del usuario es inválido: $id');
  //     }
  //     _email = userDetails['users']['email'];
  //     _profile = await ProfileService().getProfileById(id);
  //     logger.e('Error obteniendo el ID del usuario: $_profile');
  //   } catch (e) {
  //     logger.e('Error obteniendo el ID del usuario: $e');
  //     _error = 'Error al cargar el perfil';
  //   } finally {
  //     setState(() {
  //       _loading = false;
  //     });
  //   }
  // }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userDetails = await userProvider.getUserDetails();

      // More flexible ID handling
      final id = userDetails?['userId'];
      if (id == null) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      // Convert to int if necessary
      final userId = id is int ? id : int.tryParse(id.toString());
      if (userId == null) {
        throw Exception('El ID del usuario no es válido: $id');
      }

      _email = userDetails?['users']?['email'];
      _profile = await ProfileService().getProfileById(userId);

      // Log success as info, not error
      logger.i('Perfil cargado correctamente: $_profile');
    } catch (e) {
      // logger.e('Error al cargar el perfil', error: e, stackTrace: stackTrace);
      setState(() {
        // _error = 'Error al cargar el perfil: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Configuraciones")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isTablet = screenWidth > 600;
                final fontSize = isTablet ? 24.0 : 20.0;

                return Text(
                  "Configuraciones",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                );
              },
            ),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? ZonixColors.darkGray
                : ZonixColors.primaryBlue,
            elevation: 0,
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado de usuario destacado
                  Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ZonixColors.darkGray
                        : ZonixColors.white,
                    elevation: 8,
                    shadowColor: ZonixColors.primaryBlue.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: _getProfileImage(_profile?.photo),
                            backgroundColor:
                                ZonixColors.primaryBlue.withOpacity(0.15),
                            child: (_profile?.photo == null)
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 40)
                                : null,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_profile?.firstName ?? ''} ${_profile?.lastName ?? ''}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? ZonixColors.white
                                        : ZonixColors.darkGray,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _email ?? 'Correo no disponible',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ZonixColors.mediumGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sección: Información de cuenta
                  Text(
                    "Mi cuenta",
                    style: TextStyle(
                      color: ZonixColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ZonixColors.darkGray
                        : ZonixColors.white,
                    elevation: 6,
                    shadowColor: ZonixColors.primaryBlue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildListTile(
                          context,
                          icon: Icons.person_outline_rounded,
                          color: ZonixColors.primaryBlue,
                          title: "Perfil",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePagex(
                                    userId: userProvider.userId ?? 0),
                              ),
                            );
                          },
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.folder_outlined,
                          color: ZonixColors.secondaryBlue,
                          title: "Documentos",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DocumentListScreen(
                                    userId: userProvider.userId ?? 0),
                              ),
                            );
                          },
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.location_on_outlined,
                          color: ZonixColors.warningOrange,
                          title: "Direcciones",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddressPage(
                                    userId: userProvider.userId ?? 0),
                              ),
                            );
                          },
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.phone_outlined,
                          color: ZonixColors.successGreen,
                          title: "Teléfonos",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneScreen(
                                    userId: userProvider.userId ?? 0),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Después de la sección 'Mi cuenta' y antes de 'Funcionalidades Avanzadas':
                  if (userProvider.userRole == 'commerce') ...[
                    const SizedBox(height: 24),
                    Text(
                      "Gestión del comercio",
                      style: TextStyle(
                        color: ZonixColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? ZonixColors.darkGray
                          : ZonixColors.white,
                      elevation: 6,
                      shadowColor: ZonixColors.primaryBlue.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Gestión del comercio (próximamente)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Sección: Funcionalidades Avanzadas
                  Text(
                    "Funcionalidades Avanzadas",
                    style: TextStyle(
                      color: ZonixColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ZonixColors.darkGray
                        : ZonixColors.white,
                    elevation: 2,
                    shadowColor: ZonixColors.primaryBlue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        // Historial (próximamente)
                        // Exportar datos (próximamente)
                        // Privacidad (próximamente)
                        // Eliminación de cuenta (próximamente)
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sección: Administración y Ayuda
                  Text(
                    "Administración y Ayuda",
                    style: TextStyle(
                      color: ZonixColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ZonixColors.darkGray
                        : ZonixColors.white,
                    elevation: 2,
                    shadowColor: ZonixColors.primaryBlue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        // Notificaciones (próximamente)
                        // Ayuda (próximamente)
                        // Acerca de (próximamente)
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón de cerrar sesión
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await userProvider.logout();
                          if (!mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        icon: const Icon(
                          Icons.logout_sharp,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: const Text(
                          "Cerrar sesión",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ZonixColors.errorRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          elevation: 4,
                          shadowColor: ZonixColors.errorRed.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      String? subtitle,
      required VoidCallback onTap}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 24),
        radius: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark
              ? ZonixColors.white
              : ZonixColors.darkGray,
          fontSize: 16,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: ZonixColors.mediumGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: ZonixColors.mediumGray,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  ImageProvider<Object> _getProfileImage(String? profilePhoto) {
    if (profilePhoto != null && profilePhoto.isNotEmpty) {
      // Detectar URLs de placeholder y evitarlas
      if (profilePhoto.contains('via.placeholder.com') ||
          profilePhoto.contains('placeholder.com') ||
          profilePhoto.contains('placehold.it')) {
        logger.w(
            'Detectada URL de placeholder, usando imagen local: $profilePhoto');
        return const AssetImage('assets/default_avatar.png');
      }

      logger.i('Usando foto del perfil: $profilePhoto');
      return NetworkImage(profilePhoto);
    }

    logger.w('Usando imagen predeterminada');
    return const AssetImage('assets/default_avatar.png');
  }
}
