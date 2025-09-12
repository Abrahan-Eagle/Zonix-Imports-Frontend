import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'onboarding_page1.dart';
import 'onboarding_page2.dart';
import 'onboarding_page3.dart';
import 'onboarding_page4.dart';
import 'onboarding_page5.dart';
import 'package:zonix/features/utils/user_provider.dart';
import 'package:provider/provider.dart';
import 'onboarding_service.dart';
import 'package:zonix/main.dart';

// Paleta de colores Zonix Imports
class ZonixColors {
  static const Color darkBlue = Color(0xFF0C2D57); // Azul Oscuro (Principal)
  static const Color goldenYellow =
      Color(0xFFFFB400); // Amarillo Dorado (Secundario)
  static const Color brightBlue = Color(0xFF1E90FF); // Azul Brillante (Soporte)
  static const Color pureWhite = Color(0xFFFFFFFF); // Blanco Puro (Neutral)
  static const Color lightGray = Color(0xFFE5E5E5); // Gris Claro (Soporte)
}

final OnboardingService _onboardingService = OnboardingService();

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  List<Widget> get onboardingPages {
    return const [
      WelcomePage(),
      OnboardingPage1(),
      OnboardingPage2(),
      OnboardingPage3(),
      OnboardingPage4(),
      OnboardingPage5(),
    ];
  }

  Future<void> _completeOnboarding(int userId) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
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

    if (_currentPage == onboardingPages.length - 1) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      _completeOnboarding(userId);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _handleBack() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            // Contenido principal
            PageView(
              controller: _controller,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: onboardingPages,
            ),

            // Barra de navegación inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      // Indicador de progreso
                      SmoothPageIndicator(
                        controller: _controller,
                        count: onboardingPages.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          // activeDotColor: theme.primaryColor,
                          // dotColor: theme.dividerColor,

                          activeDotColor:
                              ZonixColors.goldenYellow, // Punto activo dorado
                          dotColor: ZonixColors.pureWhite.withOpacity(
                              0.4), // Puntos inactivos semitransparentes
                          spacing: 8,
                          expansionFactor: 3,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botones de navegación
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón Atrás/Saltar
                          if (_currentPage > 0)
                            TextButton(
                              onPressed: _handleBack,
                              child: const Text('Atrás'),
                            )
                          else
                            TextButton(
                              onPressed: () async {
                                final userId = userProvider.userId;
                                await _completeOnboarding(userId);
                              },
                              child: const Text('Saltar'),
                            ),

                          // Botón Siguiente/Finalizar
                          FloatingActionButton(
                            onPressed: _handleNext,
                            backgroundColor: ZonixColors.goldenYellow,
                            elevation: 4,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: ZonixColors.darkBlue,
                                    strokeWidth: 2,
                                  )
                                : Icon(
                                    _currentPage == onboardingPages.length - 1
                                        ? Icons.check
                                        : Icons.arrow_forward,
                                    color: ZonixColors.darkBlue,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
