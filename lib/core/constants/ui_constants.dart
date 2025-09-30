import 'package:flutter/material.dart';

/// Constantes de UI centralizadas para Zonix Imports
/// Este archivo centraliza todos los colores, tamaños y constantes de UI
/// para mantener consistencia en toda la aplicación
class UIConstants {
  // ========================================
  // 🎨 PALETA DE COLORES PRINCIPAL
  // ========================================

  /// Colores base de la marca
  static const Color primaryBlue =
      Color(0xFF1E40AF); // Azul profesional principal
  static const Color secondaryBlue = Color(0xFF1CA9E5); // Azul secundario
  static const Color accentBlue = Color(0xFF1CA9E5); // Azul de acento

  /// Colores de estado
  static const Color success = Color(0xFF43D675); // Verde éxito
  static const Color warning = Color(0xFFFFC72C); // Amarillo advertencia
  static const Color error = Color(0xFFFF4B3E); // Rojo error
  static const Color info = Color(0xFF1CA9E5); // Azul información

  /// Colores de marca
  static const Color orange = Color(0xFFFF9800); // Naranja marca
  static const Color orangeCoral = Color(0xFFFF5722); // Naranja coral
  static const Color yellow = Color(0xFFFFC72C); // Amarillo

  /// Colores neutros
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  /// Escala de grises
  static const Color grayLight = Color(0xFFF5F5F5); // Gris muy claro
  static const Color grayMedium = Color(0xFF64748B); // Gris medio
  static const Color gray = Color(0xFF4A4A4A); // Gris estándar
  static const Color grayDark = Color(0xFF23262B); // Gris oscuro
  static const Color backgroundDark = Color(0xFF181A20); // Fondo oscuro

  /// Colores de texto
  static const Color textPrimary = Color(0xFF0A2239); // Texto principal
  static const Color textSecondary = Color(0xFF4A4A4A); // Texto secundario
  static const Color textLight = Color(0xFF64748B); // Texto claro
  static const Color textWhite = Colors.white; // Texto blanco

  /// Colores de fondo
  static const Color cardBgLight = Color(0xFFF5F5F5); // Fondo tarjeta claro
  static const Color cardBgDark = Color(0xFF23262B); // Fondo tarjeta oscuro

  // ========================================
  // 📏 TAMAÑOS Y ESPACIADO
  // ========================================

  /// Espaciado estándar
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  /// Padding estándar
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  /// Margin estándar
  static const double marginXS = 4.0;
  static const double marginSM = 8.0;
  static const double marginMD = 16.0;
  static const double marginLG = 24.0;
  static const double marginXL = 32.0;

  // ========================================
  // 📐 BORDES Y RADIOS
  // ========================================

  /// Radios de borde
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 50.0;

  /// Grosor de bordes
  static const double borderThin = 0.5;
  static const double borderNormal = 1.0;
  static const double borderThick = 2.0;

  // ========================================
  // 🔤 TIPOGRAFÍA
  // ========================================

  /// Tamaños de fuente
  static const double fontSizeXS = 12.0;
  static const double fontSizeSM = 14.0;
  static const double fontSizeMD = 16.0;
  static const double fontSizeLG = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeTitle = 28.0;
  static const double fontSizeHeader = 32.0;

  /// Pesos de fuente
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // ========================================
  // 📱 COMPONENTES
  // ========================================

  /// Alturas estándar
  static const double heightButton = 48.0;
  static const double heightInput = 56.0;
  static const double heightAppBar = 56.0;
  static const double heightTabBar = 48.0;

  /// Anchos estándar
  static const double widthButton = 120.0;
  static const double widthInput = double.infinity;

  /// Íconos
  static const double iconSizeXS = 16.0;
  static const double iconSizeSM = 20.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  static const double iconSizeXL = 48.0;

  // ========================================
  // 🎭 ELEVACIONES Y SOMBRAS
  // ========================================

  /// Elevaciones estándar
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 16.0;

  // ========================================
  // ⏱️ ANIMACIONES
  // ========================================

  /// Duraciones de animación
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Curvas de animación
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveBounceIn = Curves.bounceIn;
  static const Curve curveBounceOut = Curves.bounceOut;

  // ========================================
  // 🎨 HELPERS DE TEMA
  // ========================================

  /// Obtener color de fondo según el tema
  static Color getBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? backgroundDark : white;

  /// Obtener color de tarjeta según el tema
  static Color getCardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? cardBgDark
          : cardBgLight;

  /// Obtener color de texto principal según el tema
  static Color getPrimaryTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textWhite : textPrimary;

  /// Obtener color de texto secundario según el tema
  static Color getSecondaryTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white70
          : textSecondary;

  // ========================================
  // 📐 BREAKPOINTS RESPONSIVOS
  // ========================================

  /// Breakpoints para diseño responsivo
  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  static const double breakpointLarge = 1440.0;

  // ========================================
  // 🎯 CONSTANTES ESPECÍFICAS DE LA APP
  // ========================================

  /// Configuración específica de Zonix Imports
  static const String appName = 'Zonix Imports';
  static const String appVersion = '1.0.0';

  /// Configuración de imagen de perfil
  static const double profileImageSize = 80.0;
  static const double profileImageSizeSmall = 40.0;
  static const double profileImageSizeLarge = 120.0;

  /// Configuración de productos
  static const double productImageHeight = 200.0;
  static const double productCardHeight = 280.0;

  /// Configuración de carrito
  static const double cartItemHeight = 80.0;
  static const double cartItemImageSize = 60.0;
}
