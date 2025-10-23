import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/shared/widgets/custom_card.dart';
import 'package:zonix/shared/widgets/card_header.dart';
import 'package:zonix/shared/widgets/add_button.dart';
import 'package:zonix/shared/widgets/list_item_tile.dart';
import 'package:zonix/shared/widgets/status_badge.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';
import 'package:zonix/features/profile/presentation/modals/address_form_modal.dart';

class AddressesCard extends StatelessWidget {
  const AddressesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<ProfileProvider>().addresses;

    return CustomCard(
      child: Column(
        children: [
          CardHeader(
            title: 'Direcciones',
            action: AddButton(
              onPressed: () => _showAddressModal(context, isEdit: false),
            ),
          ),
          if (addresses.isEmpty)
            _buildEmptyState(context)
          else
            ...addresses.map((address) => ListItemTile(
                  title: '${address.street}, ${address.houseNumber}',
                  subtitle:
                      '${address.cityName ?? 'Ciudad'}, ${address.stateName ?? 'Estado'}',
                  subtitle2: address.reference != null
                      ? 'Ref: ${address.reference}'
                      : null,
                  badge: address.isDefault
                      ? const StatusBadge(
                          text: 'Por Defecto',
                          color: AppColors.green,
                        )
                      : null,
                  onTap: () => _showAddressModal(context,
                      address: address, isEdit: true),
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
            Icons.location_on_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes direcciones registradas',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showAddressModal(context, isEdit: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
            ),
            child: const Text('Agregar Dirección'),
          ),
        ],
      ),
    );
  }

  void _showAddressModal(BuildContext context,
      {address, required bool isEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressFormModal(
        address: address,
        isEdit: isEdit,
      ),
    );
  }
}
