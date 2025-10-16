import 'package:flutter/material.dart';
import 'package:zonix/features/checkout/data/models/address_model.dart';

class AddressSelector extends StatelessWidget {
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;
  final Function(AddressModel) onAddressSelected;
  final VoidCallback? onAddNewAddress;

  const AddressSelector({
    super.key,
    required this.addresses,
    this.selectedAddress,
    required this.onAddressSelected,
    this.onAddNewAddress,
  });

  @override
  Widget build(BuildContext context) {
    if (addresses.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dirección de Envío',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onAddNewAddress != null)
              TextButton.icon(
                onPressed: onAddNewAddress,
                icon: const Icon(Icons.add),
                label: const Text('Nueva'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...addresses.map((address) => _buildAddressCard(context, address)),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    final isSelected = selectedAddress?.id == address.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onAddressSelected(address),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Radio button
              Radio<int>(
                value: address.id,
                groupValue: selectedAddress?.id,
                onChanged: (_) => onAddressSelected(address),
              ),
              const SizedBox(width: 12),
              // Address info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address.shortAddress,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Principal',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (address.reference != null && address.reference!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Ref: ${address.reference}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes direcciones registradas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega una dirección de envío para continuar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            if (onAddNewAddress != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAddNewAddress,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Dirección'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

