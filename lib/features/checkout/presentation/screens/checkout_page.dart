import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:zonix/features/checkout/data/datasources/address_api_service.dart';
import 'package:zonix/features/checkout/data/models/address_model.dart';
import 'package:zonix/features/checkout/presentation/widgets/address_selector.dart';
import 'package:zonix/features/checkout/presentation/widgets/shipping_method_selector.dart';
import 'package:zonix/features/checkout/presentation/widgets/checkout_order_summary.dart';
import 'package:zonix/features/checkout/presentation/widgets/order_success_dialog.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final AddressApiService _addressService = AddressApiService();
  List<AddressModel> _addresses = [];
  bool _loadingAddresses = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _loadingAddresses = true);

    try {
      final checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
      
      // Cargar resumen de checkout
      await checkoutProvider.loadCheckoutSummary();
      
      // Cargar direcciones
      _addresses = await _addressService.getUserAddresses();
      
      // Seleccionar dirección por defecto
      final defaultAddress = _addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => _addresses.isNotEmpty ? _addresses.first : throw Exception('Sin direcciones'),
      );
      
      if (_addresses.isNotEmpty && mounted) {
        checkoutProvider.setShippingAddress(defaultAddress);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingAddresses = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, child) {
          if (checkoutProvider.isLoading || _loadingAddresses) {
            return const Center(child: CircularProgressIndicator());
          }

          if (checkoutProvider.error != null) {
            return _buildError(context, checkoutProvider.error!);
          }

          if (checkoutProvider.cartItems.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              // Stepper header
              _buildStepperHeader(context),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_currentStep == 0) ...[
                        // Paso 1: Dirección
                        AddressSelector(
                          addresses: _addresses,
                          selectedAddress: checkoutProvider.selectedShippingAddress,
                          onAddressSelected: (address) {
                            checkoutProvider.setShippingAddress(address);
                          },
                          onAddNewAddress: () {
                            // TODO: Navigate to add address page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Agregar dirección - Pendiente UI')),
                            );
                          },
                        ),
                      ] else if (_currentStep == 1) ...[
                        // Paso 2: Método de envío
                        ShippingMethodSelector(
                          selectedMethod: checkoutProvider.deliveryType,
                          onMethodSelected: (method) {
                            checkoutProvider.setDeliveryType(method);
                          },
                        ),
                      ] else if (_currentStep == 2) ...[
                        // Paso 3: Resumen
                        CheckoutOrderSummary(
                          items: checkoutProvider.cartItems,
                          summary: checkoutProvider.checkoutSummary!,
                          deliveryType: checkoutProvider.deliveryType,
                        ),
                        const SizedBox(height: 16),
                        // Notas opcionales
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Notas del pedido (opcional)',
                            hintText: 'Instrucciones especiales para la entrega',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            checkoutProvider.setNotes(value);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Botones de navegación
              _buildNavigationButtons(context, checkoutProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepperHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          _buildStepIndicator(context, 0, 'Dirección'),
          _buildStepDivider(context, 0),
          _buildStepIndicator(context, 1, 'Envío'),
          _buildStepDivider(context, 1),
          _buildStepIndicator(context, 2, 'Confirmar'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int step, String label) {
    final isActive = _currentStep >= step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(BuildContext context, int step) {
    final isCompleted = _currentStep > step;

    return Container(
      height: 2,
      width: 40,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted
          ? Theme.of(context).primaryColor
          : Colors.grey.shade300,
    );
  }

  Widget _buildNavigationButtons(BuildContext context, CheckoutProvider checkoutProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Atrás'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: checkoutProvider.isReadyToCheckout && !checkoutProvider.isLoading
                  ? () => _handleNextStep(context, checkoutProvider)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: checkoutProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_currentStep < 2 ? 'Continuar' : 'Confirmar Orden'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNextStep(BuildContext context, CheckoutProvider checkoutProvider) async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Confirmar orden
      final order = await checkoutProvider.confirmCheckout();
      
      if (order != null && mounted) {
        // Mostrar dialog de éxito
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OrderSuccessDialog(
            order: order,
            onViewOrder: () {
              Navigator.of(context).pop(); // Cerrar dialog
              Navigator.of(context).pop(); // Volver atrás
              // TODO: Navigate to order detail page
            },
            onContinueShopping: () {
              Navigator.of(context).pop(); // Cerrar dialog
              Navigator.of(context).pop(); // Volver atrás
            },
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkoutProvider.error ?? 'Error al crear orden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadData(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'El carrito está vacío',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver al Catálogo'),
          ),
        ],
      ),
    );
  }
}

