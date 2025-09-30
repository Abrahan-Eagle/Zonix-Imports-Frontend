import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Helper para obtener variables de entorno de forma simple
class EnvHelper {
  /// Obtiene la URL base de la API según el entorno
  static String get apiUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) {
      return dotenv.env['API_URL_PROD'] ?? 'https://zonix.uniblockweb.com';
    }
    return dotenv.env['API_URL_LOCAL'] ?? 'http://192.168.0.101:8000';
  }

  /// Obtiene la URL del WebSocket según el entorno
  static String get wsUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) {
      return dotenv.env['WS_URL_PROD'] ?? 'wss://zonix.uniblockweb.com';
    }
    return dotenv.env['WS_URL_LOCAL'] ?? 'ws://192.168.0.101:6001';
  }

  /// Obtiene el timeout de request
  static int get requestTimeout {
    return int.tryParse(dotenv.env['REQUEST_TIMEOUT'] ?? '30000') ?? 30000;
  }

  /// Obtiene el timeout de conexión
  static int get connectionTimeout {
    return int.tryParse(dotenv.env['CONNECTION_TIMEOUT'] ?? '30000') ?? 30000;
  }

  /// Obtiene el timeout de recepción
  static int get receiveTimeout {
    return int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '30000') ?? 30000;
  }

  /// Obtiene el App ID de Echo
  static String get echoAppId {
    return dotenv.env['ECHO_APP_ID'] ?? 'zonix-eats-app';
  }

  /// Obtiene la clave de Echo
  static String get echoKey {
    return dotenv.env['ECHO_KEY'] ?? 'zonix-eats-key';
  }

  /// Obtiene si los WebSockets están habilitados
  static bool get enableWebsockets {
    return (dotenv.env['ENABLE_WEBSOCKETS'] ?? 'true').toLowerCase() == 'true';
  }

  /// Obtiene la API key de Google Maps
  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'your_google_maps_api_key_here';
  }

  /// Obtiene el Project ID de Firebase
  static String get firebaseProjectId {
    return dotenv.env['FIREBASE_PROJECT_ID'] ?? 'your_firebase_project_id';
  }

  /// Obtiene el Sender ID de Firebase
  static String get firebaseMessagingSenderId {
    return dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? 'your_sender_id';
  }

  /// Obtiene el App ID de Firebase
  static String get firebaseAppId {
    return dotenv.env['FIREBASE_APP_ID'] ?? 'your_app_id';
  }

  /// Obtiene el nombre de la aplicación
  static String get appName {
    return dotenv.env['APP_NAME'] ?? 'ZONIX-IMPORTS';
  }

  /// Obtiene la versión de la aplicación
  static String get appVersion {
    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }

  /// Obtiene el número de build
  static String get appBuildNumber {
    return dotenv.env['APP_BUILD_NUMBER'] ?? '1';
  }

  /// Obtiene el tamaño de página por defecto
  static int get defaultPageSize {
    return int.tryParse(dotenv.env['DEFAULT_PAGE_SIZE'] ?? '20') ?? 20;
  }

  /// Obtiene el tamaño máximo de página
  static int get maxPageSize {
    return int.tryParse(dotenv.env['MAX_PAGE_SIZE'] ?? '100') ?? 100;
  }

  /// Obtiene el número máximo de reintentos
  static int get maxRetryAttempts {
    return int.tryParse(dotenv.env['MAX_RETRY_ATTEMPTS'] ?? '3') ?? 3;
  }

  /// Obtiene el delay entre reintentos
  static int get retryDelayMs {
    return int.tryParse(dotenv.env['RETRY_DELAY_MS'] ?? '1000') ?? 1000;
  }

  /// Obtiene si está en modo debug
  static bool get debugMode {
    return (dotenv.env['DEBUG_MODE'] ?? 'true').toLowerCase() == 'true';
  }

  /// Obtiene el nivel de log
  static String get logLevel {
    return dotenv.env['LOG_LEVEL'] ?? 'debug';
  }
}
