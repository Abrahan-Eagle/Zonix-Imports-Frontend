import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/shared/providers/theme_provider.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';
import 'package:zonix/shared/widgets/custom_card.dart';
import 'package:zonix/shared/widgets/card_header.dart';
import 'package:zonix/features/profile/presentation/modals/edit_profile_modal.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    return CustomCard(
      child: Column(
        children: [
          CardHeader(
            title: 'Información Personal',
            action: ElevatedButton(
              onPressed: () => _showEditProfileModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Editar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Grid de información - igual al HTML
          LayoutBuilder(
            builder: (context, constraints) {
              // 1 columna en móvil (< 768px), 2 columnas en tablet+
              final crossAxisCount = constraints.maxWidth < 768 ? 1 : 2;
              
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: crossAxisCount == 1 ? 4.0 : 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildInfoItem(
                    theme,
                    'Primer Nombre',
                    profile?.firstName ?? 'N/A',
                  ),
                  _buildInfoItem(
                    theme,
                    'Segundo Nombre',
                    profile?.middleName ?? 'N/A',
                  ),
                  _buildInfoItem(
                    theme,
                    'Primer Apellido',
                    profile?.lastName ?? 'N/A',
                  ),
                  _buildInfoItem(
                    theme,
                    'Segundo Apellido',
                    profile?.secondLastName ?? 'N/A',
                  ),
                  _buildInfoItem(
                    theme,
                    'Fecha de Nacimiento',
                    profile?.dateOfBirth != null
                        ? '${profile!.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}'
                        : 'N/A',
                  ),
                  _buildInfoItem(
                    theme,
                    'Estado del Perfil',
                    _getStatusText(profile?.status),
                    statusColor: _getStatusColor(profile?.status),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(ThemeProvider theme, String label, String value,
      {Color? statusColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.textSecondary,
            letterSpacing: 0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (statusColor != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'completeData':
        return 'Completo';
      case 'incompleteData':
        return 'Incompleto';
      case 'notverified':
        return 'No Verificado';
      default:
        return 'N/A';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completeData':
        return AppColors.green;
      case 'incompleteData':
        return AppColors.orange;
      case 'notverified':
        return AppColors.gray;
      default:
        return AppColors.gray;
    }
  }

  void _showEditProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileModal(),
    );
  }
}
