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

class CommerceDataPage extends StatefulWidget {
  const CommerceDataPage({Key? key}) : super(key: key);

  @override
  State<CommerceDataPage> createState() => _CommerceDataPageState();
}

class _CommerceDataPageState extends State<CommerceDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _logoUrl;
  bool _open = false;
  String _schedule = '';
  bool _loading = false;
  bool _initialLoading = true;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _loadCommerceData();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCommerceData() async {
    try {
      setState(() {
        _initialLoading = true;
        _error = null;
      });

      final data = await CommerceDataService.getCommerceData();
      
      setState(() {
        _businessNameController.text = data['business_name'] ?? '';
        _businessTypeController.text = data['business_type'] ?? '';
        _taxIdController.text = data['tax_id'] ?? '';
        _addressController.text = data['address'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _logoUrl = data['image'];
        _open = data['open'] ?? false;
        _schedule = data['schedule'] ?? '';
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
        'business_name': _businessNameController.text,
        'business_type': _businessTypeController.text,
        'tax_id': _taxIdController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'image': _logoUrl,
        'open': _open,
        'schedule': _schedule,
      };

      final result = await CommerceDataService.updateCommerceData(data);
      
      setState(() {
        _loading = false;
        _success = result['message'] ?? 'Datos del comercio actualizados correctamente.';
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

  Future<void> _uploadLogo() async {
    try {
      // TODO: Implementar selección de imagen
      setState(() {
        _loading = true;
        _error = null;
      });

      // Simular subida de imagen
      await Future.delayed(const Duration(seconds: 2));
      final imageUrl = await CommerceDataService.uploadCommerceImage('');
      
      setState(() {
        _logoUrl = imageUrl;
        _loading = false;
        _success = 'Logo subido correctamente.';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error al subir logo: $e';
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
                'Datos del comercio',
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
              'Datos del comercio',
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
              // Logo del comercio
              Card(
                elevation: 4,
                color: isDark ? ZonixColors.darkGray : ZonixColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Logo del Comercio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: ZonixColors.primaryBlue.withOpacity(0.1),
                        backgroundImage: _logoUrl != null ? NetworkImage(_logoUrl!) : null,
                        child: _logoUrl == null 
                          ? Icon(Icons.store, size: 50, color: ZonixColors.mediumGray)
                          : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _uploadLogo,
                        icon: const Icon(Icons.upload),
                        label: const Text('Subir logo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ZonixColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Información básica
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
                        'Información Básica',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _businessNameController,
                        style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                        decoration: InputDecoration(
                          labelText: 'Nombre comercial *',
                          labelStyle: TextStyle(color: ZonixColors.mediumGray),
                          filled: true,
                          fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.store, color: ZonixColors.mediumGray),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _businessTypeController,
                        style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                        decoration: InputDecoration(
                          labelText: 'Tipo de negocio',
                          labelStyle: TextStyle(color: ZonixColors.mediumGray),
                          filled: true,
                          fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.category, color: ZonixColors.mediumGray),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _taxIdController,
                        style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                        decoration: InputDecoration(
                          labelText: 'Cédula de Identidad (CI)',
                          labelStyle: TextStyle(color: ZonixColors.mediumGray),
                          filled: true,
                          fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.receipt, color: ZonixColors.mediumGray),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[vVeE0-9]+')),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo requerido';
                          if (!RegExp(r'^[vVeE][0-9]{7,9}$').hasMatch(v.trim())) return 'Formato válido: V12345678 o E12345678';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información de contacto
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
                        'Información de Contacto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                        decoration: InputDecoration(
                          labelText: 'Dirección *',
                          labelStyle: TextStyle(color: ZonixColors.mediumGray),
                          filled: true,
                          fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.location_on, color: ZonixColors.mediumGray),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo requerido';
                          if (v.trim().length < 5) return 'Mínimo 5 caracteres';
                          if (v.trim().length > 200) return 'Máximo 200 caracteres';
                          return null;
                        },
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                        decoration: InputDecoration(
                          labelText: 'Teléfono *',
                          labelStyle: TextStyle(color: ZonixColors.mediumGray),
                          filled: true,
                          fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.phone, color: ZonixColors.mediumGray),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo requerido';
                          if (v.trim().length < 10) return 'Mínimo 10 dígitos';
                          if (v.trim().length > 15) return 'Máximo 15 dígitos';
                          if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Solo números';
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

              // Estado del comercio
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
                        'Estado del Comercio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.power_settings_new, color: ZonixColors.primaryBlue),
                          const SizedBox(width: 12),
                          Text(
                            'Comercio abierto',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _open,
                            onChanged: (v) => setState(() => _open = v),
                            activeColor: ZonixColors.successGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _schedule,
                        onChanged: (v) => _schedule = v,
                        style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                        decoration: InputDecoration(
                          labelText: 'Horario de atención',
                          labelStyle: TextStyle(color: ZonixColors.mediumGray),
                          hintText: 'Ej: Lunes a Viernes 8:00 AM - 6:00 PM',
                          hintStyle: TextStyle(color: ZonixColors.mediumGray),
                          filled: true,
                          fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.schedule, color: ZonixColors.mediumGray),
                        ),
                        maxLines: 3,
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
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZonixColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: _loading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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