import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    final bool isProduction = const bool.fromEnvironment('dart.vm.product');

    if (isProduction) {
      return dotenv.env['API_URL_PROD'] ?? 'http://192.168.27.12:8000/api';
    } else {
      return dotenv.env['API_URL_LOCAL'] ?? 'http://192.168.27.12:8000/api';
    }
  }

  static const String appName = 'Zonix Imports';
  static const String appVersion = '1.0.0';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Paginación
  static const int defaultPerPage = 15;
  static const int maxPerPage = 50;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration wishlistCacheDuration = Duration(days: 7);

  // Images
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
}
