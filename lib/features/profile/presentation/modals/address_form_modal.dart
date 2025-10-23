import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/features/profile/data/models/address_model.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';

class AddressFormModal extends StatefulWidget {
  final AddressModel? address;
  final bool isEdit;

  const AddressFormModal({
    super.key,
    this.address,
    required this.isEdit,
  });

  @override
  State<AddressFormModal> createState() => _AddressFormModalState();
}

class _AddressFormModalState extends State<AddressFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _referenceController = TextEditingController();
  String? _selectedState;
  String? _selectedCity;
  bool _isDefault = false;
  bool _isLoading = false;

  final List<Map<String, String>> _states = [
    {'id': '1', 'name': 'Distrito Capital'},
    {'id': '2', 'name': 'Miranda'},
    {'id': '3', 'name': 'Carabobo'},
    {'id': '4', 'name': 'Zulia'},
  ];

  final List<Map<String, String>> _cities = [
    {'id': '1', 'name': 'Caracas', 'state_id': '1'},
    {'id': '2', 'name': 'Valencia', 'state_id': '3'},
    {'id': '3', 'name': 'Maracaibo', 'state_id': '4'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.address != null) {
      _streetController.text = widget.address!.street;
      _houseNumberController.text = widget.address!.houseNumber;
      _postalCodeController.text = widget.address!.postalCode ?? '';
      _addressLine2Controller.text = widget.address!.addressLine2 ?? '';
      _referenceController.text = widget.address!.reference ?? '';
      _selectedState = widget.address!.cityId.toString();
      _isDefault = widget.address!.isDefault;
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
                    widget.isEdit ? 'Editar Dirección' : 'Agregar Dirección',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Estado
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(
                      labelText: 'Estado *',
                      border: OutlineInputBorder(),
                    ),
                    items: _states
                        .map((state) => DropdownMenuItem(
                              value: state['id'],
                              child: Text(state['name']!),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                        _selectedCity = null; // Reset city when state changes
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona un estado';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Ciudad
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad *',
                      border: OutlineInputBorder(),
                    ),
                    items: _cities
                        .where((city) => city['state_id'] == _selectedState)
                        .map((city) => DropdownMenuItem(
                              value: city['id'],
                              child: Text(city['name']!),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCity = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona una ciudad';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Calle
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      labelText: 'Calle/Avenida *',
                      hintText: 'Ej: Av. Principal',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La calle es requerida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Número y código postal
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _houseNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Número de Casa/Edif. *',
                            hintText: 'Ej: Edif. A-5',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El número es requerido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Código Postal',
                            hintText: '1010',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Línea 2
                  TextFormField(
                    controller: _addressLine2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Línea 2 (Apartamento, Piso, etc.)',
                      hintText: 'Ej: Piso 5, Apto 501',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Referencia
                  TextFormField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Referencia',
                      hintText: 'Puntos de referencia cercanos...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Checkbox
                  CheckboxListTile(
                    title: const Text('Dirección por Defecto'),
                    value: _isDefault,
                    onChanged: (value) =>
                        setState(() => _isDefault = value ?? false),
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
                          onPressed: _isLoading ? null : _saveAddress,
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

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final address = AddressModel(
        id: widget.isEdit ? widget.address?.id : null,
        profileId: context.read<ProfileProvider>().profile?.id ?? 1,
        cityId: int.parse(_selectedCity!),
        street: _streetController.text.trim(),
        houseNumber: _houseNumberController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        reference: _referenceController.text.trim(),
        isDefault: _isDefault,
        status: 'active',
        cityName: 'Caracas',
        stateName: 'Distrito Capital',
      );

      bool success;
      if (widget.isEdit && widget.address != null) {
        success = await context.read<ProfileProvider>().updateAddress(address);
      } else {
        success = await context.read<ProfileProvider>().createAddress(address);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isEdit
                  ? 'Dirección actualizada'
                  : 'Dirección agregada')),
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
    _streetController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    _addressLine2Controller.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}
