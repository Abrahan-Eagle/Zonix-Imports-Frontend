import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:zonix/features/services/auth/api_service.dart';
import 'package:zonix/main.dart';
import 'package:zonix/features/services/auth/google_sign_in_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zonix/features/utils/auth_utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zonix/features/screens/onboarding/onboarding_screen.dart';
import 'dart:ui';

const FlutterSecureStorage _storage = FlutterSecureStorage();
final ApiService apiService = ApiService();
final logger = Logger();

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final GoogleSignInService googleSignInService = GoogleSignInService();
  bool isAuthenticated = false;
  GoogleSignInAccount? _currentUser;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  String? _loginError;
  bool _isLoading = false;

  // Paleta de colores profesional (2025) - Inspirado en Alibaba/AliExpress/Amazon
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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthentication();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    isAuthenticated = await AuthUtils.isAuthenticated();
    if (isAuthenticated) {
      _currentUser = await GoogleSignInService.getCurrentUser();
      if (_currentUser != null) {
        logger.i('Foto de usuario: ${_currentUser!.photoUrl}');
        await _storage.write(
            key: 'userPhotoUrl', value: _currentUser!.photoUrl);
        logger.i('Nombre de usuario: ${_currentUser!.displayName}');
        await _storage.write(
            key: 'displayName', value: _currentUser!.displayName);
      }
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      await GoogleSignInService.signInWithGoogle();
      _currentUser = await GoogleSignInService.getCurrentUser();

      if (_currentUser != null) {
        await AuthUtils.saveUserName(
            _currentUser!.displayName ?? 'Nombre no disponible');
        await AuthUtils.saveUserEmail(_currentUser!.email);
        await AuthUtils.saveUserPhotoUrl(
            _currentUser!.photoUrl ?? 'URL de foto no disponible');

        String? savedName = await _storage.read(key: 'userName');
        String? savedEmail = await _storage.read(key: 'userEmail');
        String? savedPhotoUrl = await _storage.read(key: 'userPhotoUrl');
        String? savedOnboardingString =
            await _storage.read(key: 'userCompletedOnboarding');

        logger.i('Nombre guardado: $savedName');
        logger.i('Correo guardado: $savedEmail');
        logger.i('Foto guardada: $savedPhotoUrl');
        logger.i('Onboarding guardada: $savedOnboardingString');

        bool onboardingCompleted = savedOnboardingString == '1';
        logger.i('Conversión de completedOnboarding: $onboardingCompleted');

        if (!mounted) return;

        // Success haptic feedback
        HapticFeedback.mediumImpact();

        if (!onboardingCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainRouter()),
          );
        }
      } else {
        logger.i('Inicio de sesión cancelado o fallido');
        if (!mounted) return;
        setState(() {
          _loginError = 'Inicio de sesión cancelado o fallido';
        });
      }
    } catch (e) {
      logger.e('Error durante el manejo del inicio de sesión: $e');
      if (!mounted) return;
      setState(() {
        _loginError = 'Error durante el inicio de sesión';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Stack(
          children: [
            // Fondo mejorado con gradiente y elementos geométricos
            _buildEnhancedBackground(),

            // Contenido principal responsive
            SafeArea(
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
          ],
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

          // Tarjeta de login
          _buildLoginCard(),
          const SizedBox(height: 24),

          // Indicadores de confianza
          _buildTrustIndicators(),

          const Spacer(flex: 1),

          // Footer
          _buildProfessionalFooter(),
          const SizedBox(height: 20),
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
            const SizedBox(width: 80),
            // Sección derecha - Login
            Expanded(
              flex: 1,
              child: _buildTabletLoginSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Patrón sutil de fondo
          _buildSubtlePattern(),
        ],
      ),
    );
  }

  Widget _buildSubtlePattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: SubtlePatternPainter(),
        size: Size.infinite,
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
              color: const Color(0xFF1E40AF).withOpacity(0.1),
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
                  color: const Color(0xFF1E40AF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.store,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final isTablet = screenWidth >= 600;

    // Tamaño responsive basado en el dispositivo y escala de texto
    double baseFontSize = isTablet ? 48.0 : 32.0;
    double responsiveFontSize = baseFontSize * textScaleFactor;

    return Text(
      'Zonix Imports',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: responsiveFontSize,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
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
      'Productos premium desde Estados Unidos',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: responsiveFontSize,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF64748B),
        height: 1.5,
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(32),
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
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Builder(
            builder: (context) {
              final screenWidth = MediaQuery.of(context).size.width;
              final textScaleFactor = MediaQuery.of(context).textScaleFactor;
              final isTablet = screenWidth >= 600;

              // Tamaño responsive basado en el dispositivo y escala de texto
              double baseFontSize = isTablet ? 32.0 : 24.0;
              double responsiveFontSize = baseFontSize * textScaleFactor;

              return Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: responsiveFontSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Botón de Google
          _buildGoogleButton(),
          const SizedBox(height: 16),

          // Mostrar error si existe
          if (_loginError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFECACA),
                  width: 1,
                ),
              ),
              child: Builder(
                builder: (context) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final textScaleFactor =
                      MediaQuery.of(context).textScaleFactor;
                  final isTablet = screenWidth >= 600;

                  // Tamaño responsive basado en el dispositivo y escala de texto
                  double baseFontSize = isTablet ? 16.0 : 14.0;
                  double responsiveFontSize = baseFontSize * textScaleFactor;

                  return Text(
                    _loginError!,
                    style: TextStyle(
                      fontSize: responsiveFontSize,
                      color: const Color(0xFFDC2626),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Texto de términos
          Builder(
            builder: (context) {
              final screenWidth = MediaQuery.of(context).size.width;
              final textScaleFactor = MediaQuery.of(context).textScaleFactor;
              final isTablet = screenWidth >= 600;

              // Tamaño responsive basado en el dispositivo y escala de texto
              double baseFontSize = isTablet ? 14.0 : 12.0;
              double responsiveFontSize = baseFontSize * textScaleFactor;

              return Text(
                'Al continuar aceptas nuestros términos de servicio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsiveFontSize,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final isTablet = screenWidth >= 600;

    // Tamaño responsive basado en el dispositivo y escala de texto
    double baseFontSize = isTablet ? 18.0 : 16.0;
    double responsiveFontSize = baseFontSize * textScaleFactor;
    double buttonHeight = isTablet ? 64.0 : 56.0;
    double iconSize = 20 * textScaleFactor;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleSignIn,
        icon: _isLoading
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Image.asset(
                'assets/images/google_logo.png',
                width: iconSize,
                height: iconSize,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.login,
                    color: Colors.white,
                    size: iconSize,
                  );
                },
              ),
        label: Text(
          _isLoading ? 'Iniciando sesión...' : 'Continuar con Google',
          style: TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E40AF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTrustItem(Icons.security, 'Seguro'),
        _buildTrustItem(Icons.local_shipping, 'Envío rápido'),
        _buildTrustItem(Icons.support_agent, 'Soporte 24/7'),
      ],
    );
  }

  Widget _buildTrustItem(IconData icon, String label) {
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
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E40AF),
            size: iconSize,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalFooter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final isTablet = screenWidth >= 600;

    // Tamaño responsive basado en el dispositivo y escala de texto
    double baseFontSize = isTablet ? 14.0 : 12.0;
    double responsiveFontSize = baseFontSize * textScaleFactor;

    return Text(
      '© 2025 Zonix Imports. Todos los derechos reservados.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: responsiveFontSize,
        color: const Color(0xFF94A3B8),
      ),
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
                color: const Color(0xFF1E40AF).withOpacity(0.1),
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
                    color: const Color(0xFF1E40AF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.store,
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
              'Zonix Imports',
              style: TextStyle(
                fontSize: responsiveFontSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
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
              'Productos premium desde Estados Unidos',
              style: TextStyle(
                fontSize: responsiveFontSize,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            );
          },
        ),
        const SizedBox(height: 40),

        // Características
        _buildFeatureList(),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeatureItem(Icons.verified, 'Productos verificados'),
        const SizedBox(height: 16),
        _buildFeatureItem(Icons.speed, 'Envío rápido y seguro'),
        const SizedBox(height: 16),
        _buildFeatureItem(Icons.support_agent, 'Soporte 24/7'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
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
            color: const Color(0xFF1E40AF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E40AF),
            size: iconSize,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: responsiveFontSize,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLoginSection() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) {
                final textScaleFactor = MediaQuery.of(context).textScaleFactor;
                double baseFontSize = 28.0;
                double responsiveFontSize = baseFontSize * textScaleFactor;

                return Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: responsiveFontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Botón de Google
            _buildGoogleButton(),
            const SizedBox(height: 24),

            // Mostrar error si existe
            if (_loginError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFECACA),
                    width: 1,
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    final textScaleFactor =
                        MediaQuery.of(context).textScaleFactor;
                    double baseFontSize = 14.0;
                    double responsiveFontSize = baseFontSize * textScaleFactor;

                    return Text(
                      _loginError!,
                      style: TextStyle(
                        fontSize: responsiveFontSize,
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Texto de términos
            Builder(
              builder: (context) {
                final textScaleFactor = MediaQuery.of(context).textScaleFactor;
                double baseFontSize = 14.0;
                double responsiveFontSize = baseFontSize * textScaleFactor;

                return Text(
                  'Al continuar aceptas nuestros términos de servicio y política de privacidad',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsiveFontSize,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Clase para pintar el patrón sutil
class SubtlePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Dibujar puntos sutiles
    for (int i = 0; i < 100; i++) {
      final x = (i * 73) % size.width;
      final y = (i * 97) % size.height;

      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
