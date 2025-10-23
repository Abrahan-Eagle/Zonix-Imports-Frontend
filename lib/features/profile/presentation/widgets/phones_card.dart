import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/shared/widgets/custom_card.dart';
import 'package:zonix/shared/widgets/card_header.dart';
import 'package:zonix/shared/widgets/add_button.dart';
import 'package:zonix/shared/widgets/list_item_tile.dart';
import 'package:zonix/shared/widgets/status_badge.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';
import 'package:zonix/features/profile/presentation/modals/phone_form_modal.dart';

class PhonesCard extends StatelessWidget {
  const PhonesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final phones = context.watch<ProfileProvider>().phones;

    return CustomCard(
      child: Column(
        children: [
          CardHeader(
            title: 'Teléfonos',
            action: AddButton(
              onPressed: () => _showPhoneModal(context, isEdit: false),
            ),
          ),
          if (phones.isEmpty)
            _buildEmptyState(context)
          else
            ...phones.map((phone) => ListItemTile(
                  title: phone.fullNumber,
                  subtitle: _getOperatorName(phone.operatorCode),
                  badge: phone.isPrimary
                      ? const StatusBadge(
                          text: 'Principal',
                          color: AppColors.blue,
                        )
                      : null,
                  onTap: () =>
                      _showPhoneModal(context, phone: phone, isEdit: true),
                )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.phone_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes teléfonos registrados',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showPhoneModal(context, isEdit: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
            ),
            child: const Text('Agregar Teléfono'),
          ),
        ],
      ),
    );
  }

  String _getOperatorName(String operatorCode) {
    switch (operatorCode) {
      case '0412':
        return 'Movilnet';
      case '0414':
        return 'Movistar';
      case '0424':
        return 'Movistar';
      case '0416':
        return 'Movistar';
      case '0426':
        return 'Movistar';
      default:
        return 'Operador';
    }
  }

  void _showPhoneModal(BuildContext context, {phone, required bool isEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhoneFormModal(
        phone: phone,
        isEdit: isEdit,
      ),
    );
  }
}
