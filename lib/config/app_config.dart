import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Inicializar dotenv
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // API URLs - Desde .env
  static String get apiUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) {
      return dotenv.env['API_URL_PROD'] ?? 'https://zonix.uniblockweb.com';
    }
    return dotenv.env['API_URL_LOCAL'] ?? 'http://192.168.0.101:8000';
  }

  // WebSocket Configuration - Desde .env
  static String get wsUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) {
      return dotenv.env['WS_URL_PROD'] ?? 'wss://zonix.uniblockweb.com';
    }
    return dotenv.env['WS_URL_LOCAL'] ?? 'ws://192.168.0.101:6001';
  }

  // Echo Server Configuration - Desde .env
  static String get echoAppId => dotenv.env['ECHO_APP_ID'] ?? 'zonix-eats-app';
  static String get echoKey => dotenv.env['ECHO_KEY'] ?? 'zonix-eats-key';
  static bool get enableWebsockets =>
      (dotenv.env['ENABLE_WEBSOCKETS'] ?? 'true').toLowerCase() == 'true';

  // Google Maps API Key - Desde .env
  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'your_google_maps_api_key_here';

  // Firebase Configuration - Desde .env
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? 'your_firebase_project_id';
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? 'your_sender_id';
  static String get firebaseAppId =>
      dotenv.env['FIREBASE_APP_ID'] ?? 'your_app_id';

  // Configuración de la aplicación - Desde .env
  static String get appName => dotenv.env['APP_NAME'] ?? 'ZONIX-IMPORTS';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get appBuildNumber => dotenv.env['APP_BUILD_NUMBER'] ?? '1';

  // Configuración de paginación - Desde .env
  static int get defaultPageSize =>
      int.tryParse(dotenv.env['DEFAULT_PAGE_SIZE'] ?? '20') ?? 20;
  static int get maxPageSize =>
      int.tryParse(dotenv.env['MAX_PAGE_SIZE'] ?? '100') ?? 100;

  // Configuración de timeouts - Desde .env
  static int get connectionTimeout =>
      int.tryParse(dotenv.env['CONNECTION_TIMEOUT'] ?? '30000') ?? 30000;
  static int get receiveTimeout =>
      int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '30000') ?? 30000;
  static int get requestTimeout =>
      int.tryParse(dotenv.env['REQUEST_TIMEOUT'] ?? '30000') ?? 30000;

  // Configuración de reintentos - Desde .env
  static int get maxRetryAttempts =>
      int.tryParse(dotenv.env['MAX_RETRY_ATTEMPTS'] ?? '3') ?? 3;
  static int get retryDelayMs =>
      int.tryParse(dotenv.env['RETRY_DELAY_MS'] ?? '1000') ?? 1000;

  // Configuración de desarrollo - Desde .env
  static bool get debugMode =>
      (dotenv.env['DEBUG_MODE'] ?? 'true').toLowerCase() == 'true';
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'debug';
}
