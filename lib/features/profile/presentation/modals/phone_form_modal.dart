import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/features/profile/data/models/phone_model.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';

class PhoneFormModal extends StatefulWidget {
  final PhoneModel? phone;
  final bool isEdit;

  const PhoneFormModal({
    super.key,
    this.phone,
    required this.isEdit,
  });

  @override
  State<PhoneFormModal> createState() => _PhoneFormModalState();
}

class _PhoneFormModalState extends State<PhoneFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  String? _selectedOperator;
  bool _isPrimary = false;
  bool _isActive = true;
  bool _isLoading = false;

  final List<Map<String, String>> _operators = [
    {'code': '0412', 'name': 'Movilnet'},
    {'code': '0414', 'name': 'Movistar'},
    {'code': '0424', 'name': 'Movistar'},
    {'code': '0416', 'name': 'Movistar'},
    {'code': '0426', 'name': 'Movistar'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.phone != null) {
      _selectedOperator = widget.phone!.operatorCode;
      _numberController.text = widget.phone!.number;
      _isPrimary = widget.phone!.isPrimary;
      _isActive = widget.phone!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                    widget.isEdit ? 'Editar Teléfono' : 'Agregar Teléfono',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Operador
                  DropdownButtonFormField<String>(
                    value: _selectedOperator,
                    decoration: const InputDecoration(
                      labelText: 'Código de Operador *',
                      border: OutlineInputBorder(),
                    ),
                    items: _operators
                        .map((op) => DropdownMenuItem(
                              value: op['code'],
                              child: Text('${op['code']} - ${op['name']}'),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedOperator = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona un operador';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Número
                  TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      labelText: 'Número *',
                      hintText: '1234567',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 7,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El número es requerido';
                      }
                      if (value.length != 7) {
                        return 'El número debe tener 7 dígitos';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Solo se permiten números';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Checkboxes
                  CheckboxListTile(
                    title: const Text('Teléfono Principal'),
                    value: _isPrimary,
                    onChanged: (value) =>
                        setState(() => _isPrimary = value ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Activo'),
                    value: _isActive,
                    onChanged: (value) =>
                        setState(() => _isActive = value ?? true),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _savePhone,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _savePhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final phone = PhoneModel(
        id: widget.isEdit ? widget.phone?.id : null,
        profileId: context.read<ProfileProvider>().profile?.id ?? 1,
        operatorCode: _selectedOperator!,
        countryCode: '+58',
        number: _numberController.text.trim(),
        isPrimary: _isPrimary,
        isActive: _isActive,
      );

      bool success;
      if (widget.isEdit && widget.phone != null) {
        success = await context.read<ProfileProvider>().updatePhone(phone);
      } else {
        success = await context.read<ProfileProvider>().createPhone(phone);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isEdit
                  ? 'Teléfono actualizado'
                  : 'Teléfono agregado')),
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
    _numberController.dispose();
    super.dispose();
  }
}
