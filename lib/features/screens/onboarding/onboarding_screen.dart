import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'onboarding_page1.dart';
import 'onboarding_page2.dart';
import 'onboarding_page3.dart';
import 'onboarding_page4.dart';
import 'onboarding_page5.dart';
import 'onboarding_page6.dart';
import 'onboarding_service.dart';
import 'package:zonix/main.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/utils/user_provider.dart';
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

final OnboardingService _onboardingService = OnboardingService();

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Controladores de animación para microinteracciones
  late AnimationController _buttonAnimationController;
  late AnimationController _indicatorAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _indicatorPulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _indicatorAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _indicatorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    _indicatorPulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _indicatorAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  List<Widget> get onboardingPages {
    return const [
      WelcomePage(),
      OnboardingPage1(),
      OnboardingPage2(),
      OnboardingPage3(),
      OnboardingPage4(),
      OnboardingPage5(),
      OnboardingPage6(),
    ];
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Obtener el userId del UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Asegurar que tenemos los detalles más recientes del usuario
      final userDetails = await userProvider.getUserDetails();
      final userId = userDetails['userId'];

      if (userId == null || userId == 0) {
        throw Exception("ID de usuario no encontrado");
      }

      await _onboardingService.completeOnboarding(userId);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainRouter()),
      );
    } catch (e) {
      debugPrint("Error al completar el onboarding: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al completar el onboarding'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleNext() {
    if (_isLoading) return;

    // Feedback háptico
    HapticFeedback.lightImpact();

    // Animación del botón
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    if (_currentPage == onboardingPages.length - 1) {
      _completeOnboarding(context);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handleBack() {
    if (_currentPage > 0) {
      // Feedback háptico
      HapticFeedback.lightImpact();

      // Animación del botón
      _buttonAnimationController.forward().then((_) {
        _buttonAnimationController.reverse();
      });

      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // Método dispose ya está definido arriba

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            // Contenido principal con navegación gestual mejorada
            PageView(
              controller: _controller,
              physics: const BouncingScrollPhysics(), // Física más natural
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                // Feedback háptico al cambiar página
                HapticFeedback.selectionClick();
              },
              children: onboardingPages,
            ),

            // Barra de navegación inferior con efectos modernos
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Indicador de progreso con animación
                        AnimatedBuilder(
                          animation: _indicatorPulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _currentPage == onboardingPages.length - 1
                                  ? _indicatorPulseAnimation.value
                                  : 1.0,
                              child: SmoothPageIndicator(
                                controller: _controller,
                                count: onboardingPages.length,
                                effect: ExpandingDotsEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  activeDotColor: ZonixColors.primaryBlue,
                                  dotColor:
                                      ZonixColors.mediumGray.withOpacity(0.3),
                                  spacing: 12,
                                  expansionFactor: 4,
                                  radius: 16,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Botones de navegación con efectos neumórficos
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Botón Atrás/Saltar con glassmorphism
                            _buildNavigationButton(
                              text: _currentPage > 0 ? 'Atrás' : 'Saltar',
                              onPressed: _currentPage > 0
                                  ? _handleBack
                                  : () async {
                                      await _completeOnboarding(context);
                                    },
                              isSecondary: true,
                            ),

                            // Botón Siguiente/Finalizar con neumorfismo
                            _buildNextButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para crear botón de navegación con glassmorphism
  Widget _buildNavigationButton({
    required String text,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: ZonixColors.glassBackground.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ZonixColors.mediumGray.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ZonixColors.neumorphicDark.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    ),
                    BoxShadow(
                      color: ZonixColors.neumorphicLight.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: BorderRadius.circular(16),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: ZonixColors.darkGray,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Método para crear botón siguiente con neumorfismo
  Widget _buildNextButton() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: ZonixColors.white,
              borderRadius: BorderRadius.circular(20),
              // Efecto neumórfico prominente
              boxShadow: [
                BoxShadow(
                  color: ZonixColors.neumorphicDark.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(6, 6),
                ),
                BoxShadow(
                  color: ZonixColors.neumorphicLight.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(-6, -6),
                ),
                // Sombra de elevación adicional
                BoxShadow(
                  color: ZonixColors.primaryBlue.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _handleNext,
                borderRadius: BorderRadius.circular(20),
                splashColor: ZonixColors.primaryBlue.withOpacity(0.1),
                highlightColor: ZonixColors.primaryBlue.withOpacity(0.05),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: ZonixColors.primaryBlue,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          _currentPage == onboardingPages.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          color: ZonixColors.primaryBlue,
                          size: 28,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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

          // Logo profesional
          _buildProfessionalLogo(),
          const SizedBox(height: 32),

          // Título principal
          _buildMainTitle(),
          const SizedBox(height: 12),

          // Subtítulo
          _buildSubtitle(),
          const SizedBox(height: 40),

          // Características destacadas
          _buildFeatures(),
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

  Widget _buildProfessionalLogo() {
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/logo_login.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: ZonixColors.primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 60,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainTitle() {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final textScaleFactor = MediaQuery.of(context).textScaleFactor;
        final isTablet = screenWidth >= 600;

        // Tamaño responsive basado en el dispositivo y escala de texto
        double baseFontSize = isTablet ? 48.0 : 32.0;
        double responsiveFontSize = baseFontSize * textScaleFactor;

        return Text(
          '¡Bienvenido a Zonix!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: FontWeight.w700,
            color: ZonixColors.darkGray,
            letterSpacing: -0.5,
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final textScaleFactor = MediaQuery.of(context).textScaleFactor;
        final isTablet = screenWidth >= 600;

        // Tamaño responsive basado en el dispositivo y escala de texto
        double baseFontSize = isTablet ? 20.0 : 16.0;
        double responsiveFontSize = baseFontSize * textScaleFactor;

        return Text(
          'Tu puerta de entrada a productos premium desde Estados Unidos.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: FontWeight.w400,
            color: ZonixColors.mediumGray,
            height: 1.5,
          ),
        );
      },
    );
  }

  Widget _buildFeatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureItem(Icons.public, 'Global'),
        _buildFeatureItem(Icons.verified, 'Confiable'),
        _buildFeatureItem(Icons.flash_on, 'Rápido'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Builder(
      builder: (context) {
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
      },
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
          _buildStatItem('50+', 'Países'),
          _buildStatItem('10K+', 'Productos'),
          _buildStatItem('4.8', 'Rating'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Builder(
      builder: (context) {
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
      },
    );
  }

  Widget _buildTabletInfoSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/logo_login.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: ZonixColors.primaryBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: 80,
                  ),
                );
              },
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
              '¡Bienvenido a Zonix!',
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
              'Tu puerta de entrada a productos premium desde Estados Unidos.',
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
          'assets/onboarding/onboardingPage1.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: ZonixColors.lightGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
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
        _buildTabletFeatureItem(Icons.public, 'Productos globales'),
        const SizedBox(height: 16),
        _buildTabletFeatureItem(Icons.verified, 'Calidad garantizada'),
        const SizedBox(height: 16),
        _buildTabletFeatureItem(Icons.flash_on, 'Entrega rápida'),
      ],
    );
  }

  Widget _buildTabletFeatureItem(IconData icon, String text) {
    return Builder(
      builder: (context) {
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
      },
    );
  }
}
