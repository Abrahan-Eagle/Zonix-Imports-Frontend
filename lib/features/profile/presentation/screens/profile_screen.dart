import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/shared/providers/theme_provider.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';
import 'package:zonix/features/profile/presentation/widgets/profile_header.dart';
import 'package:zonix/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:zonix/features/profile/presentation/widgets/phones_card.dart';
import 'package:zonix/features/profile/presentation/widgets/addresses_card.dart';
import 'package:zonix/features/profile/presentation/widgets/documents_card.dart';
import 'package:zonix/features/profile/presentation/widgets/commerce_card.dart';
import 'package:zonix/features/profile/presentation/widgets/orders_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar perfil al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: themeProvider.bgSecondary,
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileProvider.hasError
              ? Center(child: Text('Error: ${profileProvider.errorMessage}'))
              : RefreshIndicator(
                  onRefresh: () => profileProvider.loadProfile(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header con avatar y datos
                        const ProfileHeader(),

                        // Container con padding para las cards
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Card de información personal
                              ProfileInfoCard(),
                              const SizedBox(height: 16),

                              // Card de teléfonos
                              PhonesCard(),
                              const SizedBox(height: 16),

                              // Card de direcciones
                              AddressesCard(),
                              const SizedBox(height: 16),

                              // Card de documentos
                              DocumentsCard(),
                              const SizedBox(height: 16),

                              // Card de comercio (solo vendedores)
                              if (profileProvider.isSeller) ...[
                                CommerceCard(),
                                const SizedBox(height: 16),
                              ],

                              // Card de órdenes
                              OrdersCard(),
                              const SizedBox(height: 30),

                              // Botón de cerrar sesión
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _handleLogout(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.red,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cerrar Sesión',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<ProfileProvider>().logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}
