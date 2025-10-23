import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/shared/providers/theme_provider.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    return Container(
      decoration: BoxDecoration(
        color: theme.headerBg,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 20, right: 20),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => _changeProfileImage(context),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ClipOval(
                child: profile?.photoUsers != null
                    ? Image.network(
                        profile!.photoUsers!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildDefaultAvatar(profile),
                      )
                    : _buildDefaultAvatar(profile),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Nombre
          Text(
            profile?.fullName ?? 'Usuario',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 5),

          // Email
          Text(
            profile?.user?.email ?? 'usuario@example.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 8),

          // Badge de rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleName(profile?.role),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(dynamic profile) {
    final initials = _getInitials(profile?.fullName ?? 'U');
    return Container(
      color: AppColors.orange,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String _getRoleName(String? role) {
    switch (role) {
      case 'seller':
        return 'VENDEDOR';
      case 'admin':
        return 'ADMINISTRADOR';
      default:
        return 'COMPRADOR';
    }
  }

  Future<void> _changeProfileImage(BuildContext context) async {
    // TODO: Implementar ImagePicker y subir imagen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de cambio de imagen próximamente')),
    );
  }
}
