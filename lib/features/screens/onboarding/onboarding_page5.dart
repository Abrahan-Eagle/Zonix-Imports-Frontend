import 'package:flutter/material.dart';
import 'dart:ui';

// Paleta de colores Material You vibrante (2025)
class ZonixColors {
  static const Color seedColor =
      Color(0xFF6750A4); // Púrpura vibrante como base
  static const Color darkBlue = Color(0xFF0C2D57); // Azul Oscuro (Principal)
  static const Color goldenYellow =
      Color(0xFFFFB400); // Amarillo Dorado (Secundario)
  static const Color brightBlue = Color(0xFF1E90FF); // Azul Brillante (Soporte)
  static const Color pureWhite = Color(0xFFFFFFFF); // Blanco Puro (Neutral)
  static const Color lightGray = Color(0xFFE5E5E5); // Gris Claro (Soporte)

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

class _OnboardingPage5State extends State<OnboardingPage5>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isSmallPhone = size.width < 360;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ZonixColors.darkBlue, // Azul oscuro arriba
            Color(0xFF1A3A5C), // Azul medio
            Color(0xFF2A4A6C), // Azul más claro abajo
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Imagen de fondo con overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/onboarding/onboardingPage6.png'),
                    fit: BoxFit.cover,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ZonixColors.darkBlue.withOpacity(0.8),
                      ZonixColors.darkBlue.withOpacity(0.5),
                      ZonixColors.darkBlue.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Contenido principal
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 64.0 : (isSmallPhone ? 16.0 : 20.0),
                vertical: isTablet ? 32.0 : 16.0,
              ),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Espaciado superior flexible
                            const Spacer(flex: 1),

                            // Contenido principal
                            _buildMainContent(isTablet, isSmallPhone),

                            // Espaciador
                            SizedBox(
                                height:
                                    isTablet ? 32 : (isSmallPhone ? 20 : 24)),

                            // Características de favoritos
                            _buildFavoritesFeatures(isTablet, isSmallPhone),

                            // Espaciador flexible
                            const Spacer(flex: 2),

                            // Espacio para la navegación flotante
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isTablet, bool isSmallPhone) {
    return Column(
      children: [
        // Icono de favoritos
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : (isSmallPhone ? 12 : 16)),
          decoration: BoxDecoration(
            color: ZonixColors.goldenYellow,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ZonixColors.goldenYellow.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.favorite,
            size: isTablet ? 50 : (isSmallPhone ? 35 : 40),
            color: ZonixColors.darkBlue,
          ),
        ),

        SizedBox(height: isTablet ? 24 : (isSmallPhone ? 16 : 20)),

        // Título principal con tipografía expresiva
        Text(
          'Tus Favoritos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTablet ? 40 : (isSmallPhone ? 26 : 32),
            fontWeight: FontWeight.w800, // Más audaz
            color: ZonixColors.pureWhite,
            height: 1.1,
            letterSpacing: 1.5, // Más espaciado para expresividad
            shadows: [
              Shadow(
                color: ZonixColors.darkBlue.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),

        SizedBox(height: isTablet ? 20 : (isSmallPhone ? 12 : 16)),

        // Mensaje descriptivo con glassmorphism
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(isTablet ? 24 : (isSmallPhone ? 16 : 20)),
              decoration: BoxDecoration(
                color: ZonixColors.glassBackground.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ZonixColors.pureWhite.withOpacity(0.2),
                  width: 1.5,
                ),
                // Efecto neumórfico sutil
                boxShadow: [
                  BoxShadow(
                    color: ZonixColors.neumorphicDark.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(4, 4),
                  ),
                  BoxShadow(
                    color: ZonixColors.neumorphicLight.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(-4, -4),
                  ),
                ],
              ),
              child: Text(
                'Guarda lo que te interesa y recíbelo cuando lo necesites.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ZonixColors.pureWhite,
                  fontSize: isTablet ? 18 : (isSmallPhone ? 13 : 15),
                  height: 1.6, // Mejor interlineado
                  fontWeight: FontWeight.w500, // Más peso
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: ZonixColors.darkBlue.withOpacity(0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesFeatures(bool isTablet, bool isSmallPhone) {
    return Wrap(
      spacing: isTablet ? 32 : (isSmallPhone ? 24 : 28),
      runSpacing: isTablet ? 24 : (isSmallPhone ? 16 : 20),
      alignment: WrapAlignment.center,
      children: [
        _buildFavoritesFeature(
          Icons.bookmark_add,
          'Guarda',
          ZonixColors.goldenYellow,
          isTablet,
          isSmallPhone,
        ),
        _buildFavoritesFeature(
          Icons.access_time,
          'Cuando quieras',
          ZonixColors.brightBlue,
          isTablet,
          isSmallPhone,
        ),
        _buildFavoritesFeature(
          Icons.delivery_dining,
          'Recíbelo',
          ZonixColors.pureWhite,
          isTablet,
          isSmallPhone,
        ),
      ],
    );
  }

  Widget _buildFavoritesFeature(IconData icon, String label, Color color,
      bool isTablet, bool isSmallPhone) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 16 : (isSmallPhone ? 10 : 12)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: isTablet ? 28 : (isSmallPhone ? 20 : 24),
          ),
        ),
        SizedBox(height: isTablet ? 12 : (isSmallPhone ? 6 : 8)),
        Text(
          label,
          style: TextStyle(
            color: ZonixColors.pureWhite,
            fontSize: isTablet ? 14 : (isSmallPhone ? 10 : 12),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
