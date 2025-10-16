import 'package:flutter/material.dart';

class ShippingMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const ShippingMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de Entrega',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildMethodCard(
          context,
          method: 'delivery',
          icon: Icons.local_shipping,
          title: 'Envío a Domicilio',
          subtitle: 'Recibe en la dirección seleccionada',
        ),
        const SizedBox(height: 12),
        _buildMethodCard(
          context,
          method: 'pickup',
          icon: Icons.store,
          title: 'Retiro en Tienda',
          subtitle: 'Recoge en el local del vendedor',
        ),
      ],
    );
  }

  Widget _buildMethodCard(
    BuildContext context, {
    required String method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedMethod == method;

    return Card(
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
        onTap: () => onMethodSelected(method),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Radio button
              Radio<String>(
                value: method,
                groupValue: selectedMethod,
                onChanged: (value) {
                  if (value != null) onMethodSelected(value);
                },
              ),
              const SizedBox(width: 12),
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

