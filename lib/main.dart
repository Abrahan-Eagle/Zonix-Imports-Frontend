import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zonix/core/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:zonix/shared/providers/user_provider.dart';
import 'package:flutter/services.dart';

// Imports del módulo Products
import 'package:zonix/features/products/presentation/providers/product_provider.dart';
import 'package:zonix/features/products/presentation/screens/enhanced_products_page.dart';

// Imports del módulo Cart
import 'package:zonix/features/cart/presentation/providers/cart_provider.dart';
import 'package:zonix/features/cart/presentation/screens/cart_page.dart';

// import 'dart:io';
// import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'package:zonix/features/screens/profile/profile_page.dart';
import 'package:zonix/shared/widgets/settings_page_2.dart';
import 'package:zonix/features/auth/presentation/screens/sign_in_screen.dart';

import 'package:zonix/features/profile/data/datasources/profile_service.dart';

/*
 * ZONIX IMPORTS - Aplicación E-commerce MVP
 * 
 * Niveles de usuario (MVP):
 * 0 - Comprador: Productos, Carrito, Checkout, Pedidos
 * 1 - Vendedor: Productos, Inventario, Pedidos, Perfil
 * 
 * Funcionalidades avanzadas eliminadas para enfocarse en el MVP core
 */

const FlutterSecureStorage _storage = FlutterSecureStorage();
final ApiService apiService = ApiService();

final String baseUrl = const bool.fromEnvironment('dart.vm.product')
    ? dotenv.env['API_URL_PROD']!
    : dotenv.env['API_URL_LOCAL']!;

// Configuración del logger
final logger = Logger();

//  class MyHttpOverrides extends HttpOverrides{
//   @override
//   HttpClient createHttpClient(SecurityContext? context){
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
//   }
// }

// void main() {
Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initialization();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar configuración desde .env
  await dotenv.load(fileName: ".env");

  // Bypass de login para tests de integración
  final bool isIntegrationTest =
      const String.fromEnvironment('INTEGRATION_TEST', defaultValue: 'false') ==
          'true';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(isIntegrationTest: isIntegrationTest),
    ),
  );
}

void initialization() async {
  logger.i('Initializing...');
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final bool isIntegrationTest;
  const MyApp({super.key, this.isIntegrationTest = false});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Usar WidgetsBinding para ejecutar después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isIntegrationTest) {
        // Forzar autenticación como comercio
        userProvider.setAuthenticatedForTest(role: 'commerce');
      } else {
        userProvider.checkAuthentication();
      }
    });

    return MaterialApp(
      title: 'ZONIX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E40AF), // Azul profesional
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E40AF),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF1E40AF).withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E40AF),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF1E40AF).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1E40AF),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF1E40AF),
          unselectedItemColor: Color(0xFF64748B),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E40AF), // Azul profesional
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 2,
          shadowColor: const Color(0xFF1E40AF).withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E40AF),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF1E40AF).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1E40AF),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E293B),
          selectedItemColor: Color(0xFF60A5FA),
          unselectedItemColor: Color(0xFF64748B),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      themeMode: ThemeMode.system,
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          logger.i('isAuthenticated: ${userProvider.isAuthenticated}');
          if (userProvider.isAuthenticated) {
            return const MainRouter();
          } else {
            return const SignInScreen();
          }
        },
      ),
      routes: const {},
    );
  }
}

class MainRouter extends StatefulWidget {
  const MainRouter({super.key});

  @override
  MainRouterState createState() => MainRouterState();
}

class MainRouterState extends State<MainRouter> {
  int _selectedLevel = 0;
  int _bottomNavIndex = 0;
  dynamic _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadLastPosition();
  }

  Future<void> _loadProfile() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Obtén los detalles del usuario y verifica su contenido
      final userDetails = await userProvider.getUserDetails();

      // Extrae y valida el ID del usuario
      final id = userDetails?['userId'];
      if (id == null || id is! int) {
        throw Exception('El ID del usuario es inválido: $id');
      }
      // Obtén el perfil usando el ID del usuario
      _profile = await ProfileService().getProfileById(id);

      setState(() {});
    } catch (e) {
      logger.e('Error obteniendo el ID del usuario: $e');
    }
  }

  Future<void> _loadLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLevel = prefs.getInt('selectedLevel') ?? 0;
      _bottomNavIndex = prefs.getInt('bottomNavIndex') ?? 0;
      logger.i(
        'Loaded last position - selectedLevel: $_selectedLevel, bottomNavIndex: $_bottomNavIndex',
      );
    });
  }

  Future<void> _saveLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedLevel', _selectedLevel);
    await prefs.setInt('bottomNavIndex', _bottomNavIndex);
    logger.i(
      'Saved last position - selectedLevel: $_selectedLevel, bottomNavIndex: $_bottomNavIndex',
    );
  }

  // Función para obtener los items del BottomNavigationBar
  List<BottomNavigationBarItem> _getBottomNavItems(int level, String role) {
    List<BottomNavigationBarItem> items = [];

    switch (level) {
      case 0: // Comprador (MVP visual)
        items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Catálogo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Checkout',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
        ];
        break;
      case 1: // Vendedor (MVP visual)
        items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Productos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventario',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Pedidos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ];
        break;
      default:
        items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ];
    }

    // Agregar el item de configuración siempre
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Configuración',
      ),
    );

    // // Agregar elementos específicos según el rol si el nivel es 0
    // if (level == 0) {
    //   if (role == 'sales_admin') {
    //     items.insert( 2, const BottomNavigationBarItem( icon: Icon(Icons.qr_code), label: 'Verificar', ),);

    //     items.insert( 3, const BottomNavigationBarItem( icon: Icon(Icons.check_circle), label: 'Aprobar', ),);
    //   }

    //   if (role == 'dispatcher') {
    //     items.insert(
    //       2,
    //       const BottomNavigationBarItem(
    //         icon: Icon(Icons.workspace_premium),
    //         label: 'Despachar',
    //       ),
    //     );
    //   }
    // }

    // Devolver los items y el contador
    return items;
  }

  // Función para manejar el tap en el BottomNavigationBar
  void _onBottomNavTapped(int index, int itemCount) {
    logger.i('Bottom navigation tapped: $index, Total items: $itemCount');

    // Verifica si el índice seleccionado es el último item
    if (index == itemCount - 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage2()),
      );
    } else {
      setState(() {
        _bottomNavIndex = index; // Actualiza el índice seleccionado
        logger.i('Bottom nav index changed to: $_bottomNavIndex');
        _saveLastPosition();
      });
    }
  }

  // Dentro de tu widget donde tienes el BottomNavigationBar

  void _onLevelSelected(int level) {
    setState(() {
      _selectedLevel = level;
      _bottomNavIndex = 0;
      _saveLastPosition();
    });
  }

  Widget _createLevelButton(int level, IconData icon, String tooltip) {
    final isSelected = _selectedLevel == level;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: FloatingActionButton.small(
        heroTag: 'level$level',
        backgroundColor: isSelected
            ? const Color(0xFF1E40AF)
            : Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF334155)
                : const Color(0xFFF1F5F9),
        elevation: isSelected ? 6 : 2,
        child: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1E40AF),
          size: 20,
        ),
        onPressed: () => _onLevelSelected(level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : const Color(0xFF1E40AF),
        title: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isTablet = screenWidth > 600;
            final fontSize = isTablet ? 28.0 : 24.0;

            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'ZONI',
                    style: TextStyle(
                      fontFamily: 'system-ui',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  TextSpan(
                    text: 'X',
                    style: TextStyle(
                      fontFamily: 'system-ui',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF60A5FA),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        centerTitle: false,
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return GestureDetector(
                onTap: () {
                  showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(200, 80, 0, 0),
                    items: [
                      PopupMenuItem(
                        child: const Text('Mi Perfil (próximamente)'),
                        onTap: () {},
                      ),
                      PopupMenuItem(
                        child: const Text('Configuración'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage2(),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        child: const Text('Cerrar sesión'),
                        onTap: () async {
                          await userProvider.logout();
                          // await _storage.deleteAll();
                          if (!mounted) return;

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SignInScreen()), // Redirige al login
                            (Route<dynamic> route) =>
                                false, // Elimina todas las rutas previas
                          );
                        },
                      ),
                    ],
                  );
                },
                child: FutureBuilder<String?>(
                  future: _storage.read(key: 'userPhotoUrl'),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<String?> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(radius: 20);
                    } else if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.person),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        // child: CircleAvatar(
                        //   radius: 20,
                        //   child: ClipOval(
                        //     child: Image.network(
                        //       snapshot.data!,
                        //       fit: BoxFit.cover,
                        //     ),
                        //   ),
                        // ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: _getProfileImage(
                            _profile
                                ?.photo, // Foto del perfil del usuario (desde el backend)
                            snapshot
                                .data!, // Foto de Google (si está disponible)
                          ),
                          child: (_profile?.photo == null &&
                                  snapshot.data == null)
                              ? const Icon(Icons.person,
                                  color: Colors
                                      .white) // Ícono predeterminado si no hay foto
                              : null,
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: userProvider.getUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                logger.e('Error fetching user details: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              } // Dentro del FutureBuilder
              else {
                final role = userProvider.userRole;
                logger.i('Role fetched: $role');

                // if (_selectedLevel == 0) {
                //   if (_bottomNavIndex == 2 && role == 'sales_admin') return const TicketScannerScreen();
                //   if (_bottomNavIndex == 3 && role == 'sales_admin') return const CheckScannerScreen();
                //   if (_bottomNavIndex == 2 && role == 'dispatcher') return const DispatcherScreen();
                // }

                // Nivel 0: Comprador
                if (_selectedLevel == 0) {
                  switch (_bottomNavIndex) {
                    case 0:
                      return const EnhancedProductsPage();
                    case 1:
                      return const CartPage();
                    case 2:
                      return const Center(child: Text('Checkout'));
                    case 3:
                      return const Center(child: Text('Pedidos'));
                    default:
                      return const EnhancedProductsPage();
                  }
                }

                // Nivel 1: Tiendas/Comercio
                if (_selectedLevel == 1) {
                  switch (_bottomNavIndex) {
                    case 0:
                      return const Center(child: Text('Productos'));
                    case 1:
                      return const Center(child: Text('Inventario'));
                    case 2:
                      return const Center(child: Text('Pedidos'));
                    case 3:
                      return const Center(child: Text('Perfil Vendedor'));
                    default:
                      return const Center(child: Text('Productos'));
                  }
                }

                // Niveles avanzados eliminados - Solo MVP con niveles 0 y 1

                // Si no se cumplen ninguna de las condiciones anteriores, puedes manejar un caso por defecto.
                return const Center(
                  child: Text('Rol no reconocido o página no encontrada'),
                );
              }
            },
          );
        },
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70,
        type: ExpandableFabType.up,
        children: [
          _createLevelButton(0, Icons.shopping_bag, 'Comprador'),
          _createLevelButton(1, Icons.storefront, 'Vendedor'),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : const Color(0xFF1E40AF).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items:
              _getBottomNavItems(_selectedLevel, userProvider.userRole ?? ''),
          currentIndex: _bottomNavIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF1E40AF),
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            // Obtener el itemCount llamando a _getBottomNavItems antes de la navegación
            List<BottomNavigationBarItem> items = _getBottomNavItems(
              _selectedLevel,
              userProvider.userRole ?? '',
            );
            int itemCount = items.length;

            // Llamar a la función _onBottomNavTapped con el index y el itemCount
            _onBottomNavTapped(index, itemCount);
          },
        ),
      ),
    );
  }
}

ImageProvider<Object> _getProfileImage(
    String? profilePhoto, String? googlePhotoUrl) {
  bool _looksLikeHttpUrl(String? value) {
    if (value == null) return false;
    final v = value.trim().toLowerCase();
    if (v.isEmpty) return false;
    if (v == 'url de foto no disponible') return false;
    return v.startsWith('http://') || v.startsWith('https://');
  }

  if (profilePhoto != null && profilePhoto.isNotEmpty) {
    // Detectar URLs de placeholder y evitarlas
    if (profilePhoto.contains('via.placeholder.com') ||
        profilePhoto.contains('placeholder.com') ||
        profilePhoto.contains('placehold.it')) {
      logger.w(
          'Detectada URL de placeholder en perfil, usando imagen local: $profilePhoto');
      return const AssetImage('assets/default_avatar.png');
    }

    if (_looksLikeHttpUrl(profilePhoto)) {
      logger.i('Usando foto del perfil: $profilePhoto');
      return NetworkImage(profilePhoto); // Imagen del perfil del usuario
    } else {
      logger.w(
          'Foto de perfil inválida, usando imagen predeterminada: $profilePhoto');
      return const AssetImage('assets/default_avatar.png');
    }
  }
  if (_looksLikeHttpUrl(googlePhotoUrl)) {
    logger.i('Usando foto de Google: $googlePhotoUrl');
    return NetworkImage(googlePhotoUrl!); // Imagen de Google
  }
  logger.w('Usando imagen predeterminada');
  return const AssetImage('assets/default_avatar.png'); // Imagen predeterminada
}
