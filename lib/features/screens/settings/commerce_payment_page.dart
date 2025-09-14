import 'package:flutter/material.dart';
import 'package:zonix/features/services/commerce_data_service.dart';
import 'package:flutter/services.dart'; // Added for FilteringTextInputFormatter

// Paleta de colores profesional
class ZonixColors {
  static const Color primaryBlue = Color(0xFF1E40AF); // Azul profesional
  static const Color secondaryBlue = Color(0xFF3B82F6); // Azul secundario
  static const Color accentBlue = Color(0xFF60A5FA); // Azul de acento
  static const Color darkGray = Color(0xFF1E293B); // Gris oscuro
  static const Color mediumGray = Color(0xFF64748B); // Gris medio
  static const Color lightGray = Color(0xFFF1F5F9); // Gris claro
  static const Color white = Color(0xFFFFFFFF); // Blanco
  static const Color successGreen = Color(0xFF10B981); // Verde éxito
  static const Color warningOrange = Color(0xFFF59E0B); // Naranja advertencia
  static const Color errorRed = Color(0xFFEF4444); // Rojo error
  
  // Colores para efectos modernos
  static const Color glassBackground = Color(0x1AFFFFFF); // Fondo glassmorphism
  static const Color neumorphicLight = Color(0xFFFFFFFF); // Neumorfismo claro
  static const Color neumorphicDark = Color(0xFFE0E0E0); // Neumorfismo oscuro
}

class CommercePaymentPage extends StatefulWidget {
  const CommercePaymentPage({Key? key}) : super(key: key);

  @override
  State<CommercePaymentPage> createState() => _CommercePaymentPageState();
}

class _CommercePaymentPageState extends State<CommercePaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _paymentIdController = TextEditingController();
  final _paymentPhoneController = TextEditingController();
  
  String? _bank;
  bool _loading = false;
  bool _initialLoading = true;
  String? _error;
  String? _success;

  final List<String> _banks = [
    'Banco de Venezuela',
    'Banesco',
    'Mercantil',
    'BOD',
    'BNC',
    'Bancaribe',
    'Banco del Tesoro',
    'Banco Plaza',
    'BBVA Provincial',
    'Banco Exterior',
    'Banco Caroní',
    'Banco Sofitasa',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  @override
  void dispose() {
    _paymentIdController.dispose();
    _paymentPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentData() async {
    try {
      setState(() {
        _initialLoading = true;
        _error = null;
      });

      final data = await CommerceDataService.getCommerceData();
      
      setState(() {
        _bank = data['mobile_payment_bank'];
        _paymentIdController.text = data['mobile_payment_id'] ?? '';
        _paymentPhoneController.text = data['mobile_payment_phone'] ?? '';
        _initialLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos: $e';
        _initialLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { 
      _loading = true; 
      _error = null; 
      _success = null; 
    });

    try {
      final data = {
        'bank': _bank,
        'payment_id': _paymentIdController.text,
        'payment_phone': _paymentPhoneController.text,
      };

      await CommerceDataService.updatePaymentData(data);
      
      setState(() {
        _loading = false;
        _success = 'Datos de pago móvil actualizados correctamente.';
      });

      // Limpiar mensaje de éxito después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _success = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error al actualizar datos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_initialLoading) {
      return Scaffold(
        backgroundColor: isDark ? ZonixColors.darkGray : ZonixColors.lightGray,
        appBar: AppBar(
          title: Builder(
            builder: (context) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isTablet = screenWidth > 600;
              final fontSize = isTablet ? 24.0 : 20.0;
              
              return Text(
                'Datos de pago móvil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  letterSpacing: 0.5,
                ),
              );
            },
          ),
          backgroundColor: isDark ? ZonixColors.darkGray : ZonixColors.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? ZonixColors.darkGray : ZonixColors.lightGray,
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isTablet = screenWidth > 600;
            final fontSize = isTablet ? 24.0 : 20.0;
            
            return Text(
              'Datos de pago móvil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
                letterSpacing: 0.5,
              ),
            );
          },
        ),
        backgroundColor: isDark ? ZonixColors.darkGray : ZonixColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Información del banco
              Card(
                elevation: 4,
                color: isDark ? ZonixColors.darkGray : ZonixColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Banco',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                        decoration: InputDecoration(
                          labelText: 'Banco *',
                          labelStyle: TextStyle(color: ZonixColors.mediumGray),
                          filled: true,
                          fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.account_balance, color: ZonixColors.mediumGray),
                        ),
                        dropdownColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                        value: _bank,
                        items: _banks.map((b) => DropdownMenuItem(
                          value: b,
                          child: Text(
                            b,
                            style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                          ),
                        )).toList(),
                        onChanged: (v) => setState(() => _bank = v),
                        validator: (v) => v == null || v.isEmpty ? 'Seleccione un banco' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información de pago móvil
              Card(
                elevation: 4,
                color: isDark ? ZonixColors.darkGray : ZonixColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos de Pago Móvil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _paymentIdController,
                        style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                        decoration: InputDecoration(
                          labelText: 'ID de pago móvil *',
                          labelStyle: TextStyle(color: ZonixColors.mediumGray),
                          hintText: 'Ej: 12345678',
                          hintStyle: TextStyle(color: ZonixColors.mediumGray),
                          filled: true,
                          fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.credit_card, color: ZonixColors.mediumGray),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _paymentPhoneController,
                        style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                        decoration: InputDecoration(
                          labelText: 'Teléfono de pago móvil *',
                          labelStyle: TextStyle(color: ZonixColors.mediumGray),
                          hintText: 'Ej: 04121234567',
                          hintStyle: TextStyle(color: ZonixColors.mediumGray),
                          filled: true,
                          fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.phone_android, color: ZonixColors.mediumGray),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo requerido';
                          final regex = RegExp(r'^\d{11}$');
                          if (!regex.hasMatch(v.replaceAll(RegExp(r'\D'), ''))) {
                            return 'Debe tener 11 dígitos';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información adicional
              Card(
                elevation: 2,
                color: isDark ? ZonixColors.darkGray : ZonixColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: ZonixColors.primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            'Información Importante',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Los datos de pago móvil se utilizan para recibir pagos de los clientes\n'
                        '• Asegúrate de que el número de teléfono esté activo\n'
                        '• El ID de pago móvil debe ser el mismo registrado en tu banco\n'
                        '• Estos datos son confidenciales y seguros',
                        style: TextStyle(
                          fontSize: 14,
                          color: ZonixColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mensajes de estado
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ZonixColors.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ZonixColors.errorRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: ZonixColors.errorRed),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: TextStyle(color: ZonixColors.errorRed))),
                    ],
                  ),
                ),
              
              if (_success != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ZonixColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ZonixColors.successGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: ZonixColors.successGreen),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_success!, style: TextStyle(color: ZonixColors.successGreen))),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                  label: Text(
                    _loading ? 'Guardando...' : 'Guardar cambios',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZonixColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              ),
              
              // Espacio adicional para evitar overflow
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 