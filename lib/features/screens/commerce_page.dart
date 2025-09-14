import 'package:flutter/material.dart';
import 'commerce/commerce_dashboard_page.dart';
import 'commerce/commerce_orders_page.dart';
import 'commerce/commerce_product_form_page.dart';
import 'commerce/commerce_profile_page.dart';

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
  
  // Colores adicionales para efectos modernos
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color neumorphicLight = Color(0xFFFFFFFF);
  static const Color neumorphicDark = Color(0xFFE0E0E0);
}

class CommercePage extends StatefulWidget {
  const CommercePage({Key? key}) : super(key: key);

  @override
  State<CommercePage> createState() => _CommercePageState();
}

class _CommercePageState extends State<CommercePage> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _error;

  final List<Widget> _pages = [
    const CommerceDashboardPage(),
    const CommerceOrdersPage(),
    const CommerceProductFormPage(),
    const CommerceProfilePage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Órdenes',
    'Productos',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.darkGray
          : ZonixColors.lightGray,
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isTablet = screenWidth > 600;
            final fontSize = isTablet ? 24.0 : 20.0;
            
            return Text(
              _titles[_selectedIndex],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
                letterSpacing: 0.5,
              ),
            );
          },
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ZonixColors.darkGray
            : ZonixColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/commerce/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/commerce/settings');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: ZonixColors.primaryBlue,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando...',
                    style: TextStyle(
                      color: ZonixColors.mediumGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? _buildErrorWidget()
              : _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ZonixColors.darkGray
              : ZonixColors.white,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : ZonixColors.primaryBlue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: ZonixColors.primaryBlue,
          unselectedItemColor: ZonixColors.mediumGray,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Órdenes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 1: // Órdenes
        return FloatingActionButton(
          onPressed: () {
            // Refresh orders
            setState(() {
              _isLoading = true;
            });
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                _isLoading = false;
              });
            });
          },
          backgroundColor: ZonixColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.refresh),
        );
      case 2: // Productos
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/commerce/products/create');
          },
          backgroundColor: ZonixColors.successGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: ZonixColors.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar datos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ZonixColors.white
                  : ZonixColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(
              color: ZonixColors.mediumGray,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _error = null;
                _isLoading = false;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ZonixColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de estadísticas rápidas para el dashboard
class QuickStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const QuickStatsWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.darkGray
          : ZonixColors.white,
      elevation: 6,
      shadowColor: ZonixColors.primaryBlue.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas Rápidas',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ZonixColors.white
                    : ZonixColors.darkGray,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Órdenes Hoy',
                    '${stats['orders_today'] ?? 0}',
                    Icons.receipt,
                    ZonixColors.primaryBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Ingresos Hoy',
                    '\u20a1${(stats['revenue_today'] ?? 0.0).toStringAsFixed(2)}',
                    Icons.attach_money,
                    ZonixColors.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Productos Activos',
                    '${stats['active_products'] ?? 0}',
                    Icons.inventory,
                    ZonixColors.warningOrange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Calificación',
                    '${(stats['average_rating'] ?? 0.0).toStringAsFixed(1)} ⭐',
                    Icons.star,
                    ZonixColors.warningOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ZonixColors.mediumGray,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Widget de acciones rápidas
class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.darkGray
          : ZonixColors.white,
      elevation: 6,
      shadowColor: ZonixColors.primaryBlue.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ZonixColors.white
                    : ZonixColors.darkGray,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Nuevo Producto',
                    Icons.add_circle,
                    ZonixColors.successGreen,
                    () => Navigator.of(context).pushNamed('/commerce/products/create'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Ver Órdenes',
                    Icons.receipt,
                    ZonixColors.primaryBlue,
                    () => Navigator.of(context).pushNamed('/commerce/orders'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Promociones',
                    Icons.local_offer,
                    ZonixColors.warningOrange,
                    () => Navigator.of(context).pushNamed('/commerce/promotions'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Reportes',
                    Icons.analytics,
                    ZonixColors.accentBlue,
                    () => Navigator.of(context).pushNamed('/commerce/reports'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
