import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/shared/widgets/custom_card.dart';
import 'package:zonix/shared/widgets/card_header.dart';
import 'package:zonix/shared/widgets/status_badge.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';
import 'package:zonix/features/profile/presentation/modals/commerce_form_modal.dart';

class CommerceCard extends StatelessWidget {
  const CommerceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final commerce = context.watch<ProfileProvider>().commerce;

    return CustomCard(
      child: Column(
        children: [
          CardHeader(
            title: 'Datos del Comercio',
            action: ElevatedButton(
              onPressed: () => _showCommerceModal(context),
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
          if (commerce == null)
            _buildEmptyState(context)
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildInfoItem(
                    'Nombre del Negocio', commerce.businessName ?? 'N/A'),
                _buildInfoItem(
                    'Tipo de Negocio', commerce.businessType ?? 'N/A'),
                _buildInfoItem('RIF', commerce.rif ?? 'N/A'),
                _buildInfoItem(
                    'Cuenta Bancaria', _maskBankAccount(commerce.bankAccount)),
                _buildInfoItem(
                    'Estado', commerce.isVerified ? 'Verificado' : 'Pendiente'),
                _buildPaymentMethods(commerce.paymentMethods),
              ],
            ),
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
            Icons.store_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes datos de comercio',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showCommerceModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
            ),
            child: const Text('Configurar Comercio'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(List<String>? methods) {
    if (methods == null || methods.isEmpty) {
      return _buildInfoItem('Métodos de Pago', 'N/A');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MÉTODOS DE PAGO',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: methods
              .map((method) => StatusBadge(
                    text: method.toUpperCase(),
                    color: AppColors.blue,
                  ))
              .toList(),
        ),
      ],
    );
  }

  String _maskBankAccount(String? account) {
    if (account == null || account.isEmpty) return 'N/A';
    if (account.length < 8) return account;
    return '${account.substring(0, 4)}-****-****-${account.substring(account.length - 4)}';
  }

  void _showCommerceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CommerceFormModal(),
    );
  }
}
