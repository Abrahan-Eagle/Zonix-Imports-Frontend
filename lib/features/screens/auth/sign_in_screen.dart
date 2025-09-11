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
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? _loginError;
  bool _isLoading = false;

  // Paleta de colores Zonix Imports mejorada
  static const Color primaryBlue = Color(0xFF00356A);
  static const Color secondaryGold = Color(0xFFFFBE1A);
  static const Color accentBlue = Color(0xFF0A4A88);
  static const Color darkBackground = Color(0xFF001A2B);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

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
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotateController);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header compacto
            _buildCompactHeader(),

            const SizedBox(height: 16),

            // Error message
            if (_loginError != null) _buildErrorMessage(),

            // Contenido principal
            Expanded(
              child: Column(
                children: [
                  // Hero section
                  Expanded(
                    flex: 4,
                    child: _buildMobileHeroSection(),
                  ),

                  const SizedBox(height: 12),

                  // Auth section
                  Expanded(
                    flex: 3,
                    child: _buildMobileAuthSection(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BoxConstraints constraints) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(40),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header para tablet
              _buildTabletHeader(),

              const SizedBox(height: 40),

              // Error message
              if (_loginError != null) _buildErrorMessage(),

              // Contenido principal en dos columnas
              Expanded(
                child: Row(
                  children: [
                    // Columna izquierda - Hero
                    Expanded(
                      flex: 1,
                      child: _buildTabletHeroSection(),
                    ),

                    const SizedBox(width: 40),

                    // Columna derecha - Auth
                    Expanded(
                      flex: 1,
                      child: _buildTabletAuthSection(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            darkBackground,
            primaryBlue,
            accentBlue,
            Color(0xFF002D4A),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Elementos geométricos animados mejorados
          Positioned(
            top: -100,
            right: -100,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      secondaryGold.withOpacity(0.1),
                      secondaryGold.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: secondaryGold.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            left: -150,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      lightBackground.withOpacity(0.08),
                      lightBackground.withOpacity(0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Patrón de puntos mejorado
          ...List.generate(20, (index) {
            return Positioned(
              top: ((index * 60.0) % 800).roundToDouble(),
              left: ((index * 90.0) % 500).roundToDouble(),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_pulseAnimation.value * 0.2),
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: secondaryGold.withOpacity(0.4),
                        boxShadow: [
                          BoxShadow(
                            color: secondaryGold.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Elementos decorativos adicionales
          Positioned(
            top: 200,
            left: 50,
            child: _buildFloatingElement(size: 12, opacity: 0.15),
          ),
          Positioned(
            top: 400,
            right: 80,
            child: _buildFloatingElement(size: 8, opacity: 0.1),
          ),
          Positioned(
            bottom: 300,
            left: 100,
            child: _buildFloatingElement(size: 15, opacity: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElement(
      {required double size, required double opacity}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_pulseAnimation.value * 0.1),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  secondaryGold.withOpacity(opacity),
                  secondaryGold.withOpacity(opacity * 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _loginError!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TimeOfDay.now().format(context),
              style: const TextStyle(
                color: lightBackground,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Importaciones globales',
              style: TextStyle(
                color: secondaryGold,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: lightBackground.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: secondaryGold.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Image.asset(
            'assets/images/logo_login.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TimeOfDay.now().format(context),
              style: const TextStyle(
                color: lightBackground,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Importaciones globales',
              style: TextStyle(
                color: secondaryGold,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: lightBackground.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: secondaryGold.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Image.asset(
            'assets/images/logo_login.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeroSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo principal con animación
          ScaleTransition(
            scale: _pulseAnimation,
            child: Image.asset(
              'assets/images/logo_login2.png',
              width: 421.875,
              height: 175.5,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 20),

          // Mensaje principal
          Text(
            'El mundo en tus manos',
            style: const TextStyle(
              color: lightBackground,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Productos únicos desde cualquier lugar del mundo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: lightBackground.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // Íconos de productos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: secondaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: secondaryGold.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('📱', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Text('🎧', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Text('⌚', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Text('💻', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Text('🎮', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletHeroSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo principal más grande para tablet
          ScaleTransition(
            scale: _pulseAnimation,
            child: Image.asset(
              'assets/images/logo_login2.png',
              width: 703.125,
              height: 316.125,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 40),

          // Mensaje principal para tablet
          Text(
            'El mundo en tus manos',
            style: const TextStyle(
              color: lightBackground,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Productos únicos desde cualquier lugar del mundo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: lightBackground.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // Íconos de productos para tablet
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: secondaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: secondaryGold.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('📱', style: TextStyle(fontSize: 24)),
                SizedBox(width: 16),
                Text('🎧', style: TextStyle(fontSize: 24)),
                SizedBox(width: 16),
                Text('⌚', style: TextStyle(fontSize: 24)),
                SizedBox(width: 16),
                Text('💻', style: TextStyle(fontSize: 24)),
                SizedBox(width: 16),
                Text('🎮', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAuthSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Estadísticas de confianza
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTrustIndicator('🌍', '50+', 'Países'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 1,
                height: 25,
                decoration: BoxDecoration(
                  color: secondaryGold.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              _buildTrustIndicator('📦', '10K+', 'Productos'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 1,
                height: 25,
                decoration: BoxDecoration(
                  color: secondaryGold.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              _buildTrustIndicator('⭐', '4.8', 'Rating'),
            ],
          ),
        ),

        // Botón de Google mejorado
        _buildGoogleSignInButton(),

        // Garantías de seguridad
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: lightBackground.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: lightBackground.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                color: secondaryGold,
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Compras seguras • Envío garantizado • Soporte 24/7',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: lightBackground.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Términos legales
        Text(
          'Al continuar aceptas nuestros términos de servicio y política de privacidad',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: lightBackground.withOpacity(0.6),
            fontSize: 8,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletAuthSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Estadísticas de confianza para tablet
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTrustIndicator('🌍', '50+', 'Países', isTablet: true),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: 3,
                height: 50,
                decoration: BoxDecoration(
                  color: secondaryGold.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              _buildTrustIndicator('📦', '10K+', 'Productos', isTablet: true),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: 3,
                height: 50,
                decoration: BoxDecoration(
                  color: secondaryGold.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              _buildTrustIndicator('⭐', '4.8', 'Rating', isTablet: true),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Botón de Google para tablet
        _buildGoogleSignInButton(isTablet: true),

        const SizedBox(height: 24),

        // Garantías de seguridad para tablet
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: lightBackground.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: lightBackground.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                color: secondaryGold,
                size: 20,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Compras seguras • Envío garantizado • Soporte 24/7',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: lightBackground.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Términos legales para tablet
        Text(
          'Al continuar aceptas nuestros términos de servicio y política de privacidad',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: lightBackground.withOpacity(0.6),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton({bool isTablet = false}) {
    return Container(
      width: isTablet ? 400 : double.infinity,
      height: isTablet ? 72 : 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 14),
        gradient: LinearGradient(
          colors: [
            lightBackground,
            lightBackground.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: secondaryGold.withOpacity(0.4),
            blurRadius: isTablet ? 25 : 15,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isTablet ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleSignIn,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 14),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  SizedBox(
                    width: isTablet ? 28 : 20,
                    height: isTablet ? 28 : 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 10),
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 8),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
                    ),
                    child: Image.asset(
                      'assets/images/google_logo.png',
                      height: isTablet ? 32 : 24,
                      width: isTablet ? 32 : 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.shopping_bag_outlined,
                          size: isTablet ? 32 : 24,
                          color: primaryBlue,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 10),
                ],
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoading ? 'INICIANDO...' : 'COMENZAR COMPRAS',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 13,
                        fontWeight: FontWeight.w800,
                        color: primaryBlue,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (!_isLoading)
                      Text(
                        'Con Google',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.w500,
                          color: primaryBlue.withOpacity(0.7),
                          letterSpacing: 0.3,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustIndicator(String emoji, String number, String label,
      {bool isTablet = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: isTablet ? 28 : 18),
        ),
        const SizedBox(height: 1),
        Text(
          number,
          style: TextStyle(
            color: secondaryGold,
            fontSize: isTablet ? 20 : 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: lightBackground.withOpacity(0.8),
            fontSize: isTablet ? 12 : 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
