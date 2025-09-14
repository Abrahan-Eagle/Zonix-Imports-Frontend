import 'package:flutter/material.dart';

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

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Activos', 'Inactivos', 'Suspendidos', 'Pendientes'];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? ZonixColors.darkGray : ZonixColors.lightGray,
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isTablet = screenWidth > 600;
            final fontSize = isTablet ? 24.0 : 20.0;
            
            return Text(
              'Gestión de Usuarios',
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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddUserDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: TextStyle(
                color: isDark ? ZonixColors.white : ZonixColors.darkGray,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
                hintStyle: TextStyle(color: ZonixColors.mediumGray),
                prefixIcon: Icon(Icons.search, color: ZonixColors.mediumGray),
                filled: true,
                fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: ZonixColors.mediumGray),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? ZonixColors.darkGray : ZonixColors.lightGray,
            child: Row(
              children: [
                Text(
                  'Filtrar: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    style: TextStyle(
                      color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    dropdownColor: isDark ? ZonixColors.darkGray : ZonixColors.white,
                    items: _filters.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 20,
              itemBuilder: (context, index) {
                return _buildUserCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(int index) {
    final userTypes = ['Comprador', 'Comercio', 'Delivery', 'Transporte', 'Afiliado', 'Administrador'];
    final statuses = ['Activo', 'Inactivo', 'Suspendido', 'Pendiente'];
    final emails = [
      'juan.perez@email.com',
      'maria.gonzalez@email.com',
      'carlos.rodriguez@email.com',
      'ana.martinez@email.com',
      'luis.fernandez@email.com',
    ];
    
    final userType = userTypes[index % userTypes.length];
    final status = statuses[index % statuses.length];
    final email = emails[index % emails.length];
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: isDark ? ZonixColors.darkGray : ZonixColors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _getStatusColor(status),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ZonixColors.primaryBlue.withOpacity(0.1),
                    child: Text(
                      'U${1000 + index}',
                      style: TextStyle(color: ZonixColors.primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getUserName(index),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? ZonixColors.white : ZonixColors.darkGray,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(color: ZonixColors.mediumGray, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.category, color: ZonixColors.mediumGray, size: 16),
                  const SizedBox(width: 8),
                  Text('Tipo: $userType', style: TextStyle(color: ZonixColors.mediumGray)),
                  const Spacer(),
                  Icon(Icons.calendar_today, color: ZonixColors.mediumGray, size: 16),
                  const SizedBox(width: 8),
                  Text('Registro: ${_getRegistrationDate(index)}', style: TextStyle(color: ZonixColors.mediumGray)),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.location_on, color: ZonixColors.mediumGray, size: 16),
                  const SizedBox(width: 8),
                  Text('Ubicación: ${_getUserLocation(index)}', style: TextStyle(color: ZonixColors.mediumGray)),
                  const Spacer(),
                  Icon(Icons.phone, color: ZonixColors.mediumGray, size: 16),
                  const SizedBox(width: 8),
                  Text('${_getUserPhone(index)}', style: TextStyle(color: ZonixColors.mediumGray)),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showUserDetails(index);
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Ver Detalles'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ZonixColors.primaryBlue,
                        side: BorderSide(color: ZonixColors.primaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showUserActions(index);
                      },
                      icon: const Icon(Icons.more_vert, size: 16),
                      label: const Text('Acciones'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ZonixColors.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Activo':
        return ZonixColors.successGreen;
      case 'Inactivo':
        return ZonixColors.mediumGray;
      case 'Suspendido':
        return ZonixColors.errorRed;
      case 'Pendiente':
        return ZonixColors.warningOrange;
      default:
        return ZonixColors.mediumGray;
    }
  }

  String _getUserName(int index) {
    final names = [
      'Juan Pérez',
      'María González',
      'Carlos Rodríguez',
      'Ana Martínez',
      'Luis Fernández',
      'Sofia López',
      'Pedro García',
      'Carmen Ruiz',
    ];
    return names[index % names.length];
  }

  String _getRegistrationDate(int index) {
    final dates = [
      '15/12/2024',
      '14/12/2024',
      '13/12/2024',
      '12/12/2024',
      '11/12/2024',
      '10/12/2024',
      '09/12/2024',
      '08/12/2024',
    ];
    return dates[index % dates.length];
  }

  String _getUserLocation(int index) {
    final locations = [
      'Lima, Perú',
      'Arequipa, Perú',
      'Trujillo, Perú',
      'Piura, Perú',
      'Cusco, Perú',
    ];
    return locations[index % locations.length];
  }

  String _getUserPhone(int index) {
    final phones = [
      '+51 123 456 789',
      '+51 987 654 321',
      '+51 456 789 123',
      '+51 789 123 456',
      '+51 321 654 987',
    ];
    return phones[index % phones.length];
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Usuarios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('Todos los usuarios', true),
            _buildFilterOption('Solo activos', false),
            _buildFilterOption('Solo inactivos', false),
            _buildFilterOption('Solo suspendidos', false),
            _buildFilterOption('Por tipo de usuario', false),
            _buildFilterOption('Por fecha de registro', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtro aplicado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, bool isSelected) {
    return CheckboxListTile(
      title: Text(title),
      value: isSelected,
      onChanged: (value) {},
      activeColor: Colors.red[700],
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipo de usuario',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'buyer', child: Text('Comprador')),
                DropdownMenuItem(value: 'commerce', child: Text('Comercio')),
                DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                DropdownMenuItem(value: 'transport', child: Text('Transporte')),
                DropdownMenuItem(value: 'affiliate', child: Text('Afiliado')),
                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario agregado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Usuario #${1000 + index}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nombre', _getUserName(index)),
              _buildDetailRow('Email', '${_getUserName(index).toLowerCase().replaceAll(' ', '.')}@email.com'),
              _buildDetailRow('Teléfono', _getUserPhone(index)),
              _buildDetailRow('Ubicación', _getUserLocation(index)),
              _buildDetailRow('Tipo', 'Comprador'),
              _buildDetailRow('Estado', 'Activo'),
              _buildDetailRow('Fecha de Registro', _getRegistrationDate(index)),
              _buildDetailRow('Último Acceso', 'Hace 2 horas'),
              _buildDetailRow('Órdenes Totales', '15'),
              _buildDetailRow('Valoración', '4.8/5'),
              const SizedBox(height: 16),
              const Text('Actividad Reciente:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildActivityItem('Hace 2 horas', 'Inició sesión'),
              _buildActivityItem('Hace 1 día', 'Realizó una orden'),
              _buildActivityItem('Hace 3 días', 'Actualizó perfil'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String time, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(width: 8),
          Text(action, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showUserActions(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acciones para ${_getUserName(index)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Usuario'),
              onTap: () {
                Navigator.pop(context);
                _showEditUserDialog(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Suspender Usuario'),
              onTap: () {
                Navigator.pop(context);
                _showSuspendDialog(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar Usuario'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Cambiar Contraseña'),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Ver Historial'),
              onTap: () {
                Navigator.pop(context);
                _showUserHistory(index);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuario'),
        content: const Text('Funcionalidad de edición de usuario'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspender Usuario'),
        content: Text('¿Estás seguro de que deseas suspender a ${_getUserName(index)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario suspendido')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Suspender', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de que deseas eliminar a ${_getUserName(index)}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: const Text('Funcionalidad para cambiar contraseña'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showUserHistory(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historial del Usuario'),
        content: const Text('Mostrando historial completo del usuario'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
} 