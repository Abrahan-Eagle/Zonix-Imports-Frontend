import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/features/profile/data/models/document_model.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';

class DocumentFormModal extends StatefulWidget {
  final DocumentModel? document;
  final bool isEdit;

  const DocumentFormModal({
    super.key,
    this.document,
    required this.isEdit,
  });

  @override
  State<DocumentFormModal> createState() => _DocumentFormModalState();
}

class _DocumentFormModalState extends State<DocumentFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _documentNumberController = TextEditingController();
  String? _selectedType;
  DateTime? _issuedDate;
  DateTime? _expiresDate;
  bool _isLoading = false;

  final List<Map<String, String>> _documentTypes = [
    {'code': 'ci', 'name': 'Cédula de Identidad'},
    {'code': 'passport', 'name': 'Pasaporte'},
    {'code': 'rif', 'name': 'RIF'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.document != null) {
      _selectedType = widget.document!.type;
      _documentNumberController.text = widget.document!.documentNumber;
      _issuedDate = widget.document!.issuedAt;
      _expiresDate = widget.document!.expiresAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEdit ? 'Ver Documento' : 'Agregar Documento',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tipo de documento
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Documento *',
                      border: OutlineInputBorder(),
                    ),
                    items: _documentTypes
                        .map((type) => DropdownMenuItem(
                              value: type['code'],
                              child: Text(type['name']!),
                            ))
                        .toList(),
                    onChanged: widget.document?.approved == true
                        ? null
                        : (value) => setState(() => _selectedType = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona un tipo de documento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Número de documento
                  TextFormField(
                    controller: _documentNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Documento *',
                      hintText: 'Ej: V-12345678',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: widget.document?.approved == true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El número de documento es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fechas
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: widget.document?.approved == true
                              ? null
                              : _selectIssuedDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Emisión',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _issuedDate != null
                                  ? '${_issuedDate!.day}/${_issuedDate!.month}/${_issuedDate!.year}'
                                  : 'Seleccionar fecha',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: widget.document?.approved == true
                              ? null
                              : _selectExpiresDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Vencimiento',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _expiresDate != null
                                  ? '${_expiresDate!.day}/${_expiresDate!.month}/${_expiresDate!.year}'
                                  : 'Seleccionar fecha',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Imágenes (placeholder)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Función de subida de imágenes próximamente',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      if (widget.document?.approved != true) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveDocument,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text('Guardar'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectIssuedDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _issuedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _issuedDate = date;
      });
    }
  }

  Future<void> _selectExpiresDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _expiresDate ?? DateTime.now().add(const Duration(days: 365 * 10)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );

    if (date != null) {
      setState(() {
        _expiresDate = date;
      });
    }
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final document = DocumentModel(
        id: widget.isEdit ? widget.document?.id : null,
        profileId: context.read<ProfileProvider>().profile?.id ?? 1,
        type: _selectedType!,
        documentNumber: _documentNumberController.text.trim(),
        issuedAt: _issuedDate,
        expiresAt: _expiresDate,
        approved: false,
      );

      bool success;
      if (widget.isEdit && widget.document != null) {
        // Update not implemented for documents
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Actualización de documentos próximamente')),
        );
        return;
      } else {
        success =
            await context.read<ProfileProvider>().createDocument(document);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento agregado')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error: ${context.read<ProfileProvider>().errorMessage}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
  }
}
