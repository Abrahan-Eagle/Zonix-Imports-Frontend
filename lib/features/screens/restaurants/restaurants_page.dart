import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zonix/features/services/restaurant_service.dart';
import 'package:zonix/models/restaurant.dart';
import 'restaurant_details_page.dart';
import '../../services/test_auth_service.dart';
import 'package:zonix/features/utils/network_image_with_fallback.dart';

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

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({Key? key}) : super(key: key);

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  Future<List<Restaurant>>? _restaurantsFuture;
  final Logger _logger = Logger();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';
  bool _isRefreshing = false;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debouncer._timer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _logger.d('🔄 Llegamos al final de la lista');
      // Aquí podrías cargar más datos si implementas paginación
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      _logger.i('🔄 Iniciando carga de restaurantes...');
      setState(() => _isRefreshing = true);
      
      // Primero probar la autenticación
      _logger.i('🔍 Probando autenticación...');
      final authResult = await TestAuthService.testAuth();
      
      if (authResult.containsKey('error')) {
        _logger.e('❌ Error de autenticación: $authResult');
        setState(() => _isRefreshing = false);
        return;
      }
      
      _logger.i('✅ Autenticación exitosa, cargando restaurantes...');
      
      setState(() {
        _restaurantsFuture = RestaurantService().fetchRestaurants();
      });
      
      _restaurantsFuture?.then((restaurants) {
        _logger.d('✅ Datos recibidos de fetchRestaurants()');
        _logger.d('📌 Cantidad de restaurantes: ${restaurants.length}');
      }).catchError((error) {
        _logger.e('❌ Error al cargar restaurantes: $error');
      }).whenComplete(() => setState(() => _isRefreshing = false));
      
    } catch (e) {
      _logger.e('❌ Error en initState al cargar restaurantes: $e');
      setState(() => _isRefreshing = false);
    }
  }

  List<Restaurant> _filterRestaurants(List<Restaurant> restaurants) {
    if (_searchQuery.isEmpty) return restaurants;
    return restaurants.where((restaurant) => 
      restaurant.nombreLocal.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (restaurant.direccion?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.darkGray
          : ZonixColors.white,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.darkGray.withOpacity(0.3)
          : ZonixColors.lightGray,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? ZonixColors.darkGray
                  : ZonixColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            'Ocurrió un error',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(color: Colors.white70),
            ),
          ),
          FilledButton(
            onPressed: _loadRestaurants,
            style: FilledButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty 
              ? 'No hay restaurantes disponibles' 
              : 'No encontramos resultados',
            style: GoogleFonts.manrope(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
              ),
              child: const Text('Limpiar búsqueda'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.darkGray
          : ZonixColors.white,
      shadowColor: ZonixColors.primaryBlue.withOpacity(0.15),
      elevation: 6,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () async {
          await HapticFeedback.lightImpact();
          _logger.d('🚀 Navegando a detalles de  {restaurant.nombreLocal}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDetailsPage(
                commerceId: restaurant.id,
                nombreLocal: restaurant.nombreLocal,
                direccion: restaurant.direccion ?? '',
                telefono: restaurant.telefono ?? '',
                abierto: restaurant.abierto ?? false,
                horario: restaurant.horario,
                logoUrl: restaurant.logoUrl,
                rating: null,
                tiempoEntrega: null,
                banco: restaurant.pagoMovilBanco,
                cedula: restaurant.pagoMovilCedula,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: ZonixColors.primaryBlue.withOpacity(0.15),
        highlightColor: ZonixColors.primaryBlue.withOpacity(0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del restaurante
            AspectRatio(
              aspectRatio: 16/9,
              child: RestaurantImage(
                imageUrl: restaurant.logoUrl ?? '',
                restaurantName: restaurant.nombreLocal,
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
            ),
            // Información del restaurante
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    restaurant.nombreLocal,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.white
          : ZonixColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Dirección
                  if (restaurant.direccion != null)
                    Row(
                      children: [
                        Icon(Icons.location_on, color: ZonixColors.primaryBlue, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant.direccion!,
                            style: TextStyle(
                              color: ZonixColors.mediumGray,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  // Estado abierto/cerrado
                  Row(
                    children: [
                      Icon(
                        restaurant.abierto == true ? Icons.check_circle : Icons.cancel,
                        color: restaurant.abierto == true ? ZonixColors.successGreen : ZonixColors.errorRed,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.abierto == true ? 'Abierto' : 'Cerrado', // TODO: internacionalizar
                        style: TextStyle(
                          color: restaurant.abierto == true ? ZonixColors.successGreen : ZonixColors.errorRed,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              'Restaurantes',
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ZonixColors.white
                      : ZonixColors.darkGray,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar restaurante...',
                  hintStyle: TextStyle(color: ZonixColors.mediumGray),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? ZonixColors.darkGray
                      : ZonixColors.white,
                  prefixIcon: Icon(Icons.search, color: ZonixColors.mediumGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) {
                  _debouncer.run(() {
                    setState(() {
                      _searchQuery = value;
                    });
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Restaurant>>(
                future: _restaurantsFuture,
                builder: (context, snapshot) {
                  if (_isRefreshing) {
                    return _buildShimmerLoading();
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error!);
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  } else {
                    final filtered = _filterRestaurants(snapshot.data!);
                    if (filtered.isEmpty) return _buildEmptyState();
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: _buildRestaurantCard(filtered[index]),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}