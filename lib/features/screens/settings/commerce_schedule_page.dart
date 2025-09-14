import 'package:flutter/material.dart';
import 'package:zonix/features/services/commerce_data_service.dart';

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

class CommerceSchedulePage extends StatefulWidget {
  const CommerceSchedulePage({Key? key}) : super(key: key);

  @override
  State<CommerceSchedulePage> createState() => _CommerceSchedulePageState();
}

class _CommerceSchedulePageState extends State<CommerceSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _scheduleController = TextEditingController();
  
  bool _loading = false;
  bool _initialLoading = true;
  String? _error;
  String? _success;

  // Horarios por día
  Map<String, Map<String, dynamic>> _scheduleData = {
    'monday': {'enabled': true, 'open': '08:00', 'close': '18:00'},
    'tuesday': {'enabled': true, 'open': '08:00', 'close': '18:00'},
    'wednesday': {'enabled': true, 'open': '08:00', 'close': '18:00'},
    'thursday': {'enabled': true, 'open': '08:00', 'close': '18:00'},
    'friday': {'enabled': true, 'open': '08:00', 'close': '18:00'},
    'saturday': {'enabled': true, 'open': '09:00', 'close': '14:00'},
    'sunday': {'enabled': false, 'open': '09:00', 'close': '14:00'},
  };

  final Map<String, String> _dayNames = {
    'monday': 'Lunes',
    'tuesday': 'Martes',
    'wednesday': 'Miércoles',
    'thursday': 'Jueves',
    'friday': 'Viernes',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  @override
  void dispose() {
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _loadScheduleData() async {
    try {
      setState(() {
        _initialLoading = true;
        _error = null;
      });

      final data = await CommerceDataService.getCommerceData();
      final schedule = data['schedule'];
      
      if (schedule != null && schedule is String && schedule.isNotEmpty) {
        _parseScheduleString(schedule);
      }
      
      setState(() {
        _initialLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar horario: $e';
        _initialLoading = false;
      });
    }
  }

  void _parseScheduleString(String schedule) {
    // Parsear horario desde string (formato simple)
    // TODO: Implementar parsing más robusto
    _scheduleController.text = schedule;
  }

  String _generateScheduleString() {
    final buffer = StringBuffer();
    for (var entry in _scheduleData.entries) {
      final day = entry.key;
      final data = entry.value;
      final dayName = _dayNames[day]!;
      
      if (data['enabled']) {
        buffer.writeln('$dayName: ${data['open']} - ${data['close']}');
      } else {
        buffer.writeln('$dayName: Cerrado');
      }
    }
    return buffer.toString().trim();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { 
      _loading = true; 
      _error = null; 
      _success = null; 
    });

    try {
      final scheduleString = _generateScheduleString();
      
      final data = {
        'schedule': scheduleString,
      };

      await CommerceDataService.updateCommerceData(data);
      
      setState(() {
        _loading = false;
        _success = 'Horario actualizado correctamente.';
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
        _error = 'Error al actualizar horario: $e';
      });
    }
  }

  Widget _buildDaySchedule(String day, String dayName) {
    final data = _scheduleData[day]!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      color: isDark ? ZonixColors.darkGray : ZonixColors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: data['enabled'],
                  onChanged: (value) {
                    setState(() {
                      data['enabled'] = value ?? false;
                    });
                  },
                  activeColor: ZonixColors.primaryBlue,
                ),
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                  ),
                ),
                const Spacer(),
                if (data['enabled'])
                  Text(
                    '${data['open']} - ${data['close']}',
                    style: TextStyle(color: ZonixColors.successGreen, fontWeight: FontWeight.bold),
                  )
                else
                  Text(
                    'Cerrado',
                    style: TextStyle(color: ZonixColors.errorRed, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            if (data['enabled']) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: data['open'],
                      style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                      decoration: InputDecoration(
                        labelText: 'Apertura',
                        labelStyle: TextStyle(color: ZonixColors.mediumGray),
                        filled: true,
                        fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        data['open'] = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('a', style: TextStyle(fontSize: 16, color: ZonixColors.mediumGray)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: data['close'],
                      style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                      decoration: InputDecoration(
                        labelText: 'Cierre',
                        labelStyle: TextStyle(color: ZonixColors.mediumGray),
                        filled: true,
                        fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        data['close'] = value;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
                'Horario de atención',
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
              'Horario de atención',
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
              // Selector de horarios por día
              Card(
                elevation: 4,
                color: isDark ? ZonixColors.darkGray : ZonixColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, color: ZonixColors.primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            'Horario por Días',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._scheduleData.keys.map((day) => _buildDaySchedule(day, _dayNames[day]!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Horario personalizado
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
                        'Horario Personalizado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Si necesitas un horario más específico, puedes escribirlo aquí:',
                        style: TextStyle(color: ZonixColors.mediumGray),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _scheduleController,
                        style: TextStyle(color: isDark ? ZonixColors.white : ZonixColors.darkGray),
                        decoration: InputDecoration(
                          labelText: 'Horario personalizado',
                          labelStyle: TextStyle(color: ZonixColors.mediumGray),
                          hintText: 'Ejemplo:\nL-V 8:00-18:00\nS 9:00-14:00\nD cerrado',
                          hintStyle: TextStyle(color: ZonixColors.mediumGray),
                          filled: true,
                          fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
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
                            'Información',
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
                        '• El horario se muestra a los clientes para que sepan cuándo pueden hacer pedidos\n'
                        '• Los días marcados como "Cerrado" no aparecerán en el horario público\n'
                        '• Puedes usar el horario personalizado para casos especiales\n'
                        '• Los cambios se aplican inmediatamente',
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
                    _loading ? 'Guardando...' : 'Guardar horario',
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