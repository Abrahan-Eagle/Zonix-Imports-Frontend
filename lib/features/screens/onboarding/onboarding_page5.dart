import 'package:flutter/material.dart';
import 'dart:ui';

// Paleta de colores profesional (2025) - Inspirado en Alibaba/AliExpress/Amazon
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

class OnboardingPage5 extends StatefulWidget {
  const OnboardingPage5({super.key});

  @override
  State<OnboardingPage5> createState() => _OnboardingPage5State();
}

class _OnboardingPage5State extends State<OnboardingPage5> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ZonixColors.lightGray,
              ZonixColors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isTablet) {
                return _buildTabletLayout(constraints);
              } else {
                return _buildMobileLayout(constraints);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 1),

          // Icono de favoritos
          _buildFavoritesIcon(),
          const SizedBox(height: 32),

          // Título principal
          _buildMainTitle(),
          const SizedBox(height: 12),

          // Subtítulo
          _buildSubtitle(),
          const SizedBox(height: 40),

          // Características de favoritos
          _buildFavoritesFeatures(),
          const SizedBox(height: 40),

          // Estadísticas
          _buildStats(),

          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BoxConstraints constraints) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(48),
        child: Row(
          children: [
            // Sección izquierda - Información
            Expanded(
              flex: 1,
              child: _buildTabletInfoSection(),
            ),
            const SizedBox(width: 48),
            // Sección derecha - Visual
            Expanded(
              flex: 1,
              child: _buildTabletVisualSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesIcon() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ZonixColors.primaryBlue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ZonixColors.primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 60,
          ),
        ),
      ),
    );
  }

  Widget _buildMainTitle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final isTablet = screenWidth >= 600;
    
    // Tamaño responsive basado en el dispositivo y escala de texto
    double baseFontSize = isTablet ? 48.0 : 32.0;
    double responsiveFontSize = baseFontSize * textScaleFactor;
    
    return Text(
      'Tus Favoritos',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: responsiveFontSize,
        fontWeight: FontWeight.w700,
        color: ZonixColors.darkGray,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSubtitle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final isTablet = screenWidth >= 600;
    
    // Tamaño responsive basado en el dispositivo y escala de texto
    double baseFontSize = isTablet ? 20.0 : 16.0;
    double responsiveFontSize = baseFontSize * textScaleFactor;
    
    return Text(
      'Guarda lo que te interesa y recíbelo cuando lo necesites.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: responsiveFontSize,
        fontWeight: FontWeight.w400,
        color: ZonixColors.mediumGray,
        height: 1.5,
      ),
    );
  }

  Widget _buildFavoritesFeatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureItem(Icons.bookmark_add, 'Guarda'),
        _buildFeatureItem(Icons.access_time, 'Cuando quieras'),
        _buildFeatureItem(Icons.delivery_dining, 'Recíbelo'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final isTablet = screenWidth >= 600;
    
    // Tamaños responsive basados en el dispositivo y escala de texto
    double containerSize = isTablet ? 56.0 : 48.0;
    double iconSize = isTablet ? 28.0 : 24.0;
    double baseFontSize = isTablet ? 14.0 : 12.0;
    double responsiveFontSize = baseFontSize * textScaleFactor;
    
    return Column(
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: ZonixColors.lightGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ZonixColors.mediumGray.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: ZonixColors.primaryBlue,
            size: iconSize,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: FontWeight.w500,
            color: ZonixColors.mediumGray,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: ZonixColors.lightGray,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('∞', 'Favoritos'),
          _buildStatItem('24h', 'Notificación'),
          _buildStatItem('1-Click', 'Compra'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final isTablet = screenWidth >= 600;
    
    // Tamaños responsive basados en el dispositivo y escala de texto
    double valueFontSize = isTablet ? 24.0 : 20.0;
    double labelFontSize = isTablet ? 14.0 : 12.0;
    double responsiveValueFontSize = valueFontSize * textScaleFactor;
    double responsiveLabelFontSize = labelFontSize * textScaleFactor;
    
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: responsiveValueFontSize,
            fontWeight: FontWeight.w700,
            color: ZonixColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: responsiveLabelFontSize,
            fontWeight: FontWeight.w500,
            color: ZonixColors.mediumGray,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletInfoSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono de favoritos
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ZonixColors.primaryBlue.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: ZonixColors.primaryBlue,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 80,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Título
        Builder(
          builder: (context) {
            final textScaleFactor = MediaQuery.of(context).textScaleFactor;
            double baseFontSize = 48.0;
            double responsiveFontSize = baseFontSize * textScaleFactor;
            
            return Text(
              'Tus Favoritos',
              style: TextStyle(
                fontSize: responsiveFontSize,
                fontWeight: FontWeight.w700,
                color: ZonixColors.darkGray,
                letterSpacing: -1,
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Subtítulo
        Builder(
          builder: (context) {
            final textScaleFactor = MediaQuery.of(context).textScaleFactor;
            double baseFontSize = 20.0;
            double responsiveFontSize = baseFontSize * textScaleFactor;
            
            return Text(
              'Guarda lo que te interesa y recíbelo cuando lo necesites.',
              style: TextStyle(
                fontSize: responsiveFontSize,
                fontWeight: FontWeight.w400,
                color: ZonixColors.mediumGray,
                height: 1.5,
              ),
            );
          },
        ),
        const SizedBox(height: 40),

        // Características
        _buildTabletFeatures(),
      ],
    );
  }

  Widget _buildTabletVisualSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ZonixColors.primaryBlue.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/onboarding/onboardingPage6.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: ZonixColors.lightGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.favorite,
                color: ZonixColors.primaryBlue,
                size: 100,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabletFeatures() {
    return Column(
      children: [
        _buildTabletFeatureItem(Icons.bookmark_add, 'Lista de deseos'),
        const SizedBox(height: 16),
        _buildTabletFeatureItem(Icons.access_time, 'Notificaciones'),
        const SizedBox(height: 16),
        _buildTabletFeatureItem(Icons.delivery_dining, 'Compra rápida'),
      ],
    );
  }

  Widget _buildTabletFeatureItem(IconData icon, String text) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double baseFontSize = 16.0;
    double responsiveFontSize = baseFontSize * textScaleFactor;
    double iconSize = 20 * textScaleFactor;
    double containerSize = 40 * textScaleFactor;
    
    return Row(
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: ZonixColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: ZonixColors.primaryBlue,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: FontWeight.w500,
            color: ZonixColors.darkGray,
          ),
        ),
      ],
    );
  }
}