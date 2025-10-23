import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/core/utils/app_colors.dart';
import 'package:zonix/features/profile/presentation/providers/profile_provider.dart';
import 'package:zonix/features/profile/data/models/commerce_model.dart';

class CommerceFormModal extends StatefulWidget {
  const CommerceFormModal({super.key});

  @override
  State<CommerceFormModal> createState() => _CommerceFormModalState();
}

class _CommerceFormModalState extends State<CommerceFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _rifController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<String> _selectedPaymentMethods = [];
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'stripe',
    'paypal',
    'binance',
    'pago_movil',
    'zelle',
  ];

  @override
  void initState() {
    super.initState();
    _loadCommerceData();
  }

  void _loadCommerceData() {
    final commerce = context.read<ProfileProvider>().commerce;
    if (commerce != null) {
      _businessNameController.text = commerce.businessName ?? '';
      _businessTypeController.text = commerce.businessType ?? '';
      _rifController.text = commerce.rif ?? '';
      _bankAccountController.text = commerce.bankAccount ?? '';
      _phoneController.text = commerce.phone ?? '';
      _selectedPaymentMethods.addAll(commerce.paymentMethods ?? []);
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
                  const Text(
                    'Editar Datos del Comercio',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre del negocio
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Negocio *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre del negocio es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tipo de negocio
                  TextFormField(
                    controller: _businessTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Negocio *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El tipo de negocio es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // RIF
                  TextFormField(
                    controller: _rifController,
                    decoration: const InputDecoration(
                      labelText: 'RIF *',
                      hintText: 'J-123456789',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El RIF es requerido';
                      }
                      if (!RegExp(r'^[VEJPG]-\d{8,9}$').hasMatch(value)) {
                        return 'Formato de RIF inválido (Ej: J-12345678)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cuenta bancaria
                  TextFormField(
                    controller: _bankAccountController,
                    decoration: const InputDecoration(
                      labelText: 'Cuenta Bancaria',
                      hintText: '0134-0000-0000-0000-0000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Teléfono
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono del Negocio',
                      hintText: '+58 412-1234567',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Métodos de pago
                  Text(
                    'Métodos de Pago Aceptados',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._paymentMethods.map((method) => CheckboxListTile(
                        title: Text(_getPaymentMethodName(method)),
                        value: _selectedPaymentMethods.contains(method),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedPaymentMethods.add(method);
                            } else {
                              _selectedPaymentMethods.remove(method);
                            }
                          });
                        },
                      )),
                  const SizedBox(height: 16),

                  // Logo (placeholder)
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
                          'Función de subida de logo próximamente',
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveCommerce,
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

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'stripe':
        return 'Stripe';
      case 'paypal':
        return 'PayPal';
      case 'binance':
        return 'Binance';
      case 'pago_movil':
        return 'Pago Móvil';
      case 'zelle':
        return 'Zelle';
      default:
        return method.toUpperCase();
    }
  }

  Future<void> _saveCommerce() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPaymentMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un método de pago')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final commerce = CommerceModel(
        id: context.read<ProfileProvider>().commerce?.id,
        profileId: context.read<ProfileProvider>().profile?.id ?? 1,
        businessName: _businessNameController.text.trim(),
        businessType: _businessTypeController.text.trim(),
        rif: _rifController.text.trim(),
        bankAccount: _bankAccountController.text.trim(),
        phone: _phoneController.text.trim(),
        paymentMethods: _selectedPaymentMethods,
        isVerified:
            context.read<ProfileProvider>().commerce?.isVerified ?? false,
        open: context.read<ProfileProvider>().commerce?.open ?? true,
        schedule: context.read<ProfileProvider>().commerce?.schedule,
      );

      final success =
          await context.read<ProfileProvider>().updateCommerce(commerce);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos del comercio actualizados')),
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
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _rifController.dispose();
    _bankAccountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
