# Zonix Imports Frontend - Flutter App

## 📋 Descripción

Aplicación móvil de Zonix Imports desarrollada en Flutter. Proporciona una interfaz completa para clientes y vendedores con funcionalidades de e-commerce multi-modal.

## 🏗️ Arquitectura

**Clean Architecture + Feature-First + Provider Pattern**

```
lib/
├── core/                       # ✅ Núcleo de la aplicación
│   ├── config/                # ✅ Configuración global
│   │   ├── app_config.dart    # ✅ URLs, constantes
│   │   ├── theme.dart         # ✅ Tema y colores
│   │   └── routes.dart        # ✅ Rutas de navegación
│   ├── constants/             # ✅ Constantes globales
│   ├── utils/                 # ✅ Utilidades globales
│   └── services/              # ✅ Servicios base
│
├── shared/                     # ✅ Componentes compartidos
│   ├── widgets/               # ✅ Widgets comunes
│   ├── models/                # ✅ Modelos base
│   └── providers/             # ✅ Providers compartidos
│
├── features/                   # ✅ Módulos por funcionalidad
│   ├── auth/                  # ✅ Módulo autenticación
│   │   ├── data/              # ✅ Capa de datos
│   │   ├── domain/            # ✅ Lógica de negocio
│   │   └── presentation/      # ✅ Capa de presentación
│   ├── products/              # ✅ Módulo productos
│   ├── cart/                  # ✅ Módulo carrito
│   ├── orders/                # ✅ Módulo órdenes
│   ├── commerce/              # ✅ Módulo comercio (vendedor)
│   ├── payments/              # ✅ Módulo pagos
│   └── profile/               # ✅ Módulo perfil
│
├── app/                       # ✅ Configuración de la app
│   ├── app.dart              # ✅ Widget principal
│   ├── app_module.dart       # ✅ Inyección de dependencias
│   └── app_routes.dart       # ✅ Configuración de rutas
│
└── main.dart                 # ✅ Punto de entrada
```

## 🚀 Instalación

### Prerrequisitos
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Dispositivo físico o emulador

### Configuración

1. **Instalar dependencias**
```bash
flutter pub get
```

2. **Configurar URLs**
```dart
// lib/config/app_config.dart
class AppConfig {
  static const String baseUrl = 'http://192.168.0.101:8000/api';
}
```

3. **Ejecutar aplicación**
```bash
flutter run
```

## 📱 Funcionalidades Implementadas

### 🔐 Autenticación
- Login/Registro de usuarios
- Gestión de tokens JWT
- Persistencia de sesión
- Logout seguro

### 🏪 Catálogo y Productos
- Lista de productos
- Detalles de producto
- Catálogo multi-modal (detal, mayor, pre-order, referidos, dropshipping)
- Búsqueda y filtros
- Imágenes con fallback

### 🛒 Carrito de Compras
- Agregar productos
- Actualizar cantidades
- Remover productos
- Calcular totales
- Persistencia local

### 📦 Órdenes
- Crear nueva orden
- Ver historial de pedidos
- Cancelar órdenes
- Estados de pedido

### 📍 Direcciones
- Gestión de direcciones de entrega
- Validación de ubicaciones


## 🏗️ Estructura Detallada

### 🎯 Patrones de Arquitectura

**Clean Architecture + Feature-First + Provider Pattern**

Cada feature sigue la estructura de Clean Architecture:

```
features/[feature_name]/
├── data/                    # ✅ Capa de Datos
│   ├── models/             # ✅ Modelos de datos
│   ├── repositories/       # ✅ Implementación de repositorios
│   └── datasources/        # ✅ Fuentes de datos (API, Local)
├── domain/                  # ✅ Capa de Dominio
│   ├── entities/           # ✅ Entidades de negocio
│   ├── repositories/       # ✅ Interfaces de repositorios
│   └── usecases/           # ✅ Casos de uso
└── presentation/            # ✅ Capa de Presentación
    ├── providers/          # ✅ Providers (Estado)
    ├── widgets/            # ✅ Widgets específicos
    └── screens/            # ✅ Pantallas
```

### 🔄 Patrones de Desarrollo

**Repository Pattern:**
```dart
// domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProductById(int id);
  Future<void> createProduct(Product product);
}

// data/repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService _apiService;
  
  ProductRepositoryImpl(this._apiService);
  
  @override
  Future<List<Product>> getProducts() async {
    return await _apiService.fetchProducts();
  }
}
```

**UseCase Pattern:**
```dart
// domain/usecases/get_products_usecase.dart
class GetProductsUseCase {
  final ProductRepository _repository;
  
  GetProductsUseCase(this._repository);
  
  Future<List<Product>> execute() async {
    return await _repository.getProducts();
  }
}
```

**Provider Pattern:**
```dart
// presentation/providers/product_provider.dart
class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase _getProductsUseCase;
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _products = await _getProductsUseCase.execute();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 📱 Widget Composition

**Widgets Reutilizables en `shared/widgets/`:**
```dart
// shared/widgets/buttons/primary_button.dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  
  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading 
        ? const CircularProgressIndicator()
        : Text(text),
    );
  }
}
```

### 🎨 UI/UX Guidelines

- **Material Design 3** como base
- **Responsive Design** para móvil y tablet
- **Loading States** consistentes en toda la app
- **Error Handling** con snackbars informativos
- **Navegación fluida** con transiciones suaves
- **Tema personalizado** con colores de marca Zonix

## 🔧 Servicios Principales

### AuthService
```dart
class AuthService {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<void> logout();
  Future<Map<String, dynamic>> getUserDetails();
}
```

### ProductService
```dart
class ProductService {
  Future<List<Product>> fetchProducts();
  Future<Product> fetchProductDetails(int id);
  Future<List<Product>> fetchProductsBySeller(int sellerId);
}
```

### OrderService
```dart
class OrderService {
  Future<List<Order>> fetchOrders();
  Future<Order> createOrder(Map<String, dynamic> orderData);
  Future<Order> fetchOrderDetails(int id);
  Future<void> cancelOrder(int id);
}
```


## 🎨 UI/UX Components

### Widgets Reutilizables
```dart
// ImageWithFallback
class ImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  
  // Widget con fallback atractivo para imágenes rotas
}

// LoadingWidget
class LoadingWidget extends StatelessWidget {
  final String message;
  
  // Widget de carga consistente
}

// ErrorWidget
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  
  // Widget de error con opción de reintentar
}
```

### Temas y Estilos
```dart
// lib/config/theme.dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.orange,
      fontFamily: 'Roboto',
      // Configuración completa del tema
    );
  }
}
```

## 📊 Estado de la Aplicación

### Gestión de Estado
- **Provider**: Para estado global
- **SharedPreferences**: Para persistencia local

### Ejemplo de Provider
```dart
class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  double get total => _items.fold(0, (sum, item) => sum + item.total);
  
  void addItem(Product product, int quantity) {
    // Lógica para agregar al carrito
    notifyListeners();
  }
}
```

## 🔐 Seguridad

### Almacenamiento Seguro
```dart
// lib/helpers/auth_helper.dart
class AuthHelper {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
```

### Validación de Datos
```dart
// lib/features/utils/validation_utils.dart
class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
```

## 🧪 Testing

### Tests Unitarios
```dart
// test/services/auth_service_test.dart
void main() {
  group('AuthService Tests', () {
    test('should login successfully with valid credentials', () async {
      // Test de login
    });
    
    test('should fail login with invalid credentials', () async {
      // Test de login fallido
    });
  });
}
```

### Tests de Widgets
```dart
// test/widgets/login_screen_test.dart
void main() {
  testWidgets('Login screen shows all required fields', (WidgetTester tester) async {
    await tester.pumpWidget(LoginScreen());
    
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
```

### Ejecutar Tests
```bash
# Todos los tests
flutter test

# Tests específicos
flutter test test/services/auth_service_test.dart

# Tests con coverage
flutter test --coverage
```

## 📱 Navegación

### Rutas Principales
```dart
// lib/main.dart
MaterialApp(
  routes: {
    '/': (context) => SplashScreen(),
    '/login': (context) => LoginScreen(),
    '/home': (context) => HomeScreen(),
    '/products': (context) => ProductsScreen(),
    '/cart': (context) => CartScreen(),
    '/orders': (context) => OrdersScreen(),
    '/profile': (context) => ProfileScreen(),
  },
)
```

### Navegación con Parámetros
```dart
// Navegar a detalles de producto
Navigator.pushNamed(
  context, 
  '/product-details',
  arguments: {'productId': product.id}
);

// Recibir parámetros
final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
final productId = args['productId'];
```

## 🔄 Integración con Backend

### Configuración de HTTP Client
```dart
// lib/features/services/base_service.dart
class BaseService {
  static final http = HttpClient();
  
  static Future<Map<String, String>> getHeaders() async {
    final token = await AuthHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

### Manejo de Errores
```dart
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, this.statusCode);
}

// En servicios
try {
  final response = await http.get(uri, headers: headers);
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw ApiException('Error en la API', response.statusCode);
  }
} catch (e) {
  throw ApiException('Error de conexión', 0);
}
```

## 📊 Performance

### Optimizaciones
- **Lazy Loading**: Cargar imágenes bajo demanda
- **Caching**: Cache de datos y imágenes
- **Pagination**: Paginación de listas grandes
- **Debouncing**: Evitar requests excesivos

### Métricas
- Tiempo de inicio < 3 segundos
- Transiciones fluidas 60fps
- Uso de memoria < 200MB
- Tiempo de respuesta API < 2 segundos

## 🐛 Troubleshooting

### Problemas Comunes

1. **Error de conexión API**
   - Verificar URLs en app_config.dart
   - Verificar que el backend esté corriendo
   - Revisar configuración de red

2. **Error de red**
   - Verificar configuración de URLs
   - Revisar conectividad
   - Verificar autenticación

3. **Error de imágenes**
   - Verificar URLs de imágenes
   - Revisar permisos de red
   - Usar ImageWithFallback widget

### Debug Mode
```bash
# Ejecutar en modo debug
flutter run --debug

# Ver logs detallados
flutter logs
```

## 📈 Roadmap

### Próximas Funcionalidades
- [ ] Pagos con tarjeta
- [ ] Modo offline
- [ ] Tests de integración

### Mejoras Técnicas
- [ ] Migración a Riverpod
- [ ] Implementar BLoC pattern
- [ ] Optimización de imágenes
- [ ] Cache inteligente
- [ ] CI/CD pipeline

---

**Versión**: 1.0.0  
**Flutter**: 3.0+  
**Dart**: 3.0+  
**Última actualización**: Julio 2024  
**Estado**: Nivel 0 Completado ✅ 