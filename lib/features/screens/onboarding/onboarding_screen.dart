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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        ZonixColors.darkBlue.withOpacity(0.8),
                        ZonixColors.darkBlue.withOpacity(0.95),
                      ],
                    ),
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
                                  activeDotColor: ZonixColors.goldenYellow,
                                  dotColor:
                                      ZonixColors.pureWhite.withOpacity(0.3),
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
                    color: ZonixColors.pureWhite.withOpacity(0.3),
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
                        color: ZonixColors.pureWhite,
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
              color: ZonixColors.goldenYellow,
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
                  color: ZonixColors.goldenYellow.withOpacity(0.4),
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
                splashColor: ZonixColors.darkBlue.withOpacity(0.1),
                highlightColor: ZonixColors.darkBlue.withOpacity(0.05),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: ZonixColors.darkBlue,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          _currentPage == onboardingPages.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          color: ZonixColors.darkBlue,
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
                    image: AssetImage('assets/onboarding/onboardingPage1.png'),
                    fit: BoxFit.cover,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ZonixColors.darkBlue.withOpacity(0.7),
                      ZonixColors.darkBlue.withOpacity(0.4),
                      ZonixColors.darkBlue.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Contenido principal
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Espaciado superior flexible
                  const Spacer(flex: 2),

                  // Logo/Brand Zonix Imports
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ZonixColors.pureWhite.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ZonixColors.goldenYellow.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ZonixColors.goldenYellow.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Icono de caja/importación
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ZonixColors.goldenYellow,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    ZonixColors.goldenYellow.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: ZonixColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ZONIX',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                                color: ZonixColors.pureWhite,
                                letterSpacing: 2,
                              ),
                        ),
                        Text(
                          'IMPORTS',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: ZonixColors.goldenYellow,
                                letterSpacing: 1,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Mensaje de bienvenida
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: ZonixColors.pureWhite.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ZonixColors.brightBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '¡Bienvenido a Zonix Imports!\nDonde lo que imaginas, lo traemos hasta tus manos.',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: ZonixColors.pureWhite,
                                height: 1.4,
                              ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Elementos de confianza
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: ZonixColors.pureWhite.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ZonixColors.lightGray.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTrustElement('📦', 'Importación\nGlobal'),
                        _buildTrustElement('⚡', 'Entrega\nRápida'),
                        _buildTrustElement('🛡️', 'Confianza\nTotal'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Descripción adicional
                  Text(
                    'Conectamos el mundo con Venezuela\n🌍 Tu puerta de entrada a productos únicos',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ZonixColors.pureWhite.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                  ),

                  // Espaciado inferior flexible
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustElement(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ZonixColors.pureWhite.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: ZonixColors.goldenYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ZonixColors.pureWhite,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
