import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/shared/widgets/custom_card.dart';
import 'package:zonix/shared/widgets/card_header.dart';
import 'package:zonix/shared/widgets/add_button.dart';
import 'package:zonix/shared/widgets/list_item_tile.dart';
import 'package:zonix/shared/widgets/status_badge.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';
import 'package:zonix/features/profile/presentation/modals/document_form_modal.dart';

class DocumentsCard extends StatelessWidget {
  const DocumentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final documents = context.watch<ProfileProvider>().documents;

    return CustomCard(
      child: Column(
        children: [
          CardHeader(
            title: 'Documentos de Identidad',
            action: AddButton(
              onPressed: () => _showDocumentModal(context, isEdit: false),
            ),
          ),
          if (documents.isEmpty)
            _buildEmptyState(context)
          else
            ...documents.map((document) => ListItemTile(
                  title:
                      '${_getDocumentTypeName(document.type)} - ${document.documentNumber}',
                  subtitle:
                      'Emitida: ${_formatDate(document.issuedAt)} | Vence: ${_formatDate(document.expiresAt)}',
                  badge: document.approved
                      ? const StatusBadge(
                          text: 'Verificado',
                          color: AppColors.green,
                        )
                      : const StatusBadge(
                          text: 'Pendiente',
                          color: AppColors.orange,
                        ),
                  onTap: () => _showDocumentModal(context,
                      document: document, isEdit: true),
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
            Icons.badge_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes documentos registrados',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showDocumentModal(context, isEdit: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
            ),
            child: const Text('Agregar Documento'),
          ),
        ],
      ),
    );
  }

  String _getDocumentTypeName(String type) {
    switch (type) {
      case 'ci':
        return 'Cédula de Identidad';
      case 'passport':
        return 'Pasaporte';
      case 'rif':
        return 'RIF';
      default:
        return 'Documento';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDocumentModal(BuildContext context,
      {document, required bool isEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DocumentFormModal(
        document: document,
        isEdit: isEdit,
      ),
    );
  }
}
